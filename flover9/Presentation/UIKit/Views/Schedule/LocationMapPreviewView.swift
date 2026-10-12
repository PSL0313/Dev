//
//  LocationMapPreviewView.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//

import UIKit
import MapKit
import SnapKit

/// 위치를 표시해야 되는 콘텐츠에서 프리뷰로 보여주는 맵뷰
class LocationMapPreviewView: UIView {
    // MARK: - Properties
    private var mapItem: MKMapItem?
    
    /// 주소 스택뷰 확장 상태 유무
    private var isAddressExpanded = false
    
    // MARK: - UI
    private let venueLabel: UILabel = {
        let l = UILabel()
        l.textColor = .label
        l.textAlignment = .left
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 12, weight: .bold)
        
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return l
    }()
    
    private let addressLabel: UILabel = {
        let l = UILabel()
        l.textColor = .label
        l.textAlignment = .left
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 10, weight: .light)
        l.setContentHuggingPriority(.defaultLow, for: .vertical)
        return l
    }()
    
    private lazy var stackView = {
        let stv = UIStackView(arrangedSubviews: [venueLabel, addressLabel])
        stv.axis = .vertical
        stv.spacing = 4
        stv.alignment = .leading
        stv.distribution = .fill
        
        stv.isLayoutMarginsRelativeArrangement = true
        stv.layoutMargins = UIEdgeInsets(
            top: 4,
            left: 12,
            bottom: 4,
            right: 12
        )
        
        
        
        stv.backgroundColor = .systemBackground
        
        stv.layer.cornerRadius = 12
        stv.layer.cornerCurve = .continuous
        
        // 그림자를 쓰기 때문에 masksToBounds는 false
        stv.layer.masksToBounds = false
        
        stv.layer.shadowColor = UIColor.black.cgColor
        stv.layer.shadowOpacity = 0.12
        stv.layer.shadowRadius = 6
        stv.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        stv.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(toggleAddressExpansion)
        )
        
        stv.addGestureRecognizer(tapGesture)
        
        
        return stv
    }()
    
    private lazy var roadAddressCopyButton: UIButton = {
        
        let image = UIImage(systemName: "doc.on.doc")
        
        let button = UIButton(type: .system)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        button.backgroundColor = .systemBackground
        
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        
        // 그림자를 쓰기 때문에 masksToBounds는 false
        button.layer.masksToBounds = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                guard let roadAddress = self.mapItem?.address else { return }
                
                UIPasteboard.general.string = roadAddress.fullAddress
                showCopySuccess()
            },
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var resetButtonRegion: UIButton = {
        
        let image = UIImage(
            systemName: "location.fill"
        )
        
        let button = UIButton(type: .system)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        button.backgroundColor = .systemBackground
        
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        
        // 그림자를 쓰기 때문에 masksToBounds는 false
        button.layer.masksToBounds = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        button.addAction(
            UIAction { [weak self] _ in
                self?.resetRegion()
            },
            for: .touchUpInside
        )
        
        return button
    }()
    
    /// Pointer
    private var locationAnnotation: MKPointAnnotation?
    
    /// Map View
    private let map: MKMapView = {
        let map = MKMapView()
        
        // map.mapType = .standard // iOS 16 미만 사용
        
        map.preferredConfiguration = MKStandardMapConfiguration() //스탠다드
        map.isScrollEnabled = false     // 스크롤 차단
        map.isZoomEnabled = true       // 줌 차단
        map.isPitchEnabled = false      // 두손가락으로 동시에 올리거나 내려서 2D <-> 3D 전환 차단
        map.isRotateEnabled = false     // 지도 방향 조절 차단
        return map
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureLayout
    private func configureLayout() {
        addSubview(map)
        map.addSubview(resetButtonRegion)
        
        map.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        resetButtonRegion.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(15)
            $0.height.equalToSuperview().dividedBy(10)
            $0.width.equalTo(resetButtonRegion.snp.height)
        }
        
        
        map.addSubview(roadAddressCopyButton)
        map.addSubview(stackView)
        
        roadAddressCopyButton.snp.makeConstraints {
            $0.trailing.top.equalToSuperview().inset(15)
            $0.height.equalToSuperview().dividedBy(10)
            $0.width.equalTo(resetButtonRegion.snp.height)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(15)
            $0.trailing.equalTo(roadAddressCopyButton.snp.leading).offset(-15)
            $0.height.equalToSuperview().dividedBy(10)
        }
    }
    
    // Apple Map 플랫폼에 등롣된 장소 아이디를 사용할 때
    func configure(mapItem: MKMapItem?) {
        // 다시 호출될 때 이전 핀이 남지 않도록 제거
        if let locationAnnotation {
            map.removeAnnotation(locationAnnotation)
            self.locationAnnotation = nil
        }
        
        guard let mapItem else { return }
        self.mapItem = mapItem
        
        
        if let venueName = mapItem.name {
            venueLabel.text = ("장소: \(venueName)")
        }
        
        
        let address = mapItem.addressRepresentations?
            .fullAddress(
                includingRegion: false,
                singleLine: true
            )
        
        if let address {
            addressLabel.text = "주소: \(address)"
        }
        
        
        // 리전 생성 및 주입
        let coordinate = mapItem.location.coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        // 리전 적용 (MKCoordinateRegion에 설정한 값에 맞게 해당 영역을 보여줌)
        self.map.region = region
        
        
        // 정확한 위치에 표시할 핀 생성 및 주입
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = mapItem.name
        
        map.addAnnotation(annotation)
        locationAnnotation = annotation
    }
    
    
    /// 리전 원복
    private func resetRegion() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            guard let region = makeRegion() else { return }
            map.region = region
        }
    }
    
    
    @MainActor private func showCopySuccess() {
        copySuccess()
        
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(4.0))
            
            guard let self else { return }
            self.resetCopyButtonImage()
        }
    }
    
    
    @objc @MainActor private func toggleAddressExpansion() {
        UIView.animate(withDuration: 1) { [weak self] in
            guard let self else { return }
            
            if isAddressExpanded {
                stackView.snp.remakeConstraints {
                    $0.leading.top.equalToSuperview().inset(15)
                    $0.trailing.equalTo(self.roadAddressCopyButton.snp.leading).offset(-15)
                    $0.height.equalToSuperview().dividedBy(10)
                }
            } else {
                stackView.snp.remakeConstraints {
                    $0.leading.top.equalToSuperview().inset(15)
                    $0.trailing.equalTo(self.roadAddressCopyButton.snp.leading).offset(-15)
                }
            }
            
            isAddressExpanded.toggle()
            
            addressLabel.numberOfLines = isAddressExpanded ? 0 : 1
            
            self.layoutIfNeeded()
        }
    }
    
}

private extension LocationMapPreviewView {
    /// 리전 생성
    private func makeRegion() -> MKCoordinateRegion? {
        guard let mapItem else { return nil }
        let coordinate = mapItem.location.coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        return region
    }
    
    func copySuccess() {
        roadAddressCopyButton.setImage(
            UIImage(systemName: "checkmark.circle.fill"),
            for: .normal
        )
    }
    
    func resetCopyButtonImage() {
        roadAddressCopyButton.setImage(
            UIImage(systemName: "doc.on.doc"),
            for: .normal
        )
    }
}

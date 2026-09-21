//
//  DetailScheduleViewController.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import UIKit
import EventKit
import EventKitUI
import SnapKit
import Kingfisher
import MapKit

/// 일정 내용은 스크롤하고, 예매 버튼은 화면 하단에 고정한다.
final class DetailScheduleViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ScheduleDetailViewModel

    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let rootView = UIView()
    
    /// 배너(Hero)뷰
    private let banner = ScheduleHeroBannerView()
    
    /// 일정 상태
    private let statusView = ScheduleStatusView()
    
    /// 일정 제목
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    /// 일정 및 시간
    private lazy var datetimeView: ScheduleDateTimeView = {
       let v = ScheduleDateTimeView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        
        v.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.viewModel.action(.calendarAddButtonTapped)
        }), for: .touchUpInside)
        
        return v
    }()
    
    /// 지도 프리뷰
    private let mapPreviewView: LocationMapPreviewView = {
        let map = LocationMapPreviewView()
        map.layer.cornerCurve = .continuous
        map.layer.cornerRadius = 20
        map.layer.masksToBounds = true
        return map
    }()
    
    /// 설명 및 공지 등 텍스트뷰
    private let descriptionView = ScheduleDescriptionView()
    
    /// 내부 이미지 콘텐츠(행사 상세 이미지)
    private let mediaStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    // 스크롤뷰 최하단 뷰. 플로팅으로 인해 여백이 필요한데 단순 배경색은 어색하기 때문에 마지막 콘텐츠의 평균 색상을 넣음
    private let bottomBlendView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        return v
    }()
    
    
    /// 바로가기 버튼
    private lazy var ticketButton: UIControl = {
       let btn = ScheduleReservationControl()
        btn.addAction(UIAction(handler: { [weak self]_ in
            guard let self else { return }
            self.viewModel.action(.reservationButtonTapped)
        }), for: .touchUpInside)
        return btn
    }()
    
    
    // 로딩 중 화면
    private let loadingStateView = LoadingStateView()
    // 에러 및 재시도 뷰
    private let errorStateView = ErrorStateView()
    
    

    init(viewModel: ScheduleDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        bind()
        viewModel.action(.start)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if parent == nil { viewModel.cancelLoading() }
    }
}

private extension DetailScheduleViewController {
    private func configureLayout() {
        view.addSubview(errorStateView)
        view.addSubview(loadingStateView)
        
        errorStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
        
        view.addSubview(scrollView)
        view.addSubview(ticketButton)
        
        scrollView.addSubview(rootView)
        rootView.addSubview(banner)
        rootView.addSubview(statusView)
        rootView.addSubview(titleLabel)
        rootView.addSubview(datetimeView)
        rootView.addSubview(mediaStackView)
        rootView.addSubview(bottomBlendView)
        rootView.addSubview(mapPreviewView)
        rootView.addSubview(descriptionView)

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.view.snp.top)
        }

        rootView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        banner.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(banner.snp.width).multipliedBy(9.0 / 16.0)
        }
        
        statusView.snp.makeConstraints {
            $0.top.equalTo(banner.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20) // 최대한 넓어져도 슈퍼뷰 안쪽으로 20까지만
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(statusView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        datetimeView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 장소 위치 정보가 없을 수도 있기 때문에 높이와 위쪽과의 간격을 0으로 해둔 후, 위치 정보가 확인이 된 시점에 제약 변경
        mapPreviewView.snp.makeConstraints {
            $0.top.equalTo(datetimeView.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0)
        }
        
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(mapPreviewView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        mediaStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
        }
        
        bottomBlendView.snp.makeConstraints {
            $0.top.equalTo(mediaStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        ticketButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.snp.bottom).inset(50)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(55)
        }
        
        ticketButton.isHidden = true
        errorStateView.isHidden = true
        scrollView.isHidden = true
        loadingStateView.isHidden = false
        
        
    }
    
    /// 세부 콘텐츠 이미지(상세 이미지) 추가
    func configureMedia(urls: [URL]) {

        // 재사용/재configure 시 기존 이미지 제거
        mediaStackView.arrangedSubviews.forEach {
            mediaStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (idx, url) in urls.enumerated() {
            let imageView = UIImageView()

            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            mediaStackView.addArrangedSubview(imageView)

            imageView.kf.setImage(with: url) { result in
                guard case .success(let value) = result else { return }

                let image = value.image
                let ratio = image.size.height / image.size.width

                imageView.snp.makeConstraints {
                    $0.height.equalTo(imageView.snp.width)
                        .multipliedBy(ratio)
                }
                
                if idx == urls.count - 1 {
                    self.bottomBlendView.backgroundColor = image.averageColor()
                }
            }
        }
    }
    
    ///
    private func configureDescription(_ description : String?) {
        if let description {
            descriptionView.configure(discription: description)
        } else {
            descriptionView.snp.makeConstraints {
                $0.height.equalTo(0)
            }
        }
    }
    
    func bind() {
        viewModel.onState = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                loadingStateView.isHidden = false
                errorStateView.isHidden = true
                scrollView.isHidden = true
            case .loaded(let content, let mapItem):
                
                let presentation = ScheduleDetailPresentation(content: content)
                self.banner.configure(with: presentation.bannerImageURL)
                
                statusView.configure(
                    category: presentation.category,
                    status: presentation.status
                )
                
                titleLabel.text = presentation.title
                datetimeView.configure(date: presentation.date, time: presentation.time)
                
                self.isHiddenMapPreView(mapItem: mapItem)
                self.mapPreviewView.configure(mapItem: mapItem)
                
                self.configureDescription(presentation.description)
                
                configureMedia(urls: presentation.imageURLs)
                
                
                loadingStateView.isHidden = true
                errorStateView.isHidden = true
                
                scrollView.isHidden = false
                ticketButton.isHidden = !presentation.canReserve
                
            case .failed(let message):
                errorStateView.onRetry = { [weak self] in
                    guard let self else { return }
                    self.viewModel.action(.retry)
                }
                
                errorStateView.configure(message: message)
                
                errorStateView.isHidden = false
                scrollView.isHidden = true
                loadingStateView.isHidden = true
                
            case .calendarEventReady(let calendarModel):
                presentCalendarEvent(model: calendarModel)
                
            }
            
            
            view.setNeedsLayout()
        }
    }
    
    private func isHiddenMapPreView(mapItem: MKMapItem?) {
        if mapItem != nil {
            mapPreviewView.snp.remakeConstraints {
                $0.top.equalTo(datetimeView.snp.bottom).offset(15)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(mapPreviewView.snp.width)
            }
        }
    }
}


// MARK: - EventKit, EventKitUI 전용
extension DetailScheduleViewController: EKEventEditViewDelegate {

    func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction
    ) {
        dismiss(animated: true)

        switch action {
        case .saved:
            print("캘린더 추가 완료")

        case .canceled:
            print("사용자가 취소")

        case .deleted:
            break

        @unknown default:
            break
        }
    }
    
    func presentCalendarEvent(
        model: CalendarEventModel
    ) {
        Task { [weak self] in
            guard let self else { return }
            view.isUserInteractionEnabled = false   // 화면 터치 차단
            let eventStore = EKEventStore()
            let event = EKEvent(eventStore: eventStore)

            event.title = model.title
            event.startDate = model.startDate
            event.endDate = model.endDate
            event.isAllDay = model.isAllDay
            event.timeZone = model.timeZone
            event.location = model.location
            event.notes = model.notes
            event.url = model.url

            // 조회 우선순위와 캐싱은 UseCase와 Repository에서 처리한다.
            if let mapItem = model.mapItem {
                event.structuredLocation = EKStructuredLocation(mapItem: mapItem)
            }
        
            let controller = EKEventEditViewController()
            controller.eventStore = eventStore
            controller.event = event
            controller.editViewDelegate = self
            
            view.isUserInteractionEnabled = true // 화면 터치 차단 해제
            
            present(controller, animated: true)
        }
    }
}

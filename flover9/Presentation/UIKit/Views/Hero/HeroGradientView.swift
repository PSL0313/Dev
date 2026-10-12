//
//  HeroGradientView.swift
//  flover9
//
//  Created by 박선린 on 8/17/26.
//
import UIKit

final class HeroGradientView: UIView {

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    private var traitRegistration: UITraitChangeRegistration?


    override init(frame: CGRect) {
        super.init(frame: frame)

        setupGradient()
        registerTraitChanges()
    }


    required init?(coder: NSCoder) {
        fatalError()
    }


    private func setupGradient() {
        updateGradient()
    }


    private func registerTraitChanges() {

        traitRegistration = registerForTraitChanges(
            UITraitCollection.systemTraitsAffectingColorAppearance
        ) { [weak self] (
            _: Self,
            _: UITraitCollection
        ) in

            self?.updateGradient()
        }
    }


//    private func updateGradient() {
//        let backgroundColor = UIColor.systemBackground
//            .resolvedColor(with: traitCollection)
//
//        // 색상 순서
//        gradientLayer.colors = [
//            backgroundColor.withAlphaComponent(0.00).cgColor,
//            backgroundColor.withAlphaComponent(0.00).cgColor,
//            backgroundColor.withAlphaComponent(0.01).cgColor,
//            backgroundColor.withAlphaComponent(0.03).cgColor,
//            backgroundColor.withAlphaComponent(0.07).cgColor,
//            backgroundColor.withAlphaComponent(0.43).cgColor,
//            backgroundColor.withAlphaComponent(0.52).cgColor,
//            backgroundColor.withAlphaComponent(0.65).cgColor,
//            backgroundColor.withAlphaComponent(0.82).cgColor,
//            backgroundColor.withAlphaComponent(1.00).cgColor,
//            backgroundColor.withAlphaComponent(1.00).cgColor
//        ]
//
//        gradientLayer.locations = [
//            0.00,
//            0.38,
//            0.46,
//            0.53,
//            0.60,
//            0.67,
//            0.74,
//            0.81,
//            0.88,
//            0.95,
//            1.00
//        ]
//
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//    }

    private func updateGradient() {
        let backgroundColor = UIColor.systemBackground
            .resolvedColor(with: traitCollection)

        let count = 32
        let startLocation: CGFloat = 0.42

        var colors: [CGColor] = []
        var locations: [NSNumber] = []

        for index in 0..<count {
            let progress = CGFloat(index) / CGFloat(count - 1)

            let location = startLocation
                + (1.0 - startLocation) * progress

            // smootherstep
            let alpha =
                6 * pow(progress, 5)
                - 15 * pow(progress, 4)
                + 10 * pow(progress, 3)

            colors.append(
                backgroundColor
                    .withAlphaComponent(alpha)
                    .cgColor
            )

            locations.append(NSNumber(value: Double(location)))
        }

        // 그라디언트 시작 전에는 완전 투명
        colors.insert(
            backgroundColor.withAlphaComponent(0).cgColor,
            at: 0
        )

        locations.insert(0.0, at: 0)

        gradientLayer.colors = colors
        gradientLayer.locations = locations

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}

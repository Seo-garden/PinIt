//
//  MapBottomSheetViewController.swift
//  Presentation
//
//  Created by 서정원 on 4/15/26.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

public final class MapBottomSheetViewController: UIViewController {
    private let bottomSheetView = MapBottomSheetView()
    private let sheetContentHeight: CGFloat = 200
    private var isAnimating = false

    public var selectedRecord: Signal<Record> {
        bottomSheetView.selectedRecord.asSignal()
    }

    public var isVisible: Bool { parent != nil }

    public override func loadView() {
        view = bottomSheetView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let height = view.bounds.height

        switch gesture.state {
        case .changed:
            let offset = max(0, translation.y)
            view.transform = CGAffineTransform(translationX: 0, y: offset)
        case .ended, .cancelled:
            let shouldDismiss = translation.y > height / 3 || velocity.y > 800
            if shouldDismiss {
                hide()
            } else {
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    usingSpringWithDamping: 0.85,
                    initialSpringVelocity: 0.3,
                    options: [.curveEaseOut]
                ) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
    }

    public func configure(records: [Record]) {
        bottomSheetView.configure(records: records)
    }

    public func show(in parent: UIViewController, animated: Bool = true) {
        guard self.parent == nil, !isAnimating else { return }

        parent.addChild(self)
        parent.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
            view.topAnchor.constraint(
                equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -sheetContentHeight
            )
        ])

        parent.view.layoutIfNeeded()
        didMove(toParent: parent)

        guard animated else { return }

        let height = view.bounds.height
        view.transform = CGAffineTransform(translationX: 0, y: height)
        isAnimating = true
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut]
        ) {
            self.view.transform = .identity
        } completion: { _ in
            self.isAnimating = false
        }
    }

    public func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard parent != nil, !isAnimating else { return }

        let teardown: () -> Void = { [weak self] in
            guard let self else { return }
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.view.transform = .identity
            completion?()
        }

        guard animated else {
            teardown()
            return
        }

        let height = view.bounds.height
        isAnimating = true
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.view.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { _ in
            self.isAnimating = false
            teardown()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MapBottomSheetViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }
}

//
//  Controller.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-05.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

final class Controller: UIPresentationController {
    private let loaf: Loaf
    private let hitTestView = HitTestView()
    
    class HitTestView: UIView {
        weak var presentingView: UIView?
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let presentingView = presentingView, presentingView.window != nil else {
                return super.hitTest(point, with: event)
            }
            return presentingView.hitTest(presentingView.convert(point, from: self), with: event)
        }
    }
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         loaf: Loaf) {
        self.loaf = loaf
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    //MARK: - Transitions
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        hitTestView.presentingView = presentingViewController.view
        hitTestView.frame = containerView.bounds
        hitTestView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(hitTestView)
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return container.preferredContentSize
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let presentedViewSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
        
        let referenceView: UIView
        switch loaf.layoutReference {
        case .currentContext:
            referenceView = presentingViewController.view!
        case .sender:
            referenceView = loaf.sender?.view ?? presentingViewController.view!
        }
        
        let containerSafeArea = containerView.convert(referenceView.frame.inset(by: referenceView.safeAreaInsets), from: referenceView.superview)
        let prettyfierInset = CGFloat(10)
        
        let yPosition: CGFloat
        switch loaf.location {
        case .bottom:
            yPosition = containerSafeArea.maxY - presentedViewSize.height - prettyfierInset
        case .top:
            yPosition = containerSafeArea.minY + prettyfierInset
        }
        
        let toastFrame = CGRect(origin: CGPoint(
            x: (containerView.frame.width - presentedViewSize.width) / 2,
            y: yPosition
        ), size: presentedViewSize)
        return toastFrame
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container === presentedViewController {
            containerView?.setNeedsLayout()
        }
    }
}

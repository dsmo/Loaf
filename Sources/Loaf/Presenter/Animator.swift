//
//  Animator.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-05.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit

final class Animator: NSObject {
    private let loaf: Loaf
    private let duration: TimeInterval
    private var animator: UIViewPropertyAnimator?
    
    init(duration: TimeInterval, loaf: Loaf) {
        self.duration = duration
        self.loaf = loaf
        super.init()
    }
}

extension Animator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let animator else {
            fatalError("The animator should remain exist duration the transtion")
        }
        
        return animator
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
    }
}

extension Animator: UIViewControllerInteractiveTransitioning {
    var wantsInteractiveStart: Bool {
        return false
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        let isPresenting = (toViewController?.presentingViewController === fromViewController)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView
        
        guard let controller = isPresenting ? toViewController : fromViewController else { return }
        guard let view = isPresenting ? toView : fromView else { return }
        
        if isPresenting {
            containerView.addSubview(view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        
        switch isPresenting ? loaf.presentingDirection : loaf.dismissingDirection {
        case .vertical:
            dismissedFrame.origin.y = (loaf.location == .bottom) ? view.frame.height + 60 : -dismissedFrame.height - 60
        case .left:
            dismissedFrame.origin.x = -view.frame.width * 2
        case .right:
            dismissedFrame.origin.x = view.frame.width * 2
        }
        
        let initialFrame = isPresenting ? dismissedFrame : presentedFrame
        let finalFrame = isPresenting ? presentedFrame : dismissedFrame

        view.alpha = isPresenting ? 0 : 1
        view.frame = initialFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1.0)
        let animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timing)
        animator.addAnimations {
            view.frame = finalFrame
            view.alpha = isPresenting ? 1 : 0
        }
        animator.addCompletion { position in
            let completed = (position == .end)
            transitionContext.completeTransition(completed)
        }
        animator.startAnimation()
        self.animator = animator
    }
}

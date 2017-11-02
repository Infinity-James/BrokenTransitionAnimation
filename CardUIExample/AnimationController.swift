import UIKit

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case present
        case dismiss
    }

    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
        let containerView = transitionContext.containerView
        let containerFrame = containerView.frame

        switch direction {
        case .present:
            guard let toViewController = transitionContext.viewController(forKey: .to),
                let toView = transitionContext.view(forKey: .to)
                else { fatalError() }

            var toViewStartFrame = transitionContext.initialFrame(for: toViewController)
            let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
            toViewStartFrame = toViewFinalFrame
            toViewStartFrame.origin.y = containerFrame.size.height - 44
            toView.frame = toViewStartFrame
            animator.addAnimations {
                toView.frame = toViewFinalFrame
            }
        case .dismiss:
            guard let fromViewController = transitionContext.viewController(forKey: .from),
                let fromView = transitionContext.view(forKey: .from)
                else { fatalError() }

            var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
            fromViewFinalFrame.origin.y = containerFrame.size.height - 44
            animator.addAnimations {
                fromView.frame = fromViewFinalFrame
            }
        }

        animator.addCompletion { finish in
            if finish == .end {
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
            } else {
                transitionContext.cancelInteractiveTransition()
                transitionContext.completeTransition(false)
            }
        }

        return animator
    }
}

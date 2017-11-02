import UIKit

class PresentationController: UIPresentationController {
    private let dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimmingView.alpha = 0
        return dimmingView
    }()

    // MARK: UIPresentationController

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
            let presentedView = presentedView else { return }

        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }

        transitionCoordinator.animateAlongsideTransition(in: presentingViewController.view, animation: { _ in
            self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            if !transitionCoordinator.isInteractive {
                (self.presentingViewController as? ViewController)?.statusBarStyle = .lightContent
            }
        })

        transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }

        if completed {
            (presentingViewController as? ViewController)?.statusBarStyle = .lightContent
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })

        transitionCoordinator.animateAlongsideTransition(in: presentingViewController.view, animation: { _ in
            self.presentingViewController.view.transform = CGAffineTransform.identity
            if !transitionCoordinator.isInteractive {
                (self.presentingViewController as? ViewController)?.statusBarStyle = .default
            }
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        if transitionCoordinator.isCancelled {
            return
        }

        if completed {
            dimmingView.removeFromSuperview()
            (presentingViewController as? ViewController)?.statusBarStyle = .default
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        var frame = containerView.bounds
        frame.size.height -= 40
        frame.origin.y += 40
        return frame
    }

    // MARK: UIViewController

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let containerView = containerView else { return }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.frame = containerView.bounds
        })
    }
}

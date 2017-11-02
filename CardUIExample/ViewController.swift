import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    private var interactionController: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let cardView = UIView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red:0.976, green:0.976, blue:0.976, alpha:1)
        view.addSubview(cardView)

        let borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor(red:0.697, green:0.698, blue:0.697, alpha:1)
        view.addSubview(borderView)

        let cardViewTextLabel = UILabel(frame: .zero)
        cardViewTextLabel.translatesAutoresizingMaskIntoConstraints = false
        cardViewTextLabel.text = "Tap or drag"
        cardViewTextLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(cardViewTextLabel)

        let cardViewConstraints = [
            cardView.heightAnchor.constraint(equalToConstant: 44),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 0.5),
            borderView.topAnchor.constraint(equalTo: cardView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cardViewTextLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            cardViewTextLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(cardViewConstraints)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePresentTapGesture(gestureRecognizer:)))
        cardView.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePresentPanGesture(gestureRecognizer:)))
        cardView.addGestureRecognizer(panGestureRecognizer)
    }

    // MARK: Actions

    @objc private func handlePresentTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let viewController = createViewController()
        present(viewController, animated: true, completion: nil)
    }

    @objc private func handlePresentPanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        let height = (gestureRecognizer.view?.superview?.bounds.height)! - 40
        let percentage = abs(translation.y / height)
        switch gestureRecognizer.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            let viewController = createViewController()
            present(viewController, animated: true, completion: nil)
        case .changed:
            interactionController?.update(percentage)
        case .ended:
            if percentage < 0.5 {
                interactionController?.cancel()
            } else {
                interactionController?.finish()
            }
            interactionController = nil
        default: break
        }
    }

    @objc private func handleDismissTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleDismissPanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let height = (gestureRecognizer.view?.bounds.height)!
        let percentage = (translation.y / height)
        switch gestureRecognizer.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true, completion: nil)
        case .changed:
            interactionController?.update(percentage)
        case .ended:
            if percentage < 0.5 {
                interactionController?.cancel()
            } else {
                interactionController?.finish()
            }
            interactionController = nil
        default: break
        }
    }

    // MARK: UIViewControllerTransitioningDelegate

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(direction: .present) : nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Get UIKit to animate if it's not an interative animation
        return AnimationController(direction: .dismiss) : nil
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    // MARK: Private

    func createViewController() -> UIViewController {
        let viewController = UIViewController(nibName: nil, bundle: nil)
        viewController.title = "Tap or drag"
        viewController.view.backgroundColor = .white
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.transitioningDelegate = self
        navigationController.modalPresentationStyle = .custom
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissTapGesture(gestureRecognizer:)))
        navigationController.view.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGesture(gestureRecognizer:)))
        navigationController.view.addGestureRecognizer(panGestureRecognizer)

        return navigationController
    }
}

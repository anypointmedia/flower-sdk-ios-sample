import UIKit

class RootViewController: UIViewController, UINavigationControllerDelegate {
    static var videoKey = "video"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        title = "UIKit VOD Example"

        let videoButtons = (videoList as [Video?] + [nil]).map { video in
            let button = UIButton(type: .system)
            button.setTitle("Play " + (video?.title ?? "Custom Channel"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false

            let selector = #selector(openVideo(sender:))
            objc_setAssociatedObject(button, &RootViewController.videoKey, video, .OBJC_ASSOCIATION_RETAIN)
            button.addTarget(self, action: selector, for: .touchUpInside)

            return button
        }
        
        let stackView = UIStackView(arrangedSubviews: videoButtons)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openVideo(sender: UIButton) {
        let video = objc_getAssociatedObject(sender, &RootViewController.videoKey) as? Video

        let playerVC = PlayerViewController(video: video)
        navigationController?.pushViewController(playerVC, animated: true)
    }
}

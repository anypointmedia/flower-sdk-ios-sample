import UIKit

class RootViewController: UIViewController {
    static var videoKey = "video"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        title = "UIKit Interstitial Ad Example"

        let button = UIButton(type: .system)
        button.setTitle("Show Interstitial Ad", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openContent), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openContent() {
        let interstitialAdViewController = InterstitialAdViewController()
        navigationController?.pushViewController(interstitialAdViewController, animated: true)
    }
}

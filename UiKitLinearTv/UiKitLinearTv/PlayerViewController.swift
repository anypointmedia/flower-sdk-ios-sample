import os
import UIKit
import AVKit
import SwiftUI
import FlowerSdk

class PlayerViewController: UIViewController {
    private let video: Video?
    private var nextVideo: Video!

    private var urlInputField: UITextField? = nil
    private var player = AVQueuePlayer()

    // TODO GUIDE: Create FlowerAdView instance
    private var flowerAdViewHostingController = FlowerAdView.HostingController()
    private var flowerAdView: FlowerAdView {
        flowerAdViewHostingController.adView
    }

    init(video: Video?) {
        self.video = video
        nextVideo = videoList.filter { $0 != video }.first!
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = video?.title ?? "Custom Channel"
        view.backgroundColor = .white

        let leftBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(customBackButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        view.addSubview(playerViewController.view)
        addChild(playerViewController)
        playerViewController.didMove(toParent: self)

        view.addSubview(flowerAdViewHostingController.view)
        addChild(flowerAdViewHostingController)
        flowerAdViewHostingController.didMove(toParent: self)

        // TODO GUIDE: Add FlowerAdView over linear TV content
        flowerAdViewHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flowerAdViewHostingController.view.topAnchor.constraint(equalTo: playerViewController.view.topAnchor),
            flowerAdViewHostingController.view.bottomAnchor.constraint(equalTo: playerViewController.view.bottomAnchor),
            flowerAdViewHostingController.view.leadingAnchor.constraint(equalTo: playerViewController.view.leadingAnchor),
            flowerAdViewHostingController.view.trailingAnchor.constraint(equalTo: playerViewController.view.trailingAnchor)
        ])

        let switchButton = UIButton(type: .system)
        switchButton.setTitle("Switch to \(nextVideo.title)", for: .normal)
        switchButton.addTarget(self, action: #selector(switchChannel), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchButton)

        if (video != nil) {
            playLinearTv(url: video!.url)

            playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                playerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                playerViewController.view.bottomAnchor.constraint(equalTo: switchButton.topAnchor, constant: -20),
                playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            let urlInputField = UITextField()
            self.urlInputField = urlInputField
            urlInputField.placeholder = "Enter video URL"
            urlInputField.text = "https://xxx"
            urlInputField.borderStyle = .roundedRect
            urlInputField.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(urlInputField)

            let playButton = UIButton(type: .system)
            playButton.setTitle("Play", for: .normal)
            playButton.addTarget(self, action: #selector(playFromInput), for: .touchUpInside)
            playButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playButton)

            playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                urlInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                urlInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                urlInputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                playButton.topAnchor.constraint(equalTo: urlInputField.bottomAnchor, constant: 20),
                playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                playerViewController.view.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
                playerViewController.view.bottomAnchor.constraint(equalTo: switchButton.topAnchor, constant: -20),
                playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }

    @objc private func customBackButtonTapped() {
        // TODO GUIDE: Stop Flower SDK and release player resources on view destroy
        flowerAdView.adsManager.removeListener(adsManagerListener: self)
        flowerAdView.adsManager.stop()
        player.pause()
        player.removeAllItems()

        navigationController?.popViewController(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @objc private func playFromInput() {
        if let url = urlInputField?.text {
            playLinearTv(url: url)
        }
    }

    @objc private func switchChannel() {
        // TODO GUIDE: Stop Flower SDK and release player resources on view destroy
        flowerAdView.adsManager.removeListener(adsManagerListener: self)
        flowerAdView.adsManager.stop()
        player.pause()
        player.removeAllItems()

        let newPlayerVC = PlayerViewController(video: nextVideo)

        if let navigationController = navigationController {
            var viewControllers = navigationController.viewControllers
            viewControllers[viewControllers.count - 1] = newPlayerVC
            navigationController.setViewControllers(viewControllers, animated: true)
        }
    }

    private func playLinearTv(url: String) {
        flowerAdView.adsManager.addListener(adsManagerListener: self)

        // TODO GUIDE: Implement MediaPlayerHook to return the player instance
        class MediaPlayerHookImpl: MediaPlayerHook {
            public var getPlayerFn: () -> Any

            public init(getPlayerFn: @escaping () -> Any) {
                self.getPlayerFn = getPlayerFn
            }

            public func getPlayer() -> Any? {
                getPlayerFn()
            }
        }

        let mediaPlayerHook = MediaPlayerHookImpl { self.player }

        // TODO GUIDE: Change original linear TV stream url
        // arg0: videoUrl, original linear TV stream url
        // arg1: adTagUrl, url from flower system
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg2: channelId, unique channel id in your service
        // arg3: extraParams, values you can provide for targeting
        // arg4: mediaPlayerHook, interface that provides currently playing segment information for ad tracking
        // arg5: adTagHeaders, (Optional) values included in headers for ad request
        // arg6: channelStreamHeaders, (Optional) values included in headers for channel stream request
        let changedChannelUrl = flowerAdView.adsManager.changeChannelUrl(
            videoUrl: url,
            adTagUrl: "https://ad_request",
            channelId: "1",
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String](),
            channelStreamHeaders: [String: String]()
        )

        player.removeAllItems()
        player.insert(AVPlayerItem(url: URL(string: changedChannelUrl)!), after: nil)
        player.play()
    }
}

// TODO GUIDE: Implement FlowerAdsManagerListener
extension PlayerViewController: FlowerAdsManagerListener {
    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for linear TV
        }
    }

    func onPlay() {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Implement custom actions for when the ad playback starts
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Implement custom actions for when the ad playback ends
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async { [self] in
            // TODO GUIDE: Stop Flower SDK and release linear TV player resources on ad error
            flowerAdView.adsManager.removeListener(adsManagerListener: self)
            flowerAdView.adsManager.stop()
            player.pause()
            player.removeAllItems()

            if (video != nil) {
                playLinearTv(url: video!.url)
            } else {
                playFromInput()
            }
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for linear TV
            os_log(OSLogType.info, log: .default, "Ad skipped - reason: %d", reason)
        }
    }
}

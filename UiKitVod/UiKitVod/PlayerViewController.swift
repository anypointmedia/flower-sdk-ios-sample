import os
import UIKit
import AVKit
import SwiftUI
import FlowerSdk

class PlayerViewController: UIViewController, UINavigationControllerDelegate {
    private let video: Video?
    private var nextVideo: Video!

    private var urlInputField: UITextField? = nil
    private var durationInputField: UITextField? = nil
    private var player = AVQueuePlayer()
    private var isContentEnd = false

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

        // TODO GUIDE: Add FlowerAdView over VOD content
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
            playVod(url: video!.url, durationMs: video!.durationMs)

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

            let durationInputField = UITextField()
            self.durationInputField = durationInputField
            durationInputField.placeholder = "Enter video duration in milliseconds"
            durationInputField.text = "0"
            durationInputField.borderStyle = .roundedRect
            durationInputField.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(durationInputField)

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

                durationInputField.topAnchor.constraint(equalTo: urlInputField.bottomAnchor, constant: 20),
                durationInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                durationInputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                playButton.topAnchor.constraint(equalTo: durationInputField.bottomAnchor, constant: 20),
                playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                playerViewController.view.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
                playerViewController.view.bottomAnchor.constraint(equalTo: switchButton.topAnchor, constant: -20),
                playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onResume), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func customBackButtonTapped() {
            releasePlayer()

            navigationController?.popViewController(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @objc func onPause() {
        flowerAdView.adsManager.pause()
    }

    @objc func onResume() {
        flowerAdView.adsManager.resume()
    }

    @objc func playerDidFinishPlaying(_ notification: Notification) {
        isContentEnd = true
        // TODO GUIDE: Notify the end of VOD content
        flowerAdView.adsManager.notifyContentEnded()
    }

    @objc private func playFromInput() {
        if (urlInputField == nil || durationInputField == nil) {
            return
        }

        playVod(url: urlInputField!.text!, durationMs: Int64(durationInputField!.text!)!)
    }

    @objc private func switchChannel() {
        releasePlayer()

        let newPlayerVC = PlayerViewController(video: nextVideo)

        if let navigationController = navigationController {
            var viewControllers = navigationController.viewControllers
            viewControllers[viewControllers.count - 1] = newPlayerVC
            navigationController.setViewControllers(viewControllers, animated: true)
        }
    }

    private func playVod(url: String, durationMs: Int64) {
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

        // TODO GUIDE: Request VOD ad
        // arg0: adTagUrl, url from flower system.
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg1: contentId, unique content id in your service
        // arg2: durationMs, duration of VOD content in milliseconds
        // arg3: extraParams, values you can provide for targeting
        // arg4: mediaPlayerHook, interface that provides currently playing segment information for ad tracking
        // arg5: adTagHeaders, values included in headers for ad requests
        flowerAdView.adsManager.requestVodAd(
            adTagUrl: "https://ad_request",
            contentId: "-255",
            durationMs: durationMs,
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String]()
        )

        let playerItem = AVPlayerItem(url: URL(string: url)!)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        player.removeAllItems()
        player.insert(playerItem, after: nil)
        player.play()
    }

    private func releasePlayer() {
        flowerAdView.adsManager.removeListener(adsManagerListener: self)
        flowerAdView.adsManager.stop()
        player.pause()
        player.removeAllItems()
    }
}

// TODO GUIDE: Implement FlowerAdsManagerListener
extension PlayerViewController: FlowerAdsManagerListener {
    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            if (self.player.rate != 0.0) {
                // TODO GUIDE: Play mid-roll ad
                self.flowerAdView.adsManager.play()
            } else {
                // TODO GUIDE: Play pre-roll ad
                self.flowerAdView.adsManager.play()
            }
        }
    }

    func onPlay() {
        DispatchQueue.main.async {
            // TODO GUIDE: Pause VOD content when the ad playback starts
            self.player.pause()
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: Resume VOD content when the ad playback ends
            if self.isContentEnd {
                return
            }

            self.player.play()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: Resume VOD content on ad error
            if self.isContentEnd {
                return
            }

            self.player.play()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for VOD
            os_log(OSLogType.info, log: .default, "Ad skipped - reason: %d", reason)
        }
    }
}

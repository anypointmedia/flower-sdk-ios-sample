import UIKit
import AVKit
import SwiftUI
import FlowerSdk

// TODO GUIDE: implement MediaPlayerHook
class MediaPlayerHookImpl: MediaPlayerHook {
    public var getPlayerFn: () -> Any

    public init(getPlayerFn: @escaping () -> Any) {
        self.getPlayerFn = getPlayerFn
    }

    /**
     * Return a player instance or MediaPlayerAdapter instance
     */
    public func getPlayer() -> Any? {
        getPlayerFn()
    }
}

class PlayerViewController: UIViewController, UINavigationControllerDelegate, FlowerAdsManagerListener {
    private let video: Video?
    private var nextVideo: Video!

    private var urlInputField: UITextField? = nil
    private var durationInputField: UITextField? = nil
    private var playerContainerView = UIView()
    private var player = AVPlayer()
    private var isContentEnd = false
    private var flowerAdView = FlowerAdView()

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
        
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerContainerView)
        playerContainerView.layer.addSublayer(AVPlayerLayer(player: player))
        let flowerAdViewHostingController = UIHostingController(rootView: flowerAdView.body)
        flowerAdViewHostingController.view.backgroundColor = .clear
        addChild(flowerAdViewHostingController)
        playerContainerView.addSubview(flowerAdViewHostingController.view)
        flowerAdViewHostingController.didMove(toParent: self)

        let switchButton = UIButton(type: .system)
        switchButton.setTitle("Switch to \(nextVideo.title)", for: .normal)
        switchButton.addTarget(self, action: #selector(switchChannel), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchButton)

        if (video != nil) {
            playVod(url: video!.url, durationMs: video!.durationMs)

            NSLayoutConstraint.activate([
                playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                playerContainerView.bottomAnchor.constraint(equalTo: switchButton.topAnchor, constant: -20),
                playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

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

            NSLayoutConstraint.activate([
                urlInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                urlInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                urlInputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                durationInputField.topAnchor.constraint(equalTo: urlInputField.bottomAnchor, constant: 20),
                durationInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                durationInputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                playButton.topAnchor.constraint(equalTo: durationInputField.bottomAnchor, constant: 20),
                playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                playerContainerView.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
                playerContainerView.bottomAnchor.constraint(equalTo: switchButton.topAnchor, constant: -20),
                playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }

    @objc private func customBackButtonTapped() {
            releasePlayer()

            navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerContainerView.layer.sublayers?.forEach { $0.frame = playerContainerView.bounds }
    }

    @objc func playerDidFinishPlaying(_ notification: Notification) {
        isContentEnd = true
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

        // TODO GUIDE: implement MediaPlayerHook
        let mediaPlayerHook = MediaPlayerHookImpl {
            return self.player
        }

        // TODO GUIDE: request vod ad
        // arg0: adTagUrl, url from flower system.
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg1: contentId, unique content id in your service
        // arg2: durationMs, duration of vod content in milliseconds
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
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    private func releasePlayer() {
        flowerAdView.adsManager.removeListener(adsManagerListener: self)
        flowerAdView.adsManager.stop()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            if (self.player.rate != 0.0) {
                DispatchQueue.main.async {
                    // TODO GUIDE: play midroll ad
                    self.flowerAdView.adsManager.play()
                }
            } else {
                // TODO GUIDE: play preroll ad
                self.flowerAdView.adsManager.play()
            }
        }
    }

    func onPlay() {
        DispatchQueue.main.async {
            // TODO GUIDE: pause VOD content
            self.player.pause()
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: resume VOD content after ad complete
            if self.isContentEnd {
                return
            }

            self.player.play()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: resume VOD content on ad error
            if self.isContentEnd {
                return
            }

            self.player.play()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            print("Ad skipped: \(reason)")
        }
    }
}

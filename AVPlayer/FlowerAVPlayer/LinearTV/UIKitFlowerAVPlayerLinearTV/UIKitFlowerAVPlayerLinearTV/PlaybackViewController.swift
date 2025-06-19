import UIKit
import AVKit
import FlowerSdk

class PlaybackViewController: UIViewController {
    // TODO GUIDE: Replace your AVPlayer with FlowerAVPlayer
    private var player = FlowerAVPlayer()

    // OPTIONAL GUIDE: Create FlowerAdsManagerListener instance
    private var flowerListener: FlowerAdsManagerListener!

    override func viewDidLoad() {
        super.viewDidLoad()

        let playerViewController = FlowerAVPlayerViewController()
        playerViewController.player = player
        view.addSubview(playerViewController.view)
        addChild(playerViewController)
        playerViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        playLinearTv()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        player.replaceCurrentItem(with: nil)
        player.removeAdListener(listener: flowerListener)
    }

    private func playLinearTv() {
        let videoUrl = "https://XXX"
        let playerItem = AVPlayerItem(url: URL(string: videoUrl)!)
        player.replaceCurrentItem(with: playerItem)

        // TODO GUIDE: Configure linear tv ad
        // arg0: adTagUrl, url from flower system
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg1: prerollAdTagUrl, (Optional) url for linear tv preroll ads from flower system
        //       You must file a request to Anypoint Media to receive a prerollAdTagUrl.
        // arg2: channelId, unique channel id in your service
        // arg3: extraParams, (Optional) values you can provide for targeting
        // arg4: adTagHeaders, (Optional) values included in headers for ad request
        // arg5: channelStreamHeaders, (Optional) values included in headers for channel stream request
        let adConfig = FlowerLinearTvAdConfig(
            adTagUrl: "https://ad_request",
            prerollAdTagUrl: "https://preroll_ad_request",
            channelId: "1",
            extraParams: [
                "title": "My Summer Vacation",
                "genre": "horror",
                "contentRating": "PG-13"
            ],
            adTagHeaders: [
                "custom-ad-header": "custom-ad-header-value"
            ],
            channelStreamHeaders: [
                "custom-stream-header": "custom-stream-header-value"
            ],
        )
        // TODO GUIDE: FlowerAdConfig should be delivered before calling play()
        player.setAdConfig(adConfig: adConfig)

        // OPTIONAL GUIDE: Implement FlowerAdsManagerListener to receive ad events
        class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
            func onPrepare(adDurationMs: Int32) {
                // OPTIONAL GUIDE: Implement custom actions for when the ad playback is prepared
            }
            func onPlay() {
                // OPTIONAL GUIDE: Implement custom actions for when the ad playback starts
            }
            func onCompleted() {
                // OPTIONAL GUIDE: Implement custom actions for when the ad playback ends
            }
            func onError(error: FlowerError?) {
                // OPTIONAL GUIDE: Implement custom actions for when the error occurs in Flower SDK
            }
            func onAdSkipped(reason: Int32) {
                // OPTIONAL GUIDE: Implement custom actions for when the ad playback is skipped
            }
        }
        // OPTIONAL GUIDE: Register FlowerAdsManagerListener to receive ad events
        flowerListener = FlowerAdsManagerListenerImpl()
        player.addAdListener(listener: flowerListener)

        player.play()
    }
}

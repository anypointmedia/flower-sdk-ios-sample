import Foundation
import SwiftUI
import AVFoundation
import AVKit
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

struct PlaybackView: View {
    @State private var player: AVPlayer = AVPlayer()

    private let video: Video?
    private let nextVideo: Video

    @State private var flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl? = nil

    @State private var urlInput: String = "https://xxx"

    init(video: Video?) {
        self.video = video
        nextVideo = videoList.filter { $0 != video }.first!
    }

    var body: some View {
        VStack {
            if video == nil {
                TextField("Enter video URL", text: $urlInput)
                    .padding()
            }
            ZStack {
                VideoPlayer(player: player)
                self.flowerAdView.body
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if video != nil {
                    self.playLinearTv()
                }
            }
            .onDisappear {
                self.releasePlayer()
            }
            if video == nil {
                Button("Play") {
                    self.playLinearTv()
                }
            }
            NavigationLink(destination: PlaybackView(video: nextVideo)) {
                Text("Switch to \(nextVideo.title)")
            }
        }
    }

    func playLinearTv() {
        let videoUrl = video?.url ?? urlInput

        self.flowerAdsManagerListener = FlowerAdsManagerListenerImpl(self)
        flowerAdView.adsManager.addListener(adsManagerListener: self.flowerAdsManagerListener!)

        // TODO GUIDE: implement MediaPlayerHook
        let mediaPlayerHook = MediaPlayerHookImpl {
            return player
        }

        // TODO GUIDE: change original LinearTV stream url by adView.adsManager.changeChannelUrl
        // arg0: videoUrl, original LinearTV stream url
        // arg1: adTagUrl, url from flower system
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg2: channelId, unique channel id in your service
        // arg3: extraParams, values you can provide for targeting
        // arg4: mediaPlayerHook, interface that provides currently playing segment information for ad tracking
        // arg5: adTagHeaders, (Optional) values included in headers for ad request
        // arg6: channelStreamHeaders, (Optional) values included in headers for channel stream request
        let changedChannelUrl = flowerAdView.adsManager.changeChannelUrl(
            videoUrl: videoUrl,
            adTagUrl: "https://ad_request",
            channelId: "1",
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String](),
            channelStreamHeaders: [String: String]()
        )

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: changedChannelUrl)!))
        player.play()
    }

    func releasePlayer() {
        flowerAdView.adsManager.removeListener(adsManagerListener: flowerAdsManagerListener!)
        flowerAdView.adsManager.stop()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    func replayLinearTv() {
        releasePlayer()
        playLinearTv()
    }
}

private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var playbackView: PlaybackView

    init(_ playbackView: PlaybackView) {
        self.playbackView = playbackView
    }

    func onPrepare(adDurationMs: Int32) {
        // OPTIONAL GUIDE: need nothing for linear tv
    }

    func onPlay() {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: enable additional actions for ad playback
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: disable additional actions after ad complete
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: restart to play Linear TV on ad error
            self.playbackView.replayLinearTv()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            print("onAdSkipped: \(reason)")
        }
    }
}

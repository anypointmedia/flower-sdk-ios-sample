import Foundation
import os
import SwiftUI
import AVFoundation
import AVKit
import FlowerSdk

// TODO GUIDE: Implement MediaPlayerHook to return the player instance if the player is supported by Flower SDK
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
    @State public var player = AVQueuePlayer()

    private let video: Video?
    private let nextVideo: Video

    // TODO GUIDE: Create FlowerAdView instance
    @State public var flowerAdView: FlowerAdView = FlowerAdView()
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
                // TODO GUIDE: Add FlowerAdView over linear TV content
                self.flowerAdView.body
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if video != nil {
                    self.playLinearTv()
                }
            }
            .onDisappear {
                // TODO GUIDE: Stop Flower SDK and release player resources on view destroy
                flowerAdView.adsManager.removeListener(adsManagerListener: flowerAdsManagerListener!)
                flowerAdView.adsManager.stop()
                player.pause()
                player.removeAllItems()
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

        // TODO GUIDE: Implement MediaPlayerHook to return the player instance if the player is supported by Flower SDK
        let mediaPlayerHook = MediaPlayerHookImpl {
            return player
        }

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
            videoUrl: videoUrl,
            adTagUrl: "https://ad_request",
            channelId: "1",
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String](),
            channelStreamHeaders: [String: String]()
        )

        player.pause()
        player.removeAllItems()
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: changedChannelUrl)!))
        player.play()
    }
}

// TODO GUIDE: Implement FlowerAdsManagerListener
private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var playbackView: PlaybackView

    init(_ playbackView: PlaybackView) {
        self.playbackView = playbackView
    }

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
            playbackView.flowerAdView.adsManager.removeListener(adsManagerListener: self)
            playbackView.flowerAdView.adsManager.stop()
            playbackView.player.pause()
            playbackView.player.removeAllItems()

            // TODO GUIDE: Restart linear TV playback on ad error
            playbackView.playLinearTv()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for linear TV
            os_log(OSLogType.info, log: .default, "Ad skipped - reason: %d", reason)
        }
    }
}

import Foundation
import SwiftUI
import AVFoundation
import AVKit
import FlowerSdk

// TODO GUIDE: observe AVPlayer finish
class PlayerObserver: NSObject {
    @Published public var playbackFinished = false

    public func observePlaybackEvents(for player: AVPlayer) {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    @objc public func playerDidFinishPlaying(_ notification: Notification) {
        playbackFinished = true
    }

    public func removeObserver(for player: AVPlayer) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
}

// TODO GUIDE: implement MediaPlayerHook
class MediaPlayerHookImpl: MediaPlayerHook {
    public var getPlayerFn: () -> Any

    public init(getPlayerFn: @escaping () -> Any) {
        self.getPlayerFn = getPlayerFn
    }

    public func getPlayer() -> Any? {
        getPlayerFn()
    }
}

struct PlaybackView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var player: AVPlayer = AVPlayer()
    @State var isContentEnd = false

    let observer = PlayerObserver()
    var video: Video

    @StateObject var flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl? = nil

    init(video: Video) {
        self.video = video

        createPlayer()
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ZStack {
                VideoPlayer(player: player)
                self.flowerAdView.body
            }
            .onChange(of: observer.playbackFinished) { playbackFinished in
                if playbackFinished {
                    self.isContentEnd = true
                    flowerAdView.adsManager.notifyContentEnded()
                } else {
                    isContentEnd = false
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.startVideo()
            }
            .onDisappear {
                self.observer.removeObserver(for: player)
                self.stopVideo()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    func startVideo() {
        if (video.vod) {
            playVod()
        } else {
            playLinearTv()
        }
    }

    func stopVideo() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        flowerAdView.adsManager.stop()
    }

    func playVod() {
        self.flowerAdsManagerListener = FlowerAdsManagerListenerImpl(self)
        flowerAdView.adsManager.addListener(adsManagerListener: self.flowerAdsManagerListener!)

        // TODO GUIDE: implement MediaPlayerHook
        let mediaPlayerHook = MediaPlayerHookImpl {
            return player
        }

        // TODO GUIDE: request vod ad
        // arg0: adTagUrl, url from flower system.
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg1: contentId, unique content id in your service
        // arg2: durationMs, duration of vod content in milliseconds
        // arg3: extraParams, values you can provide for targeting
        // arg4: mediaPlayerHook, interface that provides currently playing segment information for ad tracking
        // arg5: adTagHeaders, values included in headers for ad request
        flowerAdView.adsManager.requestVodAd(
            adTagUrl: "https://ad_request",
            contentId: "100",
            durationMs: video.duration,
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String]()
        )

        var playerItem = AVPlayerItem(url: URL(string: video.videoUrl)!)
        player.replaceCurrentItem(with: playerItem)

        // Note: Notification Observer for AVPlayerItemDidPlayToEndTime must be created after AvPlayerItem can be specified, otherwise it would trigger the notification for all instances of AvPlayer
        observer.observePlaybackEvents(for: player)
    }

    func playLinearTv() {
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
            videoUrl: video.videoUrl,
            adTagUrl: "https://ad_request",
            channelId: "1",
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String](),
            channelStreamHeaders: [String: String]()
        )

        // OPTIONAL GUIDE: change extraParams during stream playback
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { [weak flowerAdView] time in
            print("Periodic time change: \(time.value.description)")
            flowerAdView?.adsManager.changeChannelExtraParams(extraParams: ["myTargetingKey": time.value.description]);
        }

        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: changedChannelUrl)!))
        player.play()
    }

    func createPlayer() {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
    }

    func onPlayerError(error: Any) {
        replayLinearTv()
    }

    func replayLinearTv() {
        if (!video.vod) {
            releasePlayer()
            createPlayer()
            playLinearTv()
        }
    }

    func releasePlayer() {
        flowerAdView.adsManager.removeListener(adsManagerListener: self.flowerAdsManagerListener!)
        flowerAdView.adsManager.stop()
        do {
            player.replaceCurrentItem(with: nil)
        } catch {

        }
    }
}

private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    @Environment(\.presentationMode) var presentationMode
    var playbackView: PlaybackView

    init(_ playbackView: PlaybackView) {
        self.playbackView = playbackView
    }

    func onPrepare(adDurationMs: Int32) {
        if (playbackView.video.vod) {
            if (self.playbackView.player.rate != 0.0) {
                DispatchQueue.main.async {
                    // OPTIONAL GUIDE: additional actions before ad playback

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                        // TODO GUIDE: play midroll ad
                        self.playbackView.flowerAdView.adsManager.play()
                    }
                }
            } else {
                // TODO GUIDE: play preroll ad
                self.playbackView.flowerAdView.adsManager.play()
            }
        } else {
            // TODO GUIDE: need nothing for linear tv
        }
    }

    func onPlay() {
        if (playbackView.video.vod) {
            // TODO GUIDE: pause VOD content
            self.playbackView.player.pause()
        } else {
            // OPTIONAL GUIDE: enable additional actions for ad playback
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            if self.playbackView.video.vod {
                // TODO GUIDE: resume VOD content after ad complete
                if self.playbackView.isContentEnd {
                    self.presentationMode.wrappedValue.dismiss()
                    return
                }
                self.playbackView.player.play()
            } else {
                // OPTIONAL GUIDE: disable additional actions after ad complete
            }
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            if (self.playbackView.video.vod) {
                // TODO GUIDE: resume VOD content on ad error
                if self.playbackView.isContentEnd {
                    self.presentationMode.wrappedValue.dismiss()
                    return
                }
                self.playbackView.player.play()
            } else {
                // TODO GUIDE: restart to play Linear TV on ad error
                self.playbackView.replayLinearTv()
            }

        }
    }

    func onAdSkipped(reason: Int32) {
        print("onAdSkipped: \(reason)")
    }
}

import Foundation
import SwiftUI
import AVFoundation
import AVKit
import FlowerSdk

// TODO GUIDE: observe AVPlayer finish
class PlayerObserver: ObservableObject {
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

    /**
     * Return a player instance or MediaPlayerAdapter instance
     */
    public func getPlayer() -> Any? {
        getPlayerFn()
    }
}

struct PlaybackView: View {
    @State var player: AVPlayer = AVPlayer()
    @State var activated = true
    @ObservedObject private var observer = PlayerObserver()
    
    private let video: Video?
    private let nextVideo: Video
    @State var isContentEnd = false

    @State var flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl? = nil

    @State private var urlInput: String = "https://xxx"
    @State private var durationInput: String = "0"

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
            if video == nil {
                TextField("Enter video duration in milliseconds", text: $durationInput)
                    .padding()
            }
            ZStack {
                VideoPlayer(player: player)
                    .background(Color.white)
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
            .onAppear {
                if video != nil {
                    self.playVod()
                }
            }
            .onDisappear {
                self.observer.removeObserver(for: player)
                self.releasePlayer()
            }
            if video == nil {
                Button("Play") {
                    self.playVod()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    func playVod() {
        let videoUrl = video?.url ?? urlInput
        let videoDuration = video?.durationMs ?? Int64(durationInput)!

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
            contentId: "-255",
            durationMs: videoDuration,
            extraParams: [String: String](),
            mediaPlayerHook: mediaPlayerHook,
            adTagHeaders: [String: String]()
        )

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: videoUrl)!))

        observer.observePlaybackEvents(for: player)
    }

    func releasePlayer() {
        flowerAdView.adsManager.removeListener(adsManagerListener: flowerAdsManagerListener!)
        flowerAdView.adsManager.stop()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}

private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var playbackView: PlaybackView

    init(_ playbackView: PlaybackView) {
        self.playbackView = playbackView
    }

    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            if (self.playbackView.player.rate != 0.0) {
                // TODO GUIDE: play midroll ad
                self.playbackView.flowerAdView.adsManager.play()
            } else {
                // TODO GUIDE: play preroll ad
                self.playbackView.flowerAdView.adsManager.play()
            }
        }
    }

    func onPlay() {
        DispatchQueue.main.async {
            // TODO GUIDE: pause VOD content
            self.playbackView.player.pause()
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: resume VOD content after ad complete
            if self.playbackView.isContentEnd {
                return
            }

            self.playbackView.player.play()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: resume VOD content on ad error
            if self.playbackView.isContentEnd {
                return
            }

            self.playbackView.player.play()

        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            print("onAdSkipped: \(reason)")
        }
    }
}

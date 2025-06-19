import Foundation
import os
import SwiftUI
import AVFoundation
import AVKit
import FlowerSdk

struct PlaybackView: View {
    @State private var player = FlowerAVPlayer()
    @State private var flowerListener: FlowerAdsManagerListener!

    private let video: Video?
    private let nextVideo: Video

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
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if video != nil {
                        self.playLinearTv()
                    }
                }
                .onDisappear {
                    player.pause()
                    player.replaceCurrentItem(with: nil)
                    player.removeAdListener(listener: flowerListener)
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

    private func playLinearTv() {
        let videoUrl = video?.url ?? urlInput
        let playerItem = AVPlayerItem(url: URL(string: videoUrl)!)

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

        flowerListener = FlowerAdsManagerListenerImpl()

        let adConfig = FlowerLinearTvAdConfig(
            adTagUrl: "https://ad_request",
            channelId: "1",
        )

        player.setAdConfig(adConfig: adConfig)
        player.addAdListener(listener: flowerListener)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}

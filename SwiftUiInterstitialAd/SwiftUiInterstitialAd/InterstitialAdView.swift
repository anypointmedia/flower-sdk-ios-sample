import Foundation
import os
import SwiftUI
import FlowerSdk

struct InterstitialAdView: View {
    // TODO GUIDE: Create FlowerAdView instance
    private let flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl!

    public init() {
    }

    var body: some View {
        ZStack {
            Text("Original Content")
            // TODO GUIDE: Add FlowerAdView over content
            self.flowerAdView.body
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            requestAd()
        }
        .onDisappear {
            stopAd()
        }
        .edgesIgnoringSafeArea(.all)
    }

    func requestAd() {
        self.flowerAdsManagerListener = FlowerAdsManagerListenerImpl(self)
        flowerAdView.adsManager.addListener(adsManagerListener: flowerAdsManagerListener)

        // TODO GUIDE: Request interstitial ad
        // arg0: adTagUrl, url from flower system
        //       You must file a request to Anypoint Media to receive a adTagUrl.
        // arg1: extraParams, values you can provide for targeting
        // arg2: adTagHeaders, (Optional) values included in headers for ad request
        flowerAdView.adsManager.requestAd(
            adTagUrl: "https://ad_request",
            extraParams: [String: String](),
            adTagHeaders: [String: String]()
        );
    }

    public func playAd() {
        flowerAdView.adsManager.play()
    }

    public func stopAd() {
        flowerAdView.adsManager.removeListener(adsManagerListener: flowerAdsManagerListener)
        flowerAdView.adsManager.stop()
    }
}

// TODO GUIDE: Implement FlowerAdsManagerListener
private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var interstitialAdView: InterstitialAdView

    init(_ interstitialAdView: InterstitialAdView) {
        self.interstitialAdView = interstitialAdView
    }

    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            // TODO GUIDE: Play interstitial ad
            self.interstitialAdView.playAd()
        }
    }

    func onPlay() {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for interstitial ad
        }
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: Stop FlowerAdsManager after the interstitial ad ends
            self.interstitialAdView.stopAd()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: Stop FlowerAdsManager on error
            self.interstitialAdView.stopAd()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for interstitial ad
            os_log(OSLogType.info, log: .default, "Ad skipped - reason: %d", reason)
        }
    }
}

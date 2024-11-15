import Foundation
import SwiftUI
import FlowerSdk

struct InterstitialAdView: View {
    private let flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl!

    public init() {
    }

    var body: some View {
        ZStack {
            Text("Original Content")
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

        // TODO GUIDE: request ad
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

private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var interstitialAdView: InterstitialAdView

    init(_ interstitialAdView: InterstitialAdView) {
        self.interstitialAdView = interstitialAdView
    }

    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            // TODO GUIDE: play ad
            self.interstitialAdView.playAd()
        }
    }

    func onPlay() {
        // OPTIONAL GUIDE: need nothing for interstitial ad
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: stop FlowerAdsManager
            self.interstitialAdView.stopAd()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: stop FlowerAdsManager
            self.interstitialAdView.stopAd()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            print("Ad skipped: \(reason)")
        }
    }
}

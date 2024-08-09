import Foundation
import SwiftUI
import FlowerSdk

struct InterstitialAdView: View {
    // TODO GUIDE: create FlowerAdView instance
    private var flowerAdView: FlowerAdView = FlowerAdView()
    @State private var flowerAdsManagerListener: FlowerAdsManagerListenerImpl!

    public init() {
    }

    var body: some View {
        ZStack {
            Text("Content Below Ad")
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
        flowerAdView.adsManager.stop()
        flowerAdView.adsManager.removeListener(adsManagerListener: flowerAdsManagerListener)
    }
}

private class FlowerAdsManagerListenerImpl: FlowerAdsManagerListener {
    var interstitialView: InterstitialAdView

    init(_ interstitialView: InterstitialAdView) {
        self.interstitialView = interstitialView
    }

    func onPrepare(adDurationMs: Int32) {
        // TODO GUIDE: play ad
        interstitialView.playAd();
    }

    func onPlay() {
        // TODO GUIDE: need nothing for interstitial ad
    }

    func onCompleted() {
        DispatchQueue.main.async {
            // TODO GUIDE: stop FlowerAdsManager
            self.interstitialView.stopAd()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: stop FlowerAdsManager
            self.interstitialView.stopAd()
        }
    }

    func onAdSkipped(reason: Int32) {
        print("onAdSkipped: \(reason)")
    }
}

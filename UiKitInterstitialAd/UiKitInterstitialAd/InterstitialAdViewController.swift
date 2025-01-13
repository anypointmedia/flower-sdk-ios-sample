import os
import UIKit
import SwiftUI
import FlowerSdk

class InterstitialAdViewController: UIViewController {
    // TODO GUIDE: Create FlowerAdView instance
    private var flowerAdView = FlowerAdView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Interstitial Ad"
        view.backgroundColor = .white

        let contentText = UILabel()
        contentText.text = "Original Content"
        contentText.textAlignment = .center
        contentText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentText)

        // TODO GUIDE: Add FlowerAdView over content
        let flowerAdViewHostingController = UIHostingController(rootView: flowerAdView.body)
        flowerAdViewHostingController.view.backgroundColor = .clear
        flowerAdViewHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(flowerAdViewHostingController)
        view.addSubview(flowerAdViewHostingController.view)
        flowerAdViewHostingController.didMove(toParent: self)

        // add flowerAdView to the view & set constraints
        NSLayoutConstraint.activate([
            contentText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentText.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            flowerAdViewHostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            flowerAdViewHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flowerAdViewHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flowerAdViewHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        requestAd()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopAd()
    }

    private func requestAd() {
        flowerAdView.adsManager.addListener(adsManagerListener: self)

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

    private func playAd() {
        flowerAdView.adsManager.play()
    }

    private func stopAd() {
        flowerAdView.adsManager.removeListener(adsManagerListener: self)
        flowerAdView.adsManager.stop()
    }
}


// TODO GUIDE: Implement FlowerAdsManagerListener
extension InterstitialAdViewController: FlowerAdsManagerListener {
    func onPrepare(adDurationMs: Int32) {
        DispatchQueue.main.async {
            // TODO GUIDE: Play interstitial ad
            self.playAd()
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
            self.stopAd()
        }
    }

    func onError(error: FlowerError?) {
        DispatchQueue.main.async {
            // TODO GUIDE: Stop FlowerAdsManager on error
            self.stopAd()
        }
    }

    func onAdSkipped(reason: Int32) {
        DispatchQueue.main.async {
            // OPTIONAL GUIDE: Need nothing to do for interstitial ad
            os_log(OSLogType.info, log: .default, "Ad skipped - reason: %d", reason)
        }
    }
}

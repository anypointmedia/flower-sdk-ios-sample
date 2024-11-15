import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: InterstitialAdView()) {
                    Text("Show Interstitial Ad")
                }
            }
            .navigationTitle("SwiftUI Interstitial Ad Example")
        }
    }

}

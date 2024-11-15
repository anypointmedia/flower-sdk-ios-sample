import SwiftUI

struct RootView: View {
    @State private var currentView: AppView = .root
    @State private var path: [String] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(videoList, id: \.self) { video in
                    NavigationLink(destination: PlaybackView(video: video)) {
                        Text("Play \(video.title)")
                    }
                }
                NavigationLink(destination: PlaybackView(video: nil)) {
                    Text("Play Custom Channel")
                }
            }
            .navigationTitle("SwiftUI Linear TV Example")
        }
    }

}


enum AppView {
    case root
    case playbackViewNew
    case vodView
    case interstitialAdView
}

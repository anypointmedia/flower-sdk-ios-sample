import SwiftUI

struct RootView: View {
    @State private var currentView: AppView = .root
    @State private var path: [String] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(videoList.indices, id: \.self) { index in
                    NavigationLink(destination: ContentView(viewIndex: index, videos: videoList)) {
                        Text("Play \(videoList[index].title)")
                    }
                }
                NavigationLink(destination: PlaybackView(video: nil)) {
                    Text("Play Custom Channel")
                }
            }
            .navigationTitle("SwiftUI VOD Example")
        }
    }

}


enum AppView {
    case root
    case playbackViewNew
    case vodView
    case interstitialAdView
}

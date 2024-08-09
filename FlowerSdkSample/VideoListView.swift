import Foundation
import SwiftUI

struct VideoListView: View {
        
    init() {
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: { PlaybackView(video: VideoList().linearTvList[0]) } ) {
                    Text("LinearTV 1")
                }
                NavigationLink(destination: { PlaybackView(video: VideoList().vodList[0]) } ) {
                    Text("VOD 1")
                }
                NavigationLink(destination: { InterstitialAdView() } ) {
                    Text("Interstitial Ad")
                }
            }
            .navigationBarTitle("")
        }
        .navigationViewStyle(.stack)
    }

}

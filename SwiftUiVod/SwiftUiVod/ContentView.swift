import SwiftUI

struct ContentView: View {
    @State var viewIndex = 0
    @State var isPresent = true
    let videos: [Video]?

    var body: some View {
        if let videos = videos, videos.indices.contains(viewIndex) {
            PlaybackView(video: videos[viewIndex])
                .id(viewIndex)
                .background(Color.white)
        } else {
            PlaybackView(video: nil)
                .background(Color.white)
        }
        
        Button(action: {
            if viewIndex == 0 {
                viewIndex = 1
            } else {
                viewIndex = 0
            }
        }) {
            Text("Play \(videoList[viewIndex].title)")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}

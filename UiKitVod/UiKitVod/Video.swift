import Foundation

class Video: NSObject {
    let title: String
    let url: String
    let durationMs: Int64

    init(title: String, url: String, durationMs: Int64) {
        self.title = title
        self.url = url
        self.durationMs = durationMs
    }
}

let videoList = [
    Video(
        title: "Your VOD Stream 1",
        url: "https://XXX",
        durationMs: 0
    ),
    Video(
        title: "Your VOD Stream 2",
        url: "https://XXX",
        durationMs: 0
    ),
]

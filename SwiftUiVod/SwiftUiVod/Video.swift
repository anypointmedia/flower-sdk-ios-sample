import Foundation

struct Video: Hashable {
    let title: String
    let url: String
    let durationMs: Int64
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

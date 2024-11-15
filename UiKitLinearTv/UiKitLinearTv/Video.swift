import Foundation

class Video: NSObject {
    var title: String
    var url: String

    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

let videoList = [
    Video(
        title: "Your Linear TV Stream 1",
        url: "https://XXX"
    ),
    Video(
        title: "Your Linear TV Stream 2",
        url: "https://XXX"
    ),
]

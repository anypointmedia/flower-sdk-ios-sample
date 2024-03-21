import Foundation

struct VideoList {
    var categoryNames: [String]
    var linearTvList: [Video]
    var vodList: [Video]
    var categoryItems: [[Video]]

    init() {
        categoryNames = ["Linear TV", "VOD"]
        linearTvList = [
            Video(
                title: "Your Linear TV Stream",
                // videoUrl should be a working m3u8 link
                videoUrl: "https://XXX",
                vod: false
            ),
        ]
        vodList = [
            Video(
                title: "Your VOD Stream",
                // videoUrl should be a working m3u8 link
                videoUrl: "https://XXX",
                vod: true,
                // duration of video in milliseconds
                duration: 0
            )
        ]
        categoryItems = [linearTvList, vodList]
    }
}

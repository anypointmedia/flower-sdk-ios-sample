import Foundation

struct Video: Codable {
    var id: Int64 = 0
    var title: String?
    var backgroundImageUrl: String?
    var videoUrl: String
    var vod: Bool = false
    var duration: Int64 = 0

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case backgroundImageUrl
        case videoUrl
        case vod
        case duration
    }
}

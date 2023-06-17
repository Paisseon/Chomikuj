import Foundation

struct DownloadResponse: Decodable {
    let redirectURL: URL
    
    enum CodingKeys: String, CodingKey {
        case redirectURL = "redirectUrl"
    }
}

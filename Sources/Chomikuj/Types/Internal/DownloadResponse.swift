import Foundation

struct DownloadResponse: Decodable {
    let redirectURL: URL
    let trackingCodeJS: String?
    let type: String
    let refreshTopBar: Bool
    let topBar: String?
    
    enum CodingKeys: String, CodingKey {
        case redirectURL = "redirectUrl"
        case type = "Type"
        case trackingCodeJS, refreshTopBar, topBar
    }
}

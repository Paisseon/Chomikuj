struct ActionResponse: Decodable {
    let containsCaptcha: Bool
    let content: String
    let data: [String: Int]
    let isSuccess: Bool
    let title: String
    let type: String
    let refreshTopBar: Bool
    let trackingCodeJS: String?
    
    enum CodingKeys: String, CodingKey {
        case containsCaptcha = "ContainsCaptcha"
        case content = "Content"
        case data = "Data"
        case isSuccess = "IsSuccess"
        case title = "Title"
        case type = "Type"
        case refreshTopBar, trackingCodeJS
    }
}

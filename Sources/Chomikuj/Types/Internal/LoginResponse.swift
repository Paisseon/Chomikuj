struct LoginResponse: Decodable {
    let data: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

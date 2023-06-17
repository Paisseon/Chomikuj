import Foundation

public struct Chomik {
    public let name: String
    public var cookie: String = ""
    public private(set) var folders: [Folder] = []
    public private(set) var token: String = ""
    public private(set) var ticks: String = ""
    public private(set) var isLoggedIn: Bool = false
    
    public init(name: String) {
        self.name = name
    }
    
    // Login to this hamster
    
    public mutating func login(password: String) async throws {
        let url: URL = .init(string: ChomikAPI.login.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "Login=\(self.name)&Password=\(password)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: LoginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        guard response.data["Status"] == 0 else {
            throw "Login failed for account \(name)"
        }
        
        self.isLoggedIn = true
    }
    
    // Populate the folder array for this hamster
    
    public mutating func mapFolders(in id: Int = 0) async throws {
        let url: URL = .init(string: ChomikAPI.folders.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "chomikName=\(self.name)&folderId=\(id)&ticks=\(self.ticks)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        guard let data: Data = try? await request.send() else {
            throw "Couldn't map folders for \(name)"
        }
        
        let html: String = .init(decoding: data, as: UTF8.self)
        
        let pathRegex: NSRegularExpression = try .init(pattern: #"(?<=href=\\\")([^\"]*)(?=\\\")"#)
        let uuidRegex: NSRegularExpression = try .init(pattern: #"(?<=rel=\\\")(\d*)(?=\\\")"#)
        let nameRegex: NSRegularExpression = try .init(pattern: #"(?<=title=\\\")([^\"]*)(?=\\\" id)"#)
        
        let pathMatch: [NSTextCheckingResult] = pathRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let uuidMatch: [NSTextCheckingResult] = uuidRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let nameMatch: [NSTextCheckingResult] = nameRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        
        let filePaths: [String] = pathMatch.map { String(html[Range($0.range, in: html)!]) }
        let fileUUIDs: [Int] = uuidMatch.map { Int(String(html[Range($0.range, in: html)!])) ?? -1 }
        let fileNames: [String] = nameMatch.map { String(html[Range($0.range, in: html)!]) }
        
        self.folders = Array(0 ..< min(fileUUIDs.count, fileNames.count, filePaths.count)).map {
            Folder(
                id: fileUUIDs[$0],
                name: fileNames[$0],
                path: filePaths[$0]
            )
        }
    }
    
    // Get the verification token and folder ticks. Idk what the latter is, but it's required to map folders
    
    public mutating func tikTok() async throws {
        let url: URL = .init(string: ChomikAPI.base.rawValue + name)!
        let data: Data? = try? await URLSession.shared.data(from: url).0
        let html: String = .init(decoding: data ?? Data(), as: UTF8.self)
        
        let tikRegex: NSRegularExpression = try .init(pattern: #"(?<=type=\"hidden\" name=\"TreeTicks\" value=\")(.*)(?=\")"#)
        let tokRegex: NSRegularExpression = try .init(pattern: #"(?<=RequestVerificationToken\" type=\"hidden\" value\=\")(.*)(?=\")"#)
        
        let tikMatch: [NSTextCheckingResult] = tikRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let tokMatch: [NSTextCheckingResult] = tokRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        
        guard let retTik: NSTextCheckingResult = tikMatch.last,
              let retTok: NSTextCheckingResult = tokMatch.last
        else {
            throw "Couldn't find tick or token"
        }
        
        self.ticks = String(html[Range(retTik.range, in: html)!])
        self.token = String(html[Range(retTok.range, in: html)!]).urlEncoded()
    }
}

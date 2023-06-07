import Foundation

public struct Downloader {
    public static func download(
        _ file: File,
        as chomik: Chomik
    ) async throws -> URL {
        let url: URL = .init(string: ChomikAPI.download.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "fileId=\(file.id)&__RequestVerificationToken=\(chomik.token)".data(using: .utf8)!
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: DownloadResponse = try JSONDecoder().decode(DownloadResponse.self, from: data)
        
        return try await URLRequest(url: response.redirectURL).download()
    }
}

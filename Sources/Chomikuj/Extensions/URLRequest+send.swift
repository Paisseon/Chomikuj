import Foundation

extension URLRequest {
    func send() async throws -> Data {
        if #available(iOS 15.0, macOS 12.0, *) {
            return try await URLSession.shared.data(for: self).0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: self) { data, _, error in
                if let data { continuation.resume(returning: data) }
                if let error { continuation.resume(throwing: error) }
            }
            
            task.resume()
        }
    }
    
    func download() async throws -> URL {
        if #available(iOS 15.0, macOS 12.0, *) {
            return try await URLSession.shared.download(for: self).0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: self) { url, _, error in
                if let url { continuation.resume(returning: url) }
                if let error { continuation.resume(throwing: error) }
            }
            
            task.resume()
        }
    }
}

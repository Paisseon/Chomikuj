import Foundation

extension URLRequest {
    func send(throwing errMsg: String = "Request failed") async throws -> Data {
        if #available(iOS 15.0, macOS 12.0, *) {
            let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: self)
            if (response as? HTTPURLResponse)?.statusCode != 200 { throw errMsg }
            
            return data
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: self) { data, response, error in
                if (response as? HTTPURLResponse)?.statusCode != 200 { continuation.resume(throwing: errMsg) }
                if let data { continuation.resume(returning: data) }
                if let error { continuation.resume(throwing: error) }
            }
            
            task.resume()
        }
    }
    
    func download(throwing errMsg: String = "Download failed") async throws -> URL {
        if #available(iOS 15.0, macOS 12.0, *) {
            let (url, response): (URL, URLResponse) = try await URLSession.shared.download(for: self)
            if (response as? HTTPURLResponse)?.statusCode != 200 { throw errMsg }
            
            return url
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: self) { url, response, error in
                if (response as? HTTPURLResponse)?.statusCode != 200 { continuation.resume(throwing: errMsg) }
                if let url { continuation.resume(returning: url) }
                if let error { continuation.resume(throwing: error) }
            }
            
            task.resume()
        }
    }
}

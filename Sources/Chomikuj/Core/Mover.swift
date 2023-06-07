import Foundation

public struct Mover {
    public static func copy(
        _ file: File,
        from src: Folder,
        to dst: Folder,
        chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't move a file"
        }
        
        let url: URL = .init(string: ChomikAPI.copy.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FileId=\(file.id)&FolderId=\(src.id)&FolderTo=\(dst.id)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: ActionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
        
        guard response.isSuccess else {
            throw "Failed to copy \(file.name) (\(file.id)) to \(dst.name) (\(dst.id))"
        }
    }
    
    public static func move(
        _ file: File,
        from src: Folder,
        to dst: Folder,
        chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't move a file"
        }
        
        let url: URL = .init(string: ChomikAPI.move.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FileId=\(file.id)&FolderId=\(src.id)&FolderTo=\(dst.id)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: ActionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
        
        guard response.isSuccess else {
            throw "Failed to move \(file.name) (\(file.id)) to \(dst.name) (\(dst.id))"
        }
    }
    
    public static func rename(
        _ file: File,
        newName: String,
        newDesc: String,
        chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't rename a file"
        }
        
        let url: URL = .init(string: ChomikAPI.move.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "FileId=\(file.id)&Name=\(newName)&Description=\(newDesc)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: ActionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
        
        guard response.isSuccess else {
            throw "Failed to move \(file.name) (\(file.id)) to \(newName)"
        }
    }
}

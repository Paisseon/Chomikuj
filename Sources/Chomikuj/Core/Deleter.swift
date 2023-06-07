import Foundation

public struct Deleter {
    public static func deleteFile(
        _ file: File,
        from folder: Folder,
        as chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't delete a file"
        }
        
        let url: URL = .init(string: ChomikAPI.delete.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FolderId=\(folder.id)&FileId=\(file.id)&FolderTo=0&__RequestVerificationToken=\(chomik.token)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue(folder.path, forHTTPHeaderField: "Referer")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: ActionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
        
        guard response.isSuccess else {
            throw "Failed to delete \(file.name) (\(file.id))"
        }
    }
    
    public static func deleteFolder(
        _ folder: Folder,
        from chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't delete a folder"
        }
        
        let url: URL = .init(string: ChomikAPI.deleteFolder.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FolderId=\(folder.id)&__RequestVerificationToken=\(chomik.token)".data(using: .utf8)
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: ActionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
        
        guard response.isSuccess else {
            throw "Failed to delete \(folder.name) (\(folder.id))"
        }
    }
}

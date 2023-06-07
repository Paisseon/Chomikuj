import Foundation

public struct Uploader {
    public static func upload(
        _ data: Data,
        as fileName: String,
        to folder: Folder,
        in chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't upload a file"
        }
        
        let url: URL = try await getUploadURL(for: folder, chomik: chomik)
        let mpData: Data = try getMultipart(from: data, fileName: fileName)
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = mpData
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue(ChomikAPI.base.rawValue + folder.path, forHTTPHeaderField: "Referer")
        request.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=----WebKitFormBoundary13bNeybuFGg8rkAB", forHTTPHeaderField: "Content-Type")
        
        _ = try await request.send()
    }
    
    public static func newFolder(
        _ name: String,
        in parent: Folder,
        chomik: Chomik
    ) async throws {
        guard chomik.isLoggedIn else {
            throw "Guest hamsters can't create a folder"
        }
        
        let url: URL = .init(string: ChomikAPI.newFolder.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FolderName=\(name)&FolderId=\(parent.id)&AdultContent=false&NewFolderSetPassword=false&__RequestVerificationToken=\(chomik.token)".data(using: .utf8)
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        _ = try await request.send()
    }
    
    private static func getMultipart(
        from data: Data,
        fileName: String
    ) throws -> Data {
        var body: Data = .init()
        
        body.append("------WebKitFormBoundary13bNeybuFGg8rkAB\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \"application/octet-stream\"\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("------WebKitFormBoundary13bNeybuFGg8rkAB--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private static func getUploadURL(
        for folder: Folder,
        chomik: Chomik
    ) async throws -> URL {
        let url: URL = .init(string: ChomikAPI.upload.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "accountname=\(chomik.name)&folderid=\(folder.id)&__RequestVerificationToken=\(chomik.token)".data(using: .utf8)
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let data: Data = try await request.send()
        let response: UploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
        
        return response.url
    }
}

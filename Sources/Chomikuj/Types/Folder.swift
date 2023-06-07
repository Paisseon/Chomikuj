import Foundation

public struct Folder: Comparable, Hashable {
    public let id: Int
    public let name: String
    public let path: String
    public var files: [Int: [File]] = [:]
    
    public init(id: Int, name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
    
    // Populate the files dictionary for a given page
    
    public mutating func getFiles(
        fromPage pageNumber: Int,
        for chomik: Chomik
    ) async throws {
        let page: Page = await .init(pageNumber, in: self, chomik: chomik)
        let pgFiles: [File] = try page.files()
        files[pageNumber] = pgFiles
    }
    
    // Redirect to the last page and read its number
    
    public func pageCount(for chomik: Chomik) async throws -> Int {
        let url: URL = .init(string: ChomikAPI.files.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FolderId=\(id)&PageNr=999".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue(ChomikAPI.base.rawValue + path, forHTTPHeaderField: "Referer")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")

        let data: Data = try await request.send()
        let str: String = .init(decoding: data, as: UTF8.self)
        
        guard let range: Range<String.Index> = str.range(of: #"(?<=Strona )\d{1,3}"#, options: .regularExpression),
              let maxPage: Int = .init(str[range])
        else {
            return 0
        }
        
        return maxPage
    }
    
    public static func < (lhs: Folder, rhs: Folder) -> Bool { lhs.id < rhs.id }
    public static func == (lhs: Folder, rhs: Folder) -> Bool { lhs.id == rhs.id }
}

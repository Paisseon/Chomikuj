import Foundation

public struct Searcher {
    public static func search(
        for name: String,
        in chomik: Chomik,
        pageNumber index: Int = 1
    ) async throws -> [File] {
        let page: Page = await .init(index, search: name, chomik: chomik)
        let pgFiles: [File] = try page.files()
        
        return pgFiles
    }
}

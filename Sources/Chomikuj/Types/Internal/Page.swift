import Foundation

struct Page {
    private let html: String
    
    // Init for getting pages in a folder
    
    init(
        _ index: Int,
        in folder: Folder,
        chomik: Chomik
    ) async {
        let url: URL = .init(string: ChomikAPI.base.rawValue + folder.path)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=\(chomik.name)&FolderId=\(folder.id)&PageNr=\(index)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue(folder.path, forHTTPHeaderField: "Referer")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        if !chomik.cookie.isEmpty {
            request.setValue(chomik.cookie, forHTTPHeaderField: "Cookie")
        }
        
        html = String(decoding: (try? await request.send()) ?? Data(), as: UTF8.self)
    }
    
    // Init for getting pages from search results
    
    init(
        _ index: Int,
        search: String,
        chomik: Chomik
    ) async {
        let url: URL = .init(string: ChomikAPI.search.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "FileName=\(search)&IsGallery=0&Page=\(index)&SearchOnAccount=true&TargetAccountName=\(chomik.name)".data(using: .utf8)
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        html = String(decoding: (try? await request.send()) ?? Data(), as: UTF8.self)
    }
    
    // Actually retrieve the files from HTML with lots of regex
    
    func files() throws -> [File] {
        let uuidRegex: NSRegularExpression = try .init(pattern: #"(?<=visibleButtons  fileIdContainer\" rel=\")\d{10}"#)
        let dateRegex: NSRegularExpression = try .init(pattern: #"\d{1,2} [acegijklmprstuwyzź]{3} \d{2} \d{1,2}:\d{1,2}"#)
        let nameRegex: NSRegularExpression = try .init(pattern: #"(?<=title=\")[^\=]*(?=\" data)"#)
        let sizeRegex: NSRegularExpression = try .init(pattern: #"\d{1,3},?\d?\s(GB|KB|MB)"#)
        
        let uuidMatch: [NSTextCheckingResult] = uuidRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let dateMatch: [NSTextCheckingResult] = dateRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let nameMatch: [NSTextCheckingResult] = nameRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let sizeMatch: [NSTextCheckingResult] = sizeRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        
        let fileUUIDs: [Int]    = uuidMatch.map { Int(String(html[Range($0.range, in: html)!])) ?? -1 }
        let fileDates: [UInt64] = dateMatch.map { fileDate(from: String(html[Range($0.range, in: html)!])) }
        let fileNames: [String] = nameMatch.map { String(html[Range($0.range, in: html)!]) }
        let fileSizes: [UInt64] = sizeMatch.map { fileBytes(from: String(html[Range($0.range, in: html)!])) }
        
        return Array(0 ..< min(fileDates.count, fileNames.count, fileSizes.count)).map {
            File(
                id: fileUUIDs[$0],
                name: fileNames[$0],
                size: fileSizes[$0],
                date: fileDates[$0]
            )
        }
    }
    
    // Convert the text label of the size into numeric byte count
    
    private func fileBytes(from str: String) -> UInt64 {
        let components: [String] = str.replacingOccurrences(of: ",", with: ".").components(separatedBy: " ")
        let size: Double = .init(components[0]) ?? 0
        
        switch components[1] {
            case "KB":
                return UInt64(size * 0x400)
            case "MB":
                return UInt64(size * 0x400 * 0x400)
            case "GB":
                return UInt64(size * 0x400 * 0x400 * 0x400)
            default:
                return UInt64(size)
        }
    }
    
    // Convert the Polish date into numeric UNIX time
    
    private func fileDate(from str: String) -> UInt64 {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd MMM yy HH:mm"
        formatter.locale = .init(identifier: "pl_PL")
        
        guard let date: Date = formatter.date(from: str) else {
            return 0
        }
        
        return UInt64(date.timeIntervalSince1970)
    }
}

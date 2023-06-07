import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
    func urlEncoded() -> String { self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self }
}

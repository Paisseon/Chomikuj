public struct File: Comparable, Hashable {
    public let id: Int
    public let name: String
    public let size: UInt64
    public let date: UInt64
    
    public static func < (lhs: File, rhs: File) -> Bool { lhs.id < lhs.id }
    public static func == (lhs: File, rhs: File) -> Bool { lhs.id == rhs.id }
}

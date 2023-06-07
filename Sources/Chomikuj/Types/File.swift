public struct File: Comparable, Hashable {
    public let id: Int
    public let name: String
    public let size: UInt64
    public let date: UInt64
    
    public init(id: Int, name: String, size: UInt64, date: UInt64) {
        self.id = id
        self.name = name
        self.size = size
        self.date = date
    }
    
    public static func < (lhs: File, rhs: File) -> Bool { lhs.id < lhs.id }
    public static func == (lhs: File, rhs: File) -> Bool { lhs.id == rhs.id }
}

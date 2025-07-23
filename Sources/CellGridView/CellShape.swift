public enum CellShape: String, CaseIterable, Identifiable, Sendable
{
    case square  = "Square"
    case rounded = "Rounded"
    case circle  = "Circle"
    public var id: String { self.rawValue }
}

import Foundation

// Represents an integer based cell-based (i.e. cell-indexed) location within the cell-grid.
// Exactly the same implementation as ViewPoint and ViewLocation; differential naming as documentation.
// TODO: Maybe rename to GridLocation (to match the new ViewLocation).
//
public struct CellLocation: Hashable
{
    public let x: Int
    public let y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public init(_ point: CGPoint) {
        self.x = Int(round(point.x))
        self.y = Int(round(point.y))
    }

    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = Int(round(x))
        self.y = Int(round(y))
    }

    public var description: String {
        String(format: "[%d, %d]", self.x, self.y)
    }
}

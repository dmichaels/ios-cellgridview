import Foundation

// Represents an integer based point or location within the cell-grid or grid-view.
// See CellLocation, ViewLocation, and ViewPoint.
//
public struct GenericPoint: Hashable
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

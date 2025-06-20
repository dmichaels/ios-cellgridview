import Foundation

// Represents an integer based cell-based (i.e. cell-indexed) location within the grid-view.
// Note that his grid-view location (not "point" - see ViewPoint) in practice is always
// starts at (index) zero on the left/top, and contines to the right/bottom to the
// index of the maximum number of cells able to be of displayed in the grid-view.
// Exactly the same implementation as ViewPoint & CellLocation; differential naming as documentation.
//
public struct ViewLocation: Hashable
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

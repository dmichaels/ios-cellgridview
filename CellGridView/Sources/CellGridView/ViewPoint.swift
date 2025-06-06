import Foundation

// Represents an integer based point within the grid-view.
// Exactly the same implementation as CellLocation; differential naming as documentation.
// Note that we say "point" here, not "location", meaning the pixel-based coordinate
// within the grid-view; see notes on terminology at the top of the CellGridView module.
//
public struct ViewPoint
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

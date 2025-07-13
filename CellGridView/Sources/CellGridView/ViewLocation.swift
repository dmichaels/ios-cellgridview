import Foundation

// Represents an integer based cell-based (i.e. cell-indexed) location within the grid-view.
// Note that his grid-view location (not "point" - see ViewPoint) in practice is always
// starts at (index) zero on the left/top, and contines to the right/bottom to the
// index of the maximum number of cells able to be of displayed in the grid-view.
// Exactly the same implementation as ViewPoint & CellLocation; differential naming as documentation.
//
// Note on terminology: We say "cell-grid" to mean the virtual grid of all cells in existence, and "grid-view"
// to mean the viewable window (image) within which is displayed a subset of the currently viewable cell-grid.
// We say "view-point" or "point" to mean a pixel-based coordinate (e.g. from a gesture; unscaled) within the
// grid-view. We say "cell-location" to mean a cell-based (i.e. cell indexed) coordinate on the cell-grid. We
// say "view-location" to mean a cell-based coordinate on the grid-view (always zero-based). We say "location"
// generically to refer to a cell-location or a view-location, as opposed to "point" referring a view-point.
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

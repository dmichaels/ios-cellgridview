import Foundation

// Represents an integer based cell-based (i.e. cell-indexed) location within the (visible) grid-view.
// Exactly the same implementation as ViewPoint & CellLocation; differential naming as documentation.
//
// Note that this grid-view location (not "point" - see ViewPoint) always starts at (index) zero, the left/top,
// and continues to the right/bottom to the index of the maximum cells able to be of displayed in the grid-view.
//
// Note on terminology: We say "cell-grid" to mean the virtual grid of all cells in existence, and "grid-view"
// to mean the viewable window (image) within which is displayed a subset of the currently viewable cell-grid.
// We say "view-point" or "point" to mean a pixel-based coordinate (e.g. from a gesture; unscaled) within the
// grid-view. We say "cell-location" to mean a cell-based (i.e. cell indexed) coordinate on the cell-grid. We
// say "view-location" to mean a cell-based coordinate on the grid-view (always zero-based). We say "location"
// generically to refer to a cell-location or a view-location, as opposed to "point" referring a view-point.
//
public typealias ViewLocation = GenericPoint

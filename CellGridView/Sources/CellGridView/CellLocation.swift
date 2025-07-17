import Foundation

// Represents an integer based cell-based (i.e. cell-indexed) location within the entire cell-grid.
// Exactly the same implementation as ViewPoint & ViewLocation; differential naming as documentation.
//
// Note on terminology: We say "cell-grid" to mean the virtual grid of all cells in existence, and "grid-view"
// to mean the viewable window (image) within which is displayed a subset of the currently viewable cell-grid.
// We say "view-point" or "point" to mean a pixel-based coordinate (e.g. from a gesture; unscaled) within the
// grid-view. We say "cell-location" to mean a cell-based (i.e. cell indexed) coordinate on the cell-grid. We
// say "view-location" to mean a cell-based coordinate on the grid-view (always zero-based). We say "location"
// generically to refer to a cell-location or a view-location, as opposed to "point" referring a view-point.
//
// TODO: Maybe rename to GridLocation (to match the new ViewLocation).
//
public typealias CellLocation = GenericPoint

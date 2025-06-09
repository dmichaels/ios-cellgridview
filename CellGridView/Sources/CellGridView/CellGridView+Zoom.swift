import Foundation
import Utils

// TODO
// Rearranged some stuff 2025-06-09; need to retest specifically the scale/unscale functions.

extension CellGridView
{
    internal struct Zoom
    {
        internal struct Defaults {
            internal static let viewAnchorFactor: Double = 0.5
        }

        private let _cellGridView: CellGridView
        private let _startCellSize: Int
        private let _startShiftedX: Int
        private let _startShiftedY: Int
        private let _unscaledZoom: Bool

        internal init(_ cellGridView: CellGridView, _ zoomFactor: CGFloat) {

            self._unscaledZoom = CellGridView.Defaults.unscaledZoom && cellGridView.viewScaling
            if (self._unscaledZoom) {
                cellGridView.viewScaling = false
            }

            self._cellGridView = cellGridView
            self._startCellSize = cellGridView.cellSizeScaled
            self._startShiftedX = cellGridView.shiftTotalScaledX
            self._startShiftedY = cellGridView.shiftTotalScaledY
            self.zoom(zoomFactor)
        }

        internal func zoom(_ zoomFactor: CGFloat) {
            let cellSizeZoomed: CGFloat = CGFloat(self._startCellSize) * zoomFactor
            let cellSize: Int = Int(cellSizeZoomed.rounded(FloatingPointRoundingRule.toNearestOrEven))
            self._cellGridView.resizeCells(cellSize: cellSize, adjustShift: true, scaled: true)
        }

        internal func end(_ zoomFactor: CGFloat) {
            self.zoom(zoomFactor)
            if (self._unscaledZoom) {
                self._cellGridView.viewScaling = true
            }
        }
    }

    public func resizeCells(cellSize: Int, adjustShift: Bool = true,  scaled: Bool = false)
    {
        let cellSize: Int = self.constrainCellSize(!scaled ?  self.scaled(cellSize) : cellSize, scaled: true)

        guard cellSize != self.cellSizeScaled else { return }

        // If the given adjustShift is true, then we need to calculate the new shift values here BEFORE the
        // re-configure below, whether the resize takes or not due to reaching the maximum allowed cell size,
        // because they both cases depend on the cell size which is updated by this re-configure below.

        var shift = adjustShift ? CellGridView.shiftForResizeCells(cellSize: self.cellSizeScaled,
                                                                   cellSizeIncrement: cellSize - self.cellSizeScaled,
                                                                   viewWidth: self.viewWidthScaled,
                                                                   viewHeight: self.viewHeightScaled,
                                                                   shiftTotalX: self.shiftTotalScaledX,
                                                                   shiftTotalY: self.shiftTotalScaledY,
                                                                   viewAnchorFactor: Zoom.Defaults.viewAnchorFactor)
                                : (x: self.shiftTotalScaledX, y: self.shiftTotalScaledY)

        self.configure(cellSize: cellSize,
                       cellPadding: self.cellPaddingScaled,
                       cellShape: self.cellShape,
                       viewWidth: self.viewWidthScaled,
                       viewHeight: self.viewHeightScaled,
                       viewBackground: self.viewBackground,
                       viewTransparency: self.viewTransparency,
                       viewScaling: self.viewScaling,
                       scaled: true)

        self.writeCells(shiftTotalX: shift.x, shiftTotalY: shift.y, scaled: true)
    }

    public func scale(_ scaling: Bool) {
        guard self.viewScaling != scaling else { return }
        let shiftTotalX: Int = scaling ? self.screen.scaled(self.shiftTotalX) : self.screen.unscaled(self.shiftTotalX)
        let shiftTotalY: Int = scaling ? self.screen.scaled(self.shiftTotalY) : self.screen.unscaled(self.shiftTotalY)
        self.configure(cellSize: self.cellSize,
                       cellPadding: self.cellPadding,
                       cellShape: self.cellShape,
                       viewWidth: self.viewWidth,
                       viewHeight: self.viewHeight,
                       viewBackground: self.viewBackground,
                       viewTransparency: self.viewTransparency,
                       viewScaling: scaling)
        self.writeCells(shiftTotalX: shiftTotalX, shiftTotalY: shiftTotalY, scaled: scaling)
    }

    public func scale() { self.scale(true) }
    public func unscale() { self.scale(false) }

    private static func shiftForResizeCells(cellSize: Int,
                                            cellSizeIncrement: Int,
                                            viewWidth: Int,
                                            viewHeight: Int,
                                            shiftTotalX: Int,
                                            shiftTotalY: Int,
                                            viewAnchorFactor: Double = 0.5) -> (x: Int, y: Int) {
        guard cellSizeIncrement != 0 else { return (x: 0, y: 0) }
        let shiftTotalAdjustedX: Int = CellGridView.adjustShiftTotal(viewSize: viewWidth,
                                                        cellSize: cellSize,
                                                        cellSizeIncrement: cellSizeIncrement,
                                                        shiftTotal: shiftTotalX,
                                                        viewAnchorFactor: viewAnchorFactor)
        let shiftTotalAdjustedY: Int = CellGridView.adjustShiftTotal(viewSize: viewHeight,
                                                        cellSize: cellSize,
                                                        cellSizeIncrement: cellSizeIncrement,
                                                        shiftTotal: shiftTotalY,
                                                        viewAnchorFactor: viewAnchorFactor)
        return (x: shiftTotalAdjustedX, y: shiftTotalAdjustedY)
    }

    // Returns the adjusted total shift value for the given view size (width or height), cell size and the amount
    // it is being incremented by, and the current total shift value, so that the cells within the view remain
    // centered (where they were at the current/given cell size and shift total values) after the cell size has
    // been adjusted by the given increment; this is the default behavior, but if a given view anchor factor is
    // specified, then the "center" of the view is taken to be the given view size times this given view anchor
    // factor (this is 0.5 by default giving the default centered behavior). This is only for handling zooming.
    //
    // This is tricky. Turns out it is literally impossible to compute this accurately for increments or more
    // than one without actually going through iteratively and computing the result one increment at a time,
    // due to the cummulative effects of rounding. Another possible solution is to define this function as
    // working properly only for increments of one, and when zooming if this function would otherwise be called
    // with increments greater than one, then manually manufacture zoom "events" for the intermediate steps,
    // i.e. call the resizeCells function iteratively; if we were worried about performance with this iteratively
    // looping solution here, that alternate solution would should be orders of magnitude less performant, but
    // the result might (might) look even smoother, or it could just make things seem slower and sluggish.
    //
    // Ask ChatGPT to explain further if you want to understand more about why this kind of problem requires
    // an iterative solution and cannot be computed directly in one go; it refers to this problem as any of:
    //
    // - Iterative Process Recurrence Relation:
    //   Where each output is a function of the previous step.
    // - Nonlinear Recurrence with Discretization:
    //   Where rounding/floor/ceil is a nonlinear, discontinuous transformation.
    // - Nonassociative Arithmetic:
    //   Where combining steps cannot be merged into a single step due to the transformation applied at each.
    // - Path Dependence:
    //   In economics and computation, where this means that the result depends on the sequence of steps taken.
    //
    private static func adjustShiftTotal(viewSize: Int, cellSize: Int, cellSizeIncrement: Int, shiftTotal: Int,
                                         viewAnchorFactor: Double = 0.5) -> Int {
        let viewCenter: Double = Double(viewSize) * viewAnchorFactor
        var cellSizeResult: Int = cellSize
        var shiftTotalResult: Int = shiftTotal
        let increment: Int = cellSizeIncrement > 0 ? 1 : -1
        for _ in 0..<abs(cellSizeIncrement) {
            let viewCenterAdjusted: Double = viewCenter - Double(shiftTotalResult)
            let shiftDelta: Double = (viewCenterAdjusted * Double(increment)) / Double(cellSizeResult)
            cellSizeResult += increment
            shiftTotalResult = Int(((cellSizeResult % 2 == 0) ? ceil : floor)(Double(shiftTotalResult) - shiftDelta))
        }
        return shiftTotalResult
    }
}

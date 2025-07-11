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

            self._unscaledZoom = cellGridView.unscaledZoom && cellGridView.viewScaling
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
            self._cellGridView.resizeCells(cellSize: cellSize, adjustShiftOnResizeCells: true, scaled: true)
        }

        internal func end(_ zoomFactor: CGFloat) {
            //
            // TODO
            // It is possible that the onEnded event for the MagnificationGesture,
            // e.g. from Utils.SmartGesture, will not be called as expected; not clear
            // how to handle this; the only negative impact is if we are using unscaledZoom.
            //
            self.zoom(zoomFactor)
            if (self._unscaledZoom) {
                self._cellGridView.viewScaling = true
            }
        }
    }

    public func resizeCells(cellSize: Int, adjustShiftOnResizeCells: Bool = true,  scaled: Bool = false)
    {
        let cellSize: Int = self.constrainCellSize(!scaled ? self.scaled(cellSize) : cellSize, scaled: true)

        guard cellSize != self.cellSizeScaled else { return }

        // Remember that CellGridView.Config is agnostic about its property values being scaled or not.
        // Though (TODO) we could make it cognizant of this; might (or might not) make a littler clearer. 
        //
        self.configure(self.config.update(cellSize: cellSize,
                                          cellPadding: self.cellPaddingScaled),
                                          viewWidth: self.viewWidthScaled,
                                          viewHeight: self.viewHeightScaled,
                                          adjust: true,
                                          scaled: true)
    }

    public func scale(_ scaling: Bool) {
        guard self.viewScaling != scaling else { return }
        let shiftTotalX: Int = scaling ? self.screen.scaled(self.shiftTotalX) : self.screen.unscaled(self.shiftTotalX)
        let shiftTotalY: Int = scaling ? self.screen.scaled(self.shiftTotalY) : self.screen.unscaled(self.shiftTotalY)
        //
        // Remember that CellGridView.Config is agnostic about its property values being scaled or not.
        // Though (TODO) we could make it cognizant of this; might (or might not) make a little clearer. 
        //
        self.configure(self.config.update(viewScaling: scaling),
                       viewWidth: self.viewWidth,
                       viewHeight: self.viewHeight,
                       adjust: false,
                       scaled: false)
        self.shift(shiftTotalX: shiftTotalX, shiftTotalY: shiftTotalY, scaled: scaling)
    }

    public func scale() { self.scale(true) }
    public func unscale() { self.scale(false) }

    internal func shiftForResizeCells(cellSizeIncrement: Int) -> (x: Int, y: Int)
    {
        return CellGridView.shiftForResizeCells(cellSize: self.cellSizeScaled,
                                                cellSizeIncrement: cellSizeIncrement,
                                                viewWidth: self.viewWidthScaled,
                                                viewHeight: self.viewHeightScaled,
                                                shiftTotalX: self.shiftTotalScaledX,
                                                shiftTotalY: self.shiftTotalScaledY,
                                                viewAnchorFactor: Zoom.Defaults.viewAnchorFactor)
    }

    private static func shiftForResizeCells(cellSize: Int,
                                            cellSizeIncrement: Int,
                                            viewWidth: Int,
                                            viewHeight: Int,
                                            shiftTotalX: Int,
                                            shiftTotalY: Int,
                                            viewAnchorFactor: Double = 0.5) -> (x: Int, y: Int) {
        guard cellSizeIncrement != 0 else { return (x: 0, y: 0) }
        let shiftTotalX: Int = CellGridView.adjustShiftTotal(viewSize: viewWidth,
                                                             cellSize: cellSize,
                                                             cellSizeIncrement: cellSizeIncrement,
                                                             shiftTotal: shiftTotalX,
                                                             viewAnchorFactor: viewAnchorFactor)
        let shiftTotalY: Int = CellGridView.adjustShiftTotal(viewSize: viewHeight,
                                                             cellSize: cellSize,
                                                             cellSizeIncrement: cellSizeIncrement,
                                                             shiftTotal: shiftTotalY,
                                                             viewAnchorFactor: viewAnchorFactor)
        return (x: shiftTotalX, y: shiftTotalY)
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
    // i.e. call the resizeCells function iteratively; if were worried about performance with such an iterative
    // looping solution here, that alternate solution would surely be orders of magnitude less performant, but
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

    // Returns the total shift values to center the cell-grid within the grid-view, for the given cell-size,
    // or the current cell-grid-view cell-size if the given cell-size is not specified; the given cell-size
    // if given is assumed to be the scaled value; and the returned shift values are also thus scaled.
    //
    internal func shiftForCenterCells(cellSize: Int? = nil,
                                      gridColumns: Int? = nil,
                                      gridRows: Int? = nil,
                                      viewWidth: Int? = nil,
                                      viewHeight: Int? = nil,
                                      fit: CellGridView.Fit = CellGridView.Fit.disabled) -> (x: Int, y: Int)
    {
        let cellSize: Int = cellSize ?? self.cellSizeScaled
        let gridColumns: Int = gridColumns ?? self.gridColumns
        let gridRows: Int = gridRows ?? self.gridRows
        let viewWidth: Int = viewWidth ?? self.viewWidthScaled
        let viewHeight: Int = viewHeight ?? self.viewHeightScaled
        let gridWidth: Int = gridColumns * cellSize
        let gridHeight: Int = gridRows * cellSize
        var shiftTotalX: Int = -Int(round(Double(gridWidth - viewWidth) / 2.0))
        var shiftTotalY: Int = -Int(round(Double(gridHeight - viewHeight) / 2.0))
        if (fit != CellGridView.Fit.disabled) {
            shiftTotalX -= shiftTotalX % cellSize
            shiftTotalY -= shiftTotalY % cellSize
        }
        return (x: shiftTotalX, y: shiftTotalY)
    }
}

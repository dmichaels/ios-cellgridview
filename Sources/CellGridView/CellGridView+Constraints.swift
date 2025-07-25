extension CellGridView
{
    public enum Fit: String, CaseIterable, Identifiable, Sendable
    {
        case disabled = "disabled"  // no cell/view fitting attempt
        case enabled  = "enabled"   // try to fit cell and/or view size
        case view     = "view"      // try to fit view (but not cell) size
        case fixed    = "fixed"     // same as enabled but also limit number of cell to fit view
        case square   = "square"    // same as fixed but square
        public var fixed: Bool { self == .fixed || self == .square }
        public var id: String { self.rawValue }
    }

    public typealias PreferredSize = (cellSize: Int, viewWidth: Int, viewHeight: Int, fit: Bool)

    public func preferredSize(_ cellSize: Int, fit: CellGridView.Fit, scaled: Bool = false) -> PreferredSize
    {
        let cellSize: Int = !scaled ? self.scaled(cellSize) : cellSize
        let preferred: PreferredSize = CellGridView.preferredSize(cellSize: cellSize,
                                                                  viewWidth: self.scaled(self.screen.width),
                                                                  viewHeight: self.scaled(self.screen.height),
                                                                  fit: fit,
                                                                  fitMarginMax: CellGridView.Defaults.fitMarginMax)
        return scaled ? preferred : (cellSize: self.unscaled(preferred.cellSize),
                                     viewWidth: self.unscaled(preferred.viewWidth),
                                     viewHeight: self.unscaled(preferred.viewHeight),
                                     fit: preferred.fit)
    }

    internal static func preferredSize
    (
        cellSize: Int,
        viewWidth: Int,
        viewHeight: Int,
        fit: CellGridView.Fit = CellGridView.Fit.disabled,
        fitMarginMax: Int = CellGridView.Defaults.fitMarginMax
    ) -> PreferredSize
    {
        if fit != CellGridView.Fit.disabled,
           let preferred = CellGridView.preferredSize(viewWidth: viewWidth,
                                                      viewHeight: viewHeight,
                                                      cellSize: cellSize,
                                                      fitMarginMax: fitMarginMax) {
            if ((fit == CellGridView.Fit.enabled) ||
                (fit == CellGridView.Fit.fixed) ||
                ((fit == CellGridView.Fit.view) && (preferred.cellSize == cellSize))) {
                return (cellSize: preferred.cellSize, viewWidth: preferred.viewWidth,
                                                      viewHeight: preferred.viewHeight, fit: true)
            }
        }
        return (cellSize: cellSize, viewWidth: viewWidth, viewHeight: viewHeight, fit: false)
    }

    // Returns a list of preferred sizes for the cell size, such that they fit evenly without bleeding
    // out past the end of the view; the given and returned dimensions are assumed to be either scaled
    // or unscaled values, but they are assumed to be consistent with each other; i.e. we are agnostic
    // regarding whether or not the given/returned values are scaled.
    //
    internal static func preferredSize(viewWidth: Int,
                                       viewHeight: Int, cellSize: Int, fitMarginMax: Int) -> PreferredSize?
    {
        let sizes = CellGridView.preferredSizes(viewWidth: viewWidth, viewHeight: viewHeight,
                                                fitMarginMax: fitMarginMax)
        return CellGridView.closestPreferredCellSize(in: sizes, to: cellSize)
    }

    internal static func preferredSizes(viewWidth: Int, viewHeight: Int, fitMarginMax: Int) -> [PreferredSize] {
        let mindim: Int = min(viewWidth, viewHeight)
        guard mindim > 0 else { return [] }
        var results: [PreferredSize] = []
        for cellSize in 1...mindim {
            let ncols: Int = viewWidth / cellSize
            let nrows: Int = viewHeight / cellSize
            let usedw: Int = ncols * cellSize
            let usedh: Int = nrows * cellSize
            let leftx: Int = viewWidth - usedw
            let lefty: Int = viewHeight - usedh
            if ((leftx <= fitMarginMax) && (lefty <= fitMarginMax)) {
                results.append((cellSize: cellSize, viewWidth: usedw, viewHeight: usedh, fit: true))
            }
        }
        return results
    }

    private static func closestPreferredCellSize(in list: [PreferredSize], to target: Int) -> PreferredSize? {
        return list.min(by: {
            let a: Int = abs($0.cellSize - target)
            let b: Int = abs($1.cellSize - target)
            return (a, $0.cellSize) < (b, $1.cellSize)
        })
    }

    internal static func restrictShiftStrict(shiftCell: inout Int,
                                             shift: inout Int,
                                             cellSize: Int,
                                             viewSize: Int,
                                             gridCells: Int,
                                             dragging: Bool = false) {
        var shiftTotal = (shiftCell * cellSize) + shift
        let gridSize: Int = gridCells * cellSize
        if (gridSize < viewSize) {
            //
            // The entire cell-grid being smaller than the grid-view requires
            // slightly difference logic than the presumably more commmon case.
            //
            if ((shift < 0) || (shiftCell < 0)) {
                shiftCell = 0
                shift = 0
            }
            else if (shiftTotal > (viewSize - gridSize)) {
                shiftTotal = (viewSize - gridSize)
                shiftCell = shiftTotal / cellSize
                shift = shiftTotal % cellSize
            }
        }
        else if (!dragging) {
            if ((shift > 0) || (shiftCell > 0)) {
                shift = 0
                shiftCell = 0
            }
            else if ((shift < 0) || (shiftCell < 0)) {
                if ((shiftTotal < 0) && ((gridSize + shiftTotal) < viewSize)) {
                    shiftTotal = viewSize - gridSize
                    shiftCell = shiftTotal / cellSize
                    shift = shiftTotal % cellSize
                }
            }
        }
    }

    internal static func restrictShiftLenient(shiftCell: inout Int,
                                              shift: inout Int,
                                              cellSize: Int,
                                              viewCellEnd: Int,
                                              viewSizeExtra: Int,
                                              viewSize: Int,
                                              gridCells: Int) {
        if (shiftCell >= viewCellEnd) {
            if (viewSizeExtra > 0) {
                let shiftTotal = (shiftCell * cellSize) + shift
                    if ((viewSize - shiftTotal) <= cellSize) {
                let viewSizeAdjusted = viewSize - cellSize
                    shiftCell = viewSizeAdjusted / cellSize
                    shift = viewSizeAdjusted % cellSize
                }
            } else {
                shiftCell = viewCellEnd
                shift = 0
            }
        }
        else if (-shiftCell >= (gridCells - 1)) {
            shiftCell = -(gridCells - 1)
            shift = 0
        }
    }

    public final var minimumCellSize: Int {
        self.minimumCellSize(cellPadding: self.cellPadding)
    }

    public final func minimumCellSize(cellPadding: Int? = nil, cellShape: CellShape? = nil) -> Int {
        let cellPadding: Int = max(0, cellPadding ?? self.cellPadding)
        let minimumCellSize: Int = self.constrainCellSize(Defaults.cellSizeInnerMin, cellPadding: cellPadding, scaled: false)
        if let cellShape: CellShape = cellShape {
            return [CellShape.rounded, CellShape.circle].contains(cellShape) ? max(minimumCellSize, 4) : minimumCellSize
        }
        return minimumCellSize
    }

    public final var maximumCellSize: Int {
        Defaults.cellSizeMax
    }

    public final var minimumCellPadding: Int {
        0
    }

    public final var maximumCellPadding: Int {
        Defaults.cellPaddingMax
    }

    public final var minimumGridColumns: Int {
        Defaults.gridColumnsMin
    }

    public final var maximumGridColumns: Int {
        Defaults.gridColumnsMax
    }

    public final var minimumGridRows: Int {
        Defaults.gridRowsMin
    }

    public final var maximumGridRows: Int {
        Defaults.gridRowsMax
    }

    internal final func constrainCellSize(_ cellSize: Int, cellPadding: Int? = nil,
                                            cellShape: CellShape? = nil, scaled: Bool = false) -> Int {
        let cellSizeInnerMin: Int = self.scaled(Defaults.cellSizeInnerMin)
        let cellSizeMax: Int = self.scaled(Defaults.cellSizeMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding ?? self.cellPadding) : (cellPadding ?? self.cellPaddingScaled)
        let constrainedCellSize: Int = cellSize.clamped(cellSizeInnerMin + (cellPadding * 2)...cellSizeMax)
        if let cellShape: CellShape = cellShape, [CellShape.rounded, CellShape.circle].contains(cellShape) {
            if ((cellSize - cellPadding) < self.scaled(3)) {
                return self.scaled(3)
            }
        }
        return !scaled ? self.unscaled(constrainedCellSize) : constrainedCellSize
    }

    internal final func constrainCellPadding(_ cellPadding: Int, scaled: Bool = false) -> Int {
        let cellPaddingMax: Int = self.scaled(Defaults.cellPaddingMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding) : cellPadding
        let constrainedCellPadding: Int = cellPadding.clamped(0...cellPaddingMax)
        return !scaled ? self.unscaled(constrainedCellPadding) : constrainedCellPadding
    }

    internal final func constrainGridColumns(_ gridColumns: Int) -> Int {
        return gridColumns.clamped(self.minimumGridColumns...self.maximumGridColumns)
    }

    internal final func constrainGridRows(_ gridRows: Int) -> Int {
        return gridRows.clamped(self.minimumGridRows...self.maximumGridRows)
    }

    public func cellShapeRequiresNoScaling(_ cellShape: CellShape) -> Bool {
        return [CellShape.square].contains(cellShape)
    }
}

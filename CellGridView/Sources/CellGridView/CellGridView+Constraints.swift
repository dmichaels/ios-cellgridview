extension CellGridView
{
    public enum PreferredFit: String, CaseIterable, Identifiable, Sendable
    {
        case disable = "disable"
        case enable = "enable"
        case fixed = "fixed"
        case cell = "cell"
        case view  = "view"
        public var id: String { self.rawValue }
    }

    internal typealias PreferredSize = (cellSize: Int, viewWidth: Int, viewHeight: Int)

    internal static func preferredSize
    (
        cellSize: Int,
        viewWidth: Int,
        viewHeight: Int,
        preferredFit: CellGridView.PreferredFit = CellGridView.PreferredFit.cell,
        preferredFitMarginMax: Int = CellGridView.Defaults.preferredFitMarginMax
    ) -> PreferredSize
    {
        if preferredFit != CellGridView.PreferredFit.disable,
           let preferred = CellGridView.preferredSize(viewWidth: viewWidth,
                                                      viewHeight: viewHeight,
                                                      cellSize: cellSize,
                                                      preferredFitMarginMax: preferredFitMarginMax) {
            if ((preferredFit == CellGridView.PreferredFit.enable) ||
                (preferredFit == CellGridView.PreferredFit.fixed) ||
                ((preferredFit == CellGridView.PreferredFit.view) && (preferred.cellSize == cellSize))) {
                return (cellSize: preferred.cellSize, viewWidth: preferred.viewWidth, viewHeight: preferred.viewHeight)
            }
        }
        return (cellSize: cellSize, viewWidth: viewWidth, viewHeight: viewHeight)
    }

    // Returns a list of preferred sizes for the cell size, such that they fit evenly without bleeding
    // out past the end of the view; the given and returned dimensions are assumed to be unscaled values.
    //
    internal static func preferredSize(viewWidth: Int, viewHeight: Int, cellSize: Int, // todo/xyzzy/private
                                       preferredFitMarginMax: Int) -> PreferredSize?
    {
        let sizes = CellGridView.preferredSizes(viewWidth: viewWidth, viewHeight: viewHeight,
                                                preferredFitMarginMax: preferredFitMarginMax)
        return CellGridView.closestPreferredCellSize(in: sizes, to: cellSize)
    }

    internal static func preferredSizes(viewWidth: Int, viewHeight: Int,
                                        preferredFitMarginMax: Int)
                                        -> [PreferredSize] {
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
            if ((leftx <= preferredFitMarginMax) && (lefty <= preferredFitMarginMax)) {
                results.append((cellSize: cellSize, viewWidth: usedw, viewHeight: usedh))
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

    public final func minimumCellSize(cellPadding: Int? = nil) -> Int {
        let cellPadding: Int = max(0, cellPadding ?? self.cellPadding)
        return self.constrainCellSize(Defaults.cellSizeInnerMin, cellPadding: cellPadding, scaled: false)
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
        1
    }

    public final var maximumGridColumns: Int {
        5000 // TODO: configize
    }

    public final var minimumGridRows: Int {
        1
    }

    public final var maximumGridRows: Int {
        5000 // TODO: configize
    }

    internal final func constrainCellSize(_ cellSize: Int, cellPadding: Int? = nil, scaled: Bool = false) -> Int {
        let cellSizeInnerMin: Int = self.scaled(Defaults.cellSizeInnerMin)
        let cellSizeMax: Int = self.scaled(Defaults.cellSizeMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding ?? self.cellPadding) : (cellPadding ?? self.cellPaddingScaled)
        let constrainedCellSize: Int = cellSize.clamped(cellSizeInnerMin + (cellPadding * 2)...cellSizeMax)
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

    internal final func constrainGridRows(_ gridColumns: Int) -> Int {
        return gridRows.clamped(self.minimumGridRows...self.maximumGridRows)
    }
}

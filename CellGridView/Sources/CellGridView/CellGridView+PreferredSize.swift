extension CellGridView
{
    public enum PreferredFit: String, CaseIterable, Identifiable, Sendable
    {
        case none = "none"
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
        if preferredFit != CellGridView.PreferredFit.none,
           let preferred = CellGridView.preferredSize(viewWidth: viewWidth,
                                                      viewHeight: viewHeight,
                                                      cellSize: cellSize,
                                                      preferredFitMarginMax: preferredFitMarginMax) {
            if ((preferredFit != CellGridView.PreferredFit.view) || (preferred.cellSize == cellSize)) {
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
}

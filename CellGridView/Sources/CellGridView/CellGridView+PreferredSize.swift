extension CellGridView
{
    public typealias PreferredSize = (cellSize: Int, viewWidth: Int, viewHeight: Int)

    // Returns a list of preferred sizes for the cell size, such that they fit evenly without bleeding
    // out past the end of the view; the given and returned dimensions are assumed to be unscaled values.
    //
    public static func preferredSize(viewWidth: Int, viewHeight: Int, cellSize: Int,
                                     cellPreferredSizeMarginMax: Int = Defaults.cellPreferredSizeMarginMax,
                                     enabled: Bool = true) -> PreferredSize
    {
        if (enabled) {
            let sizes = CellGridView.preferredSizes(viewWidth: viewWidth, viewHeight: viewHeight,
                                                    cellPreferredSizeMarginMax: cellPreferredSizeMarginMax)
            if let size = CellGridView.closestPreferredCellSize(in: sizes, to: cellSize) {
                return size
            }
        }
        return (cellSize: cellSize, viewWidth: viewWidth, viewHeight: viewHeight)
    }

    public static func preferredSizes(viewWidth: Int, viewHeight: Int,
                                      cellPreferredSizeMarginMax: Int = Defaults.cellPreferredSizeMarginMax)
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
            if ((leftx <= cellPreferredSizeMarginMax) && (lefty <= cellPreferredSizeMarginMax)) {
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

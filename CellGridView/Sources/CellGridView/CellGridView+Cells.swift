import Utils

extension CellGridView {

    internal func defineGridCells(gridColumns: Int, gridRows: Int, foreground: Colour) -> [Cell]
    {
        var gridCells: [Cell] = []
        for y in 0..<gridRows {
            for x in 0..<gridColumns {
                gridCells.append(self.createCell(x: x, y: y, color: foreground) ??
                                 Cell(cellGridView: self, x: x, y: y, color: foreground))
            }
        }
        return gridCells
    }
}

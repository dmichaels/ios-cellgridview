import Utils

extension CellGridView {

    internal func defineCells(gridColumns: Int, gridRows: Int, color: Colour? = nil) -> [Cell]
    {
        var cells: [Cell] = []
        for y in 0..<gridRows {
            for x in 0..<gridColumns {
                if let cell: Cell = self.createCell(x: x, y: y, color: color ?? self.cellColor) {
                    cells.append(cell)
                }
            }
        }
        return cells
    }
}

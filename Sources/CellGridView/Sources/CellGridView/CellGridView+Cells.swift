import Utils

extension CellGridView {

    internal func defineCells(gridColumns: Int, gridRows: Int, color: Colour? = nil,
                              currentCells: [Cell]? = nil,
                              currentColumns: Int? = nil,
                              currentRows: Int? = nil) -> [Cell]
    {
        var currentCell: ((Int, Int) -> Cell?)? = nil

        if let currentCells = currentCells, currentCells.count > 0,
           let currentColumns = currentColumns,
           let currentRows = currentRows {
            currentCell = { (x: Int, y: Int) -> Cell? in
                guard x >= 0, x < currentColumns, y >= 0, y < currentRows else { return nil }
                return currentCells[y * currentColumns + x]
            }
        }

        var cells: [Cell] = []

        for y in 0..<gridRows {
            for x in 0..<gridColumns {
                let previous: Cell? = currentCell?(x, y)
                let color: Colour = previous?.color ?? color ?? self.cellColor
                if let cell: Cell = self.createCell(x: x, y: y, color: color, previous: previous) {
                    cells.append(cell)
                }
            }
        }

        return cells
    }
}

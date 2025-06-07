import Foundation
import Utils

extension CellGridView
{
    private final func scaled(_ viewPoint: CGFloat) -> CGFloat {
        return self.screen.scaled(viewPoint, scaling: self.viewScaling)
    }

    // Returns the cell-grid cell object for the given cell-grid cell location, or nil.
    // FYI note that the cells are stored in a single dimensional array and access in
    // typical row major fashion; slightly more efficient that two dimensional array.
    //
    public final func gridCell<T: Cell>(_ gridCellX: Int, _ gridCellY: Int) -> T? {
        if (self.gridWrapAround) {
            var gridCellX: Int = gridCellX
            var gridCellY: Int = gridCellY
            // NONONON ... use this new self.gridWrapAroundX property to prevent ... idunno ... pickup later ...
            if ((gridCellX < 0) || (gridCellX >= self.gridColumns)) {
                if (!self.gridWrapAroundX) {
                    return nil
                }
                gridCellX = ((gridCellX < 0) ? abs(gridCellX + self.gridColumns) : gridCellX) % self.gridColumns
            }
            if ((gridCellY < 0) || (gridCellY >= self.gridRows)) {
                if (!self.gridWrapAroundY) {
                    return nil
                }
                gridCellY = ((gridCellY < 0) ? abs(gridCellY + self.gridRows) : gridCellY) % self.gridRows
            }
            if gridCellX < 0 || gridCellY < 0 {
                var x = 1
            }
            return self.gridCells[gridCellY * self.gridColumns + gridCellX] as? T
            /*
            if ((gridCellX < 0) || (gridCellX >= self.gridColumns) || (gridCellY < 0) || (gridCellY >= self.gridRows)) {
                let wrapAroundGridCellX: Int = ((gridCellX < 0) ? abs(gridCellX + self.gridColumns) : gridCellX) % self.gridColumns
                let wrapAroundGridCellY: Int = ((gridCellY < 0) ? abs(gridCellY + self.gridRows) : gridCellY) % self.gridRows
                print("gridCell/wraparound: \(gridCellX),\(gridCellY) -> \(wrapAroundGridCellX),\(wrapAroundGridCellY)")
                return self.gridCells[wrapAroundGridCellY * self.gridColumns + wrapAroundGridCellX] as? T
            }
            */
        }
        guard gridCellX >= 0, gridCellX < self.gridColumns, gridCellY >= 0, gridCellY < self.gridRows else {
            return nil
        }
        return self.gridCells[gridCellY * self.gridColumns + gridCellX] as? T
    }

    // Returns the cell-grid cell object for the given grid-view input location, or nil;
    // note that the display input location is always in unscaled units.
    //
    public final func gridCell<T: Cell>(viewPoint: CGPoint) -> T? {
        if let gridCellLocation: CellLocation = self.gridCellLocation(viewPoint: viewPoint) {
            return self.gridCell(gridCellLocation.x, gridCellLocation.y)
        }
        return nil
    }

    // Returns the cell-grid cell object for the given grid-view cell location, or nil.
    //
    public final func gridCell<T: Cell>(viewCellX: Int, viewCellY: Int) -> T? {
        if let gridCellLocation: CellLocation = self.gridCellLocation(viewCellX: viewCellX, viewCellY: viewCellY) {
            return self.gridCells[gridCellLocation.y * self.gridColumns + gridCellLocation.x] as? T
        }
        return nil
    }

    // Returns the cell-grid cell location of the given grid-view input point, or nil;
    // note that the view input point is always in unscaled units.
    //
    public final func gridCellLocation(viewPoint: CGPoint) -> CellLocation? {
        if let viewCellLocation: CellLocation = self.viewCellLocation(viewPoint: viewPoint) {
            var gridCellX: Int = viewCellLocation.x - self.shiftCellScaledX - ((self.shiftScaledX > 0) ? 1 : 0)
            if (self.gridWrapAround) {
                if ((gridCellX < 0) || (gridCellX >= self.gridColumns)) {
                    let wrapAroundGridCellX: Int = ((gridCellX < 0) ? abs(gridCellX + self.gridColumns) : gridCellX) % self.gridColumns
                    print("gridCellLocation/wraparound/x: \(viewPoint.x) -> \(gridCellX) -> \(wrapAroundGridCellX)")
                    gridCellX = wrapAroundGridCellX
                }
            }
            guard gridCellX >= 0, gridCellX < self.gridColumns else { return nil }
            var gridCellY: Int = viewCellLocation.y - self.shiftCellScaledY - ((self.shiftScaledY > 0) ? 1 : 0)
            if (self.gridWrapAround) {
                if ((gridCellY < 0) || (gridCellY >= self.gridRows)) {
                    let wrapAroundGridCellY: Int = ((gridCellY < 0) ? abs(gridCellY + self.gridRows) : gridCellY) % self.gridRows
                    print("gridCellLocation/wraparound/y: \(viewPoint.y) -> \(gridCellY) -> \(wrapAroundGridCellY)")
                    gridCellY = wrapAroundGridCellY
                }
            }
            guard gridCellY >= 0, gridCellY < self.gridRows else { return nil }
            print("gridCellLocation: \(viewPoint) -> \(gridCellX),\(gridCellY)")
            return CellLocation(gridCellX, gridCellY)
        }
        return nil
    }

    // Returns the cell-grid location of the given grid-view cell location.
    //
    internal final func gridCellLocation(viewCellX: Int, viewCellY: Int) -> CellLocation? {
        if (self.gridWrapAround) {
            if ((viewCellX < 0) || (viewCellX > self.viewCellEndX) || (viewCellY < 0) || (viewCellY > self.viewCellEndY)) {
                let wrapAroundViewCellX: Int = ((viewCellX < 0) ? abs(viewCellX + self.gridColumns) : viewCellX) % self.gridColumns
                let wrapAroundViewCellY: Int = ((viewCellY < 0) ? abs(viewCellY + self.gridRows) : viewCellY) % self.gridRows
                let gridCellX: Int = viewCellX - self.shiftCellScaledX - ((self.shiftScaledX > 0) ? 1 : 0)
                let gridCellY: Int = viewCellY - self.shiftCellScaledY - ((self.shiftScaledY > 0) ? 1 : 0)
                print("gridCellLocation/wraparound: \(viewCellX),\(viewCellY) -> \(wrapAroundViewCellX),\(wrapAroundViewCellY)")
                return CellLocation(gridCellX, gridCellY)
            }
        }
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX,
              viewCellY >= 0, viewCellY <= self.viewCellEndY else { return nil }
        let gridCellX: Int = viewCellX - self.shiftCellScaledX - ((self.shiftScaledX > 0) ? 1 : 0)
        let gridCellY: Int = viewCellY - self.shiftCellScaledY - ((self.shiftScaledY > 0) ? 1 : 0)
        guard gridCellX >= 0, gridCellX < self.gridColumns,
              gridCellY >= 0, gridCellY < self.gridRows else { return nil }
        return CellLocation(gridCellX, gridCellY)
    }

    // Returns the cell-grid location relative to the grid-view of the given grid-view input point, or nil.
    //
    internal final func viewCellLocation(viewPoint: CGPoint) -> CellLocation? {
        let viewPoint: ViewPoint = ViewPoint(self.scaled(viewPoint.x), self.scaled(viewPoint.y))
        guard viewPoint.x >= 0, viewPoint.x < self.viewWidthScaled,
              viewPoint.y >= 0, viewPoint.y < self.viewHeightScaled else { return nil }
        //
        // FYI: Changed what were round calls here to ViewPoint 2025-05-31 23:20 just in case.
        //
        let viewCellX: Int = ((self.shiftScaledX > 0)
                             ? (viewPoint.x + (self.cellSizeScaled - self.shiftScaledX))
                             : (viewPoint.x - self.shiftScaledX)) / self.cellSizeScaled
        let viewCellY: Int = ((self.shiftScaledY > 0)
                             ? (viewPoint.y + (self.cellSizeScaled - self.shiftScaledY))
                             : (viewPoint.y - self.shiftScaledY)) / self.cellSizeScaled
        return CellLocation(viewCellX, viewCellY)
    }

    // Returns the grid-view location of the given cell-grid cell location, or nil.
    //
    internal final func viewCellLocation(gridCellX: Int, gridCellY: Int) -> CellLocation? {
        if (self.gridWrapAround) {
            if ((gridCellX < 0) || (gridCellX >= self.gridColumns) || (gridCellY < 0) || (gridCellY >= self.gridRows)) {
                let wrapAroundGridCellX: Int = ((gridCellX < 0) ? abs(gridCellX + self.gridColumns) : gridCellX) % self.gridColumns
                let wrapAroundGridCellY: Int = ((gridCellY < 0) ? abs(gridCellY + self.gridRows) : gridCellY) % self.gridRows
                let viewCellX: Int = gridCellX + self.shiftCellScaledX + ((self.shiftScaledX > 0) ? 1 : 0)
                let viewCellY: Int = gridCellY + self.shiftCellScaledY + ((self.shiftScaledY > 0) ? 1 : 0)
                print("viewCellLocation/wraparound: \(gridCellX),\(gridCellY) -> \(wrapAroundGridCellX),\(wrapAroundGridCellY)")
                return CellLocation(viewCellX, viewCellY)
            }
        }
        guard gridCellX >= 0, gridCellX < self.gridColumns,
              gridCellY >= 0, gridCellY < self.gridRows else { return nil }
        var viewCellX: Int = gridCellX + self.shiftCellScaledX + ((self.shiftScaledX > 0) ? 1 : 0)
        var viewCellY: Int = gridCellY + self.shiftCellScaledY + ((self.shiftScaledY > 0) ? 1 : 0)
        if (self.gridWrapAround) {
            if (self.gridWrapAroundX) {
                // viewCellX = (viewCellX < 0) ? (self.gridColumns + viewCellX) : ((viewCellX % self.viewCellEndX) - 1)
                if (viewCellX < 0) {
                    viewCellX = self.gridColumns + viewCellX
                }
                else if (viewCellX > self.viewCellEndX) {
                    viewCellX = viewCellX % self.viewCellEndX - 1
                }
            }
            if (self.gridWrapAroundY) {
                // viewCellY = (viewCellY < 0) ? (self.gridRows + viewCellY) : ((viewCellY % self.viewCellEndY) - 1)
                if (viewCellY < 0) {
                    viewCellY = self.gridRows + viewCellY
                }
                else if (viewCellY > self.viewCellEndY) {
                    viewCellY = viewCellY % self.viewCellEndY - 1
                }
            }
            return CellLocation(viewCellX, viewCellY)
        }
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX,
              viewCellY >= 0, viewCellY <= self.viewCellEndY else { return nil }
        return CellLocation(viewCellX, viewCellY)
    }
}

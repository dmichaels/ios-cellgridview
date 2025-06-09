import Foundation
import Utils

extension CellGridView
{
    // Returns the cell-grid cell object for the given cell-grid cell location, or nil.
    // FYI note that the cells are stored in a single dimensional array and access in
    // typical row major fashion; slightly more efficient that two dimensional array.
    //
    public final func gridCell<T: Cell>(_ gridCellX: Int, _ gridCellY: Int) -> T? {
        var gridCellX: Int = gridCellX
        var gridCellY: Int = gridCellY
        if (self.gridWrapAround) {
            if (!self.cellGridSmallWidth) {
                if (gridCellX < 0) {
                    gridCellX = (self.gridColumns + (gridCellX % self.gridColumns)) % self.gridColumns
                }
                else if (gridCellX >= self.gridColumns) {
                    gridCellX = gridCellX % self.gridColumns
                }
            }
            if (!self.cellGridSmallHeight) {
                if (gridCellY < 0) {
                    gridCellY = (self.gridRows + (gridCellY % self.gridRows)) % self.gridRows
                }
                else if (gridCellY >= self.gridRows) {
                    gridCellY = gridCellY % self.gridRows
                }
            }
        }
        guard gridCellX >= 0, gridCellX < self.gridColumns, gridCellY >= 0, gridCellY < self.gridRows else {
            return nil
        }
        return self.gridCells[gridCellY * self.gridColumns + gridCellX] as? T
    }

    // Returns the cell-grid cell object for the given grid-view input point, or nil;
    // note that the display input point is always in unscaled units.
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
            return self.gridCell(gridCellLocation.x, gridCellLocation.y)
        }
        return nil
    }

    // Returns the cell-grid cell location of the given grid-view input point, or nil;
    // note that the view input point is always in unscaled units.
    //
    public final func gridCellLocation(viewPoint: CGPoint) -> CellLocation? {
        if let viewCellLocation: ViewLocation = self.viewCellLocation(viewPoint: viewPoint) {
            return self.gridCellLocation(viewCellX: viewCellLocation.x, viewCellY: viewCellLocation.y)
        }
        return nil
    }

    // Returns the cell-grid location of the given grid-view cell location.
    //
    internal final func gridCellLocation(viewCellX: Int, viewCellY: Int) -> CellLocation? {
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX, viewCellY >= 0, viewCellY <= self.viewCellEndY else {
            return nil
        }
        var gridCellX: Int = viewCellX - self.shiftCellScaledX - ((self.shiftScaledX > 0) ? 1 : 0)
        var gridCellY: Int = viewCellY - self.shiftCellScaledY - ((self.shiftScaledY > 0) ? 1 : 0)
        if (self.gridWrapAround) {
            if (!self.cellGridSmallWidth) {
                if (gridCellX < 0) {
                    gridCellX = (self.gridColumns + (gridCellX % self.gridColumns)) % self.gridColumns
                }
                else if (gridCellX >= self.gridColumns) {
                    gridCellX = gridCellX % self.gridColumns
                }
            }
            if (!self.cellGridSmallHeight) {
                if (gridCellY < 0) {
                    gridCellY = (self.gridRows + (gridCellY % self.gridRows)) % self.gridRows
                }
                else if (gridCellY >= self.gridRows) {
                    gridCellY = gridCellY % self.gridRows
                }
            }
        }
        guard gridCellX >= 0, gridCellX < self.gridColumns, gridCellY >= 0, gridCellY < self.gridRows else {
            return nil
        }
        return CellLocation(gridCellX, gridCellY)
    }

    // Returns the cell-grid location relative to the grid-view of the given grid-view input point, or nil.
    //
    private final func viewCellLocation(viewPoint: CGPoint) -> ViewLocation? {
        let viewPoint: ViewPoint = ViewPoint(self.scaled(viewPoint.x), self.scaled(viewPoint.y))
        guard viewPoint.x >= 0, viewPoint.x < self.viewWidthScaled,
              viewPoint.y >= 0, viewPoint.y < self.viewHeightScaled else {
            return nil
        }
        //
        // FYI: Changed what were round calls here to ViewPoint 2025-05-31 23:20 just in case.
        //
        var viewCellX: Int = ((self.shiftScaledX > 0)
                             ? (viewPoint.x + (self.cellSizeScaled - self.shiftScaledX))
                             : (viewPoint.x - self.shiftScaledX)) / self.cellSizeScaled
        var viewCellY: Int = ((self.shiftScaledY > 0)
                             ? (viewPoint.y + (self.cellSizeScaled - self.shiftScaledY))
                             : (viewPoint.y - self.shiftScaledY)) / self.cellSizeScaled
        if (self.gridWrapAround) {
            if (!self.cellGridSmallWidth) {
                if (viewCellX < 0) {
                    viewCellX = (self.gridColumns + (viewCellX % self.gridColumns)) % self.gridColumns
                }
                else if (viewCellX > self.viewCellEndX) {
                    viewCellX = viewCellX % self.gridColumns
                }
            }
            if (!self.cellGridSmallHeight) {
                if (viewCellY < 0) {
                    viewCellY = (self.gridRows + (viewCellY % self.gridRows)) % self.gridRows
                }
                else if (viewCellY > self.viewCellEndY) {
                    viewCellY = viewCellY % self.gridRows
                }
            }
        }
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX, viewCellY >= 0, viewCellY <= self.viewCellEndY else {
            return nil
        }
        return ViewLocation(viewCellX, viewCellY)
    }

    // Returns the grid-view location of the given cell-grid cell location, or nil.
    //
    internal final func viewCellLocation(gridCellX: Int, gridCellY: Int) -> ViewLocation? {
        guard gridCellX >= 0, gridCellX < self.gridColumns, gridCellY >= 0, gridCellY < self.gridRows else {
            return nil
        }
        var viewCellX: Int = gridCellX + self.shiftCellScaledX + ((self.shiftScaledX > 0) ? 1 : 0)
        var viewCellY: Int = gridCellY + self.shiftCellScaledY + ((self.shiftScaledY > 0) ? 1 : 0)
        if (self.gridWrapAround) {
            if (!self.cellGridSmallWidth) {
                if (viewCellX < 0) {
                    viewCellX = (self.gridColumns + (viewCellX % self.gridColumns)) % self.gridColumns
                }
                else if (viewCellX > self.viewCellEndX) {
                    viewCellX = viewCellX % self.gridColumns
                }
            }
            if (!self.cellGridSmallHeight) {
                if (viewCellY < 0) {
                    viewCellY = (self.gridRows + (viewCellY % self.gridRows)) % self.gridRows
                }
                else if (viewCellY > self.viewCellEndY) {
                    viewCellY = viewCellY % self.gridRows
                }
            }
        }
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX, viewCellY >= 0, viewCellY <= self.viewCellEndY else {
            return nil
        }
        return ViewLocation(viewCellX, viewCellY)
    }

    private final var cellGridSmallWidth: Bool  { (self.cellSizeScaled * self.gridColumns) < self.viewWidthScaled }
    private final var cellGridSmallHeight: Bool { (self.cellSizeScaled * self.gridRows) < self.viewHeightScaled }

    private final func scaled(_ viewPoint: CGFloat) -> CGFloat {
        return self.screen.scaled(viewPoint, scaling: self.viewScaling)
    }
}

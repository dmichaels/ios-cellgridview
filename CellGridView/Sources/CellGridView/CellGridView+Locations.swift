import Foundation
import Utils

extension CellGridView
{
    private final func scaled(_ viewPoint: CGFloat) -> CGFloat {
        return self.screen.scaled(viewPoint, scaling: self.viewScaling)
    }

    // Returns the cell-grid cell object for the given cell-grid cell location, or nil.
    //
    public final func gridCell<T: Cell>(_ gridCellX: Int, _ gridCellY: Int) -> T? {
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
            let gridCellX: Int = viewCellLocation.x - self.shiftCellScaledX - ((self.shiftScaledX > 0) ? 1 : 0)
            guard gridCellX >= 0, gridCellX < self.gridColumns else { return nil }
            let gridCellY: Int = viewCellLocation.y - self.shiftCellScaledY - ((self.shiftScaledY > 0) ? 1 : 0)
            guard gridCellY >= 0, gridCellY < self.gridRows else { return nil }
            return CellLocation(gridCellX, gridCellY)
        }
        return nil
    }

    // Returns the cell-grid location of the given grid-view cell location.
    //
    internal final func gridCellLocation(viewCellX: Int, viewCellY: Int) -> CellLocation? {
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

    // Returns the cell-grid location of the given cell-grid cell location, or nil.
    //
    internal final func viewCellLocation(gridCellX: Int, gridCellY: Int) -> CellLocation? {
        guard gridCellX >= 0, gridCellX < self.gridColumns,
              gridCellY >= 0, gridCellY < self.gridRows else { return nil }
        let viewCellX: Int = gridCellX + self.shiftCellScaledX + ((self.shiftScaledX > 0) ? 1 : 0)
        let viewCellY: Int = gridCellY + self.shiftCellScaledY + ((self.shiftScaledY > 0) ? 1 : 0)
        guard viewCellX >= 0, viewCellX <= self.viewCellEndX,
              viewCellY >= 0, viewCellY <= self.viewCellEndY else { return nil }
        return CellLocation(viewCellX, viewCellY)
    }
}

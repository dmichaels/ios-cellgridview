import Foundation
import SwiftUI
import Utils

open class Cell
{
    private var _cellGridView: CellGridView
    private let _x: Int
    private let _y: Int
    private var _color: Colour

    public var x: Int {
        self._x
    }

    public var y: Int {
        self._y
    }

    public var location: CellLocation {
        CellLocation(self._x, self._y)
    }

    open var color: Colour {
        get { return self._color }
        set { self._color = newValue }
    }

    open var cellGridView: CellGridView {
        self._cellGridView
    }

    public init(cellGridView: CellGridView, x: Int, y: Int, color: Colour? = nil) {
        self._cellGridView = cellGridView
        self._x = x
        self._y = y
        self._color = color ?? cellGridView.cellColor
    }

    public func write(color: Colour? = nil, foregroundOnly: Bool = false) {
        if let color = color {
            self.color = color
        }
        if let viewCellLocation = self._cellGridView.viewCellLocation(gridCellX: self._x, gridCellY: self._y) {
            self._cellGridView.writeCell(viewCellX: viewCellLocation.x,
                                         viewCellY: viewCellLocation.y, foregroundOnly: foregroundOnly)
        }
    }

    open func select(dragging: Bool? = nil) {
        //
        // To be implemented by subclasses.
        // The dragging argument is nil if there is no dragging involved at all; if it is true then the
        // cell selection occurred during dragging; and if it is false then the cell selection occurred
        // at the very end of dragging, i.e. when the drag/selection stops (e.g. the finger is lifted).
        //
    }
}

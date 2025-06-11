import Foundation
import SwiftUI

open class Cell
{
    private var _cellGridView: CellGridView
    private let _x: Int
    private let _y: Int
    private var _color: CellColor

    public var x: Int {
        self._x
    }

    public var y: Int {
        self._y
    }

    public var location: CellLocation {
        CellLocation(self._x, self._y)
    }

    public var color: CellColor {
        get { return self._color }
        set { self._color = newValue }
    }

    open var cellGridView: CellGridView {
        self._cellGridView
    }

    public init(cellGridView: CellGridView, x: Int, y: Int, color: CellColor) {
        self._cellGridView = cellGridView
        self._x = x
        self._y = y
        self._color = color
    }

    public func write(color: CellColor, foregroundOnly: Bool = false) {
        if let viewCellLocation = self._cellGridView.viewCellLocation(gridCellX: self._x, gridCellY: self._y) {
            self._color = color
            self._cellGridView.writeCell(viewCellX: viewCellLocation.x, viewCellY: viewCellLocation.y)
        }
    }

    open func select(dragging: Bool = false) {
        //
        // To be implemented by subclasses.
        //
    }
}

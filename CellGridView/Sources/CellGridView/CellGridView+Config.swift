import SwiftUI
import Utils

extension CellGridView
{
    open class Config
    {
        public private(set) var viewBackground: Colour
        public private(set) var viewTransparency: UInt8
        public private(set) var viewScaling: Bool

        public var cellSize: Int // xyzzy/todo/set
        public private(set) var cellPadding: Int
        public private(set) var cellShape: CellShape
        public private(set) var cellColor: Colour

        public private(set) var cellSizeMax: Int
        public private(set) var cellSizeInnerMin: Int
        public private(set) var cellPaddingMax: Int

        public private(set) var gridColumns: Int
        public private(set) var gridRows: Int

        public private(set) var cellAntialiasFade: Float
        public private(set) var cellRoundedRadius: Float
        public private(set) var restrictShift: Bool
        public private(set) var unscaledZoom: Bool

        public private(set) var selectMode: Bool
        public private(set) var automationMode: Bool
        public private(set) var automationInterval: Double

        public init(viewBackground: Colour?     = nil,
                    viewTransparency: UInt8?    = nil,
                    viewScaling: Bool?          = nil,
                    cellSize: Int?              = nil,
                    cellPadding: Int?           = nil,
                    cellShape: CellShape?       = nil,
                    cellColor: Colour?          = nil,
                    cellSizeMax: Int?           = nil,
                    cellSizeInnerMin: Int?      = nil,
                    cellPaddingMax: Int?        = nil,
                    gridColumns: Int?           = nil,
                    gridRows: Int?              = nil,
                    cellAntialiasFade: Float?   = nil,
                    cellRoundedRadius: Float?   = nil,
                    restrictShift: Bool?        = nil,
                    unscaledZoom: Bool?         = nil,
                    selectMode: Bool?           = nil,
                    automationMode: Bool?       = nil,
                    automationInterval: Double? = nil
        )
        {
            self.viewBackground     = viewBackground     ?? CellGridView.Defaults.viewBackground
            self.viewTransparency   = viewTransparency   ?? CellGridView.Defaults.viewTransparency
            self.viewScaling        = viewScaling        ?? CellGridView.Defaults.viewScaling
            self.cellSize           = cellSize           ?? CellGridView.Defaults.cellSize
            self.cellPadding        = cellPadding        ?? CellGridView.Defaults.cellPadding
            self.cellShape          = cellShape          ?? CellGridView.Defaults.cellShape
            self.cellColor          = cellColor          ?? CellGridView.Defaults.cellColor
            self.cellSizeMax        = cellSizeMax        ?? CellGridView.Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellSizeInnerMin   ?? CellGridView.Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellPaddingMax     ?? CellGridView.Defaults.cellPaddingMax
            self.gridColumns        = gridColumns        ?? CellGridView.Defaults.gridColumns
            self.gridRows           = gridRows           ?? CellGridView.Defaults.gridRows
            self.cellAntialiasFade  = cellAntialiasFade  ?? CellGridView.Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellRoundedRadius  ?? CellGridView.Defaults.cellRoundedRadius
            self.restrictShift      = restrictShift      ?? CellGridView.Defaults.restrictShift
            self.unscaledZoom       = unscaledZoom       ?? CellGridView.Defaults.unscaledZoom
            self.selectMode         = selectMode         ?? CellGridView.Defaults.selectMode
            self.automationMode     = automationMode     ?? CellGridView.Defaults.automationMode
            self.automationInterval = automationInterval ?? CellGridView.Defaults.automationInterval
        }

        // Initializes this instance of CellGridView.Config with the properties from the given
        // CellGridView, or with the default values from CellGridView.Defaults is nil is given.
        //
        public init(_ cellGridView: CellGridView? = nil) {
            self.viewBackground     = cellGridView?.viewBackground     ?? CellGridView.Defaults.viewBackground
            self.viewTransparency   = cellGridView?.viewTransparency   ?? CellGridView.Defaults.viewTransparency
            self.viewScaling        = cellGridView?.viewScaling        ?? CellGridView.Defaults.viewScaling
            self.cellSize           = cellGridView?.cellSize           ?? CellGridView.Defaults.cellSize
            self.cellPadding        = cellGridView?.cellPadding        ?? CellGridView.Defaults.cellPadding
            self.cellShape          = cellGridView?.cellShape          ?? CellGridView.Defaults.cellShape
            self.cellColor          = cellGridView?.cellColor          ?? CellGridView.Defaults.cellColor
            self.cellSizeMax        = cellGridView?.cellSizeMax        ?? CellGridView.Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellGridView?.cellSizeInnerMin   ?? CellGridView.Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellGridView?.cellPaddingMax     ?? CellGridView.Defaults.cellPaddingMax
            self.gridColumns        = cellGridView?.gridColumns        ?? CellGridView.Defaults.gridColumns
            self.gridRows           = cellGridView?.gridRows           ?? CellGridView.Defaults.gridRows
            self.cellAntialiasFade  = cellGridView?.cellAntialiasFade  ?? CellGridView.Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellGridView?.cellRoundedRadius  ?? CellGridView.Defaults.cellRoundedRadius
            self.restrictShift      = cellGridView?.restrictShift      ?? CellGridView.Defaults.restrictShift
            self.unscaledZoom       = cellGridView?.unscaledZoom       ?? CellGridView.Defaults.unscaledZoom
            self.selectMode         = cellGridView?.selectMode         ?? CellGridView.Defaults.selectMode
            self.automationMode     = cellGridView?.automationMode     ?? CellGridView.Defaults.automationMode
            self.automationInterval = cellGridView?.automationInterval ?? CellGridView.Defaults.automationInterval
        }
    }

    public final var minimumCellSize: Int {
        self.minimumCellSize(cellPadding: self.cellPadding)
    }

    public final func minimumCellSize(cellPadding: Int? = nil) -> Int {
        let cellPadding: Int = max(0, cellPadding ?? self.cellPadding)
        return self.constrainCellSize(Defaults.cellSizeInnerMin, cellPadding: cellPadding, scaled: false)
    }

    public final var maximumCellSize: Int {
        Defaults.cellSizeMax
    }

    public final var minimumCellPadding: Int {
        0
    }

    public final var maximumCellPadding: Int {
        Defaults.cellPaddingMax
    }

    internal final func constrainCellSize(_ cellSize: Int, cellPadding: Int? = nil, scaled: Bool = false) -> Int {
        let cellSizeInnerMin: Int = self.scaled(Defaults.cellSizeInnerMin)
        let cellSizeMax: Int = self.scaled(Defaults.cellSizeMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding ?? self.cellPadding) : (cellPadding ?? self.cellPaddingScaled)
        let constrainedCellSize: Int = cellSize.clamped(cellSizeInnerMin + (cellPadding * 2)...cellSizeMax)
        return !scaled ? self.unscaled(constrainedCellSize) : constrainedCellSize
    }

    internal final func constrainCellPadding(_ cellPadding: Int, scaled: Bool = false) -> Int {
        let cellPaddingMax: Int = self.scaled(Defaults.cellPaddingMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding) : cellPadding
        let constrainedCellPadding: Int = cellPadding.clamped(0...cellPaddingMax)
        return !scaled ? self.unscaled(constrainedCellPadding) : constrainedCellPadding
    }
}

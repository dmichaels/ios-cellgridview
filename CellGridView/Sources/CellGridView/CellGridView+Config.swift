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

        // public init(config: CellGridView.Config? = nil,
        public init(_ config: CellGridView.Config? = nil,
                    viewBackground: Colour?      = nil,
                    viewTransparency: UInt8?     = nil,
                    viewScaling: Bool?           = nil,
                    cellSize: Int?               = nil,
                    cellPadding: Int?            = nil,
                    cellShape: CellShape?        = nil,
                    cellColor: Colour?           = nil,
                    cellSizeMax: Int?            = nil,
                    cellSizeInnerMin: Int?       = nil,
                    cellPaddingMax: Int?         = nil,
                    gridColumns: Int?            = nil,
                    gridRows: Int?               = nil,
                    cellAntialiasFade: Float?    = nil,
                    cellRoundedRadius: Float?    = nil,
                    restrictShift: Bool?         = nil,
                    unscaledZoom: Bool?          = nil,
                    selectMode: Bool?            = nil,
                    automationMode: Bool?        = nil,
                    automationInterval: Double?  = nil
        )
        {
            self.viewBackground     = viewBackground     ?? config?.viewBackground     ?? Defaults.viewBackground
            self.viewTransparency   = viewTransparency   ?? config?.viewTransparency   ?? Defaults.viewTransparency
            self.viewScaling        = viewScaling        ?? config?.viewScaling        ?? Defaults.viewScaling
            self.cellSize           = cellSize           ?? config?.cellSize           ?? Defaults.cellSize
            self.cellPadding        = cellPadding        ?? config?.cellPadding        ?? Defaults.cellPadding
            self.cellShape          = cellShape          ?? config?.cellShape          ?? Defaults.cellShape
            self.cellColor          = cellColor          ?? config?.cellColor          ?? Defaults.cellColor
            self.cellSizeMax        = cellSizeMax        ?? config?.cellSizeMax        ?? Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellSizeInnerMin   ?? config?.cellSizeInnerMin   ?? Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellPaddingMax     ?? config?.cellPaddingMax     ?? Defaults.cellPaddingMax
            self.gridColumns        = gridColumns        ?? config?.gridColumns        ?? Defaults.gridColumns
            self.gridRows           = gridRows           ?? config?.gridRows           ?? Defaults.gridRows
            self.cellAntialiasFade  = cellAntialiasFade  ?? config?.cellAntialiasFade  ?? Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellRoundedRadius  ?? config?.cellRoundedRadius  ?? Defaults.cellRoundedRadius
            self.restrictShift      = restrictShift      ?? config?.restrictShift      ?? Defaults.restrictShift
            self.unscaledZoom       = unscaledZoom       ?? config?.unscaledZoom       ?? Defaults.unscaledZoom
            self.selectMode         = selectMode         ?? config?.selectMode         ?? Defaults.selectMode
            self.automationMode     = automationMode     ?? config?.automationMode     ?? Defaults.automationMode
            self.automationInterval = automationInterval ?? config?.automationInterval ?? Defaults.automationInterval
        }

        // Initializes this instance of CellGridView.Config with the properties from the given
        // CellGridView, or with the default values from CellGridView.Defaults is nil is given.
        //
        public init(_ cellGridView: CellGridView? = nil) {
            self.viewBackground     = cellGridView?.viewBackground     ?? Defaults.viewBackground
            self.viewTransparency   = cellGridView?.viewTransparency   ?? Defaults.viewTransparency
            self.viewScaling        = cellGridView?.viewScaling        ?? Defaults.viewScaling
            self.cellSize           = cellGridView?.cellSize           ?? Defaults.cellSize
            self.cellPadding        = cellGridView?.cellPadding        ?? Defaults.cellPadding
            self.cellShape          = cellGridView?.cellShape          ?? Defaults.cellShape
            self.cellColor          = cellGridView?.cellColor          ?? Defaults.cellColor
            self.cellSizeMax        = cellGridView?.cellSizeMax        ?? Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellGridView?.cellSizeInnerMin   ?? Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellGridView?.cellPaddingMax     ?? Defaults.cellPaddingMax
            self.gridColumns        = cellGridView?.gridColumns        ?? Defaults.gridColumns
            self.gridRows           = cellGridView?.gridRows           ?? Defaults.gridRows
            self.cellAntialiasFade  = cellGridView?.cellAntialiasFade  ?? Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellGridView?.cellRoundedRadius  ?? Defaults.cellRoundedRadius
            self.restrictShift      = cellGridView?.restrictShift      ?? Defaults.restrictShift
            self.unscaledZoom       = cellGridView?.unscaledZoom       ?? Defaults.unscaledZoom
            self.selectMode         = cellGridView?.selectMode         ?? Defaults.selectMode
            self.automationMode     = cellGridView?.automationMode     ?? Defaults.automationMode
            self.automationInterval = cellGridView?.automationInterval ?? Defaults.automationInterval
        }

        public func update(viewBackground: Colour?     = nil,
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
                           automationInterval: Double? = nil) -> CellGridView.Config
        {
            return CellGridView.Config(viewBackground:     viewBackground     ?? self.viewBackground,
                                       viewTransparency:   viewTransparency   ?? self.viewTransparency,
                                       viewScaling:        viewScaling        ?? self.viewScaling,
                                       cellSize:           cellSize           ?? self.cellSize,
                                       cellPadding:        cellPadding        ?? self.cellPadding,
                                       cellShape:          cellShape          ?? self.cellShape,
                                       cellColor:          cellColor          ?? self.cellColor,
                                       cellSizeMax:        cellSizeMax        ?? self.cellSizeMax,
                                       cellSizeInnerMin:   cellSizeInnerMin   ?? self.cellSizeInnerMin,
                                       cellPaddingMax:     cellPaddingMax     ?? self.cellPaddingMax,
                                       gridColumns:        gridColumns        ?? self.gridColumns,
                                       gridRows:           gridRows           ?? self.gridRows,
                                       cellAntialiasFade:  cellAntialiasFade  ?? self.cellAntialiasFade,
                                       cellRoundedRadius:  cellRoundedRadius  ?? self.cellRoundedRadius,
                                       restrictShift:      restrictShift      ?? self.restrictShift,
                                       unscaledZoom:       unscaledZoom       ?? self.unscaledZoom,
                                       selectMode:         selectMode         ?? self.selectMode,
                                       automationMode:     automationMode     ?? self.automationMode,
                                       automationInterval: automationInterval ?? self.automationInterval)
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

    public final var minimumGridColumns: Int {
        1
    }

    public final var maximumGridColumns: Int {
        5000 // TODO: configize
    }

    public final var minimumGridRows: Int {
        1
    }

    public final var maximumGridRows: Int {
        5000 // TODO: configize
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

    internal final func constrainGridColumns(_ gridColumns: Int) -> Int {
        return gridColumns.clamped(self.minimumGridColumns...self.maximumGridColumns)
    }

    internal final func constrainGridRows(_ gridColumns: Int) -> Int {
        return gridRows.clamped(self.minimumGridRows...self.maximumGridRows)
    }
}

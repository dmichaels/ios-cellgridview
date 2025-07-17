import SwiftUI
import Utils

extension CellGridView
{
    open class Config
    {
        public private(set) var viewBackground: Colour
        public private(set) var viewTransparency: UInt8
        public private(set) var viewScaling: Bool

        public private(set) var cellSize: Int
        public private(set) var cellPadding: Int
        public private(set) var cellShape: CellShape
        public private(set) var cellShading: Bool
        public private(set) var cellColor: Colour

        public private(set) var cellSizeMax: Int
        public private(set) var cellSizeInnerMin: Int
        public private(set) var cellPaddingMax: Int

        public private(set) var gridColumns: Int
        public private(set) var gridRows: Int
        public private(set) var fit: CellGridView.Fit
        public private(set) var center: Bool

        public private(set) var cellAntialiasFade: Float
        public private(set) var cellRoundedRadius: Float
        public private(set) var restrictShift: Bool
        public private(set) var unscaledZoom: Bool

        public private(set) var selectMode: Bool
        public private(set) var automationMode: Bool
        public private(set) var automationInterval: Double
        public private(set) var automationRandom: Bool
        public private(set) var automationRandomInterval: Double

        public init(_ config: CellGridView.Config?    = nil,
                    viewBackground: Colour?           = nil,
                    viewTransparency: UInt8?          = nil,
                    viewScaling: Bool?                = nil,
                    cellSize: Int?                    = nil,
                    cellPadding: Int?                 = nil,
                    cellShape: CellShape?             = nil,
                    cellShading: Bool?                = nil,
                    cellColor: Colour?                = nil,
                    cellSizeMax: Int?                 = nil,
                    cellSizeInnerMin: Int?            = nil,
                    cellPaddingMax: Int?              = nil,
                    gridColumns: Int?                 = nil,
                    gridRows: Int?                    = nil,
                    fit: CellGridView.Fit?            = nil,
                    center: Bool?                     = nil,
                    cellAntialiasFade: Float?         = nil,
                    cellRoundedRadius: Float?         = nil,
                    restrictShift: Bool?              = nil,
                    unscaledZoom: Bool?               = nil,
                    selectMode: Bool?                 = nil,
                    automationMode: Bool?             = nil,
                    automationInterval: Double?       = nil,
                    automationRandom: Bool?           = nil,
                    automationRandomInterval: Double? = nil
        )
        {
            self.viewBackground     = viewBackground     ?? config?.viewBackground     ?? Defaults.viewBackground
            self.viewTransparency   = viewTransparency   ?? config?.viewTransparency   ?? Defaults.viewTransparency
            self.viewScaling        = viewScaling        ?? config?.viewScaling        ?? Defaults.viewScaling
            self.cellSize           = cellSize           ?? config?.cellSize           ?? Defaults.cellSize
            self.cellPadding        = cellPadding        ?? config?.cellPadding        ?? Defaults.cellPadding
            self.cellShape          = cellShape          ?? config?.cellShape          ?? Defaults.cellShape
            self.cellShading        = cellShading        ?? config?.cellShading        ?? Defaults.cellShading
            self.cellColor          = cellColor          ?? config?.cellColor          ?? Defaults.cellColor
            self.cellSizeMax        = cellSizeMax        ?? config?.cellSizeMax        ?? Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellSizeInnerMin   ?? config?.cellSizeInnerMin   ?? Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellPaddingMax     ?? config?.cellPaddingMax     ?? Defaults.cellPaddingMax
            self.gridColumns        = gridColumns        ?? config?.gridColumns        ?? Defaults.gridColumns
            self.gridRows           = gridRows           ?? config?.gridRows           ?? Defaults.gridRows
            self.fit                = fit                ?? config?.fit                ?? Defaults.fit
            self.center             = center             ?? config?.center             ?? Defaults.center
            self.cellAntialiasFade  = cellAntialiasFade  ?? config?.cellAntialiasFade  ?? Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellRoundedRadius  ?? config?.cellRoundedRadius  ?? Defaults.cellRoundedRadius
            self.restrictShift      = restrictShift      ?? config?.restrictShift      ?? Defaults.restrictShift
            self.unscaledZoom       = unscaledZoom       ?? config?.unscaledZoom       ?? Defaults.unscaledZoom

            self.selectMode               = selectMode               ?? config?.selectMode               ?? Defaults.selectMode
            self.automationMode           = automationMode           ?? config?.automationMode           ?? Defaults.automationMode
            self.automationInterval       = automationInterval       ?? config?.automationInterval       ?? Defaults.automationInterval
            self.automationRandom         = automationRandom         ?? config?.automationRandom         ?? Defaults.automationRandom
            self.automationRandomInterval = automationRandomInterval ?? config?.automationRandomInterval ?? Defaults.automationRandomInterval
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
            self.cellShading        = cellGridView?.cellShading        ?? Defaults.cellShading
            self.cellColor          = cellGridView?.cellColor          ?? Defaults.cellColor
            self.cellSizeMax        = cellGridView?.cellSizeMax        ?? Defaults.cellSizeMax
            self.cellSizeInnerMin   = cellGridView?.cellSizeInnerMin   ?? Defaults.cellSizeInnerMin
            self.cellPaddingMax     = cellGridView?.cellPaddingMax     ?? Defaults.cellPaddingMax
            self.gridColumns        = cellGridView?.gridColumns        ?? Defaults.gridColumns
            self.gridRows           = cellGridView?.gridRows           ?? Defaults.gridRows
            self.fit                = cellGridView?.fit                ?? Defaults.fit
            self.center             = cellGridView?.center             ?? Defaults.center
            self.cellAntialiasFade  = cellGridView?.cellAntialiasFade  ?? Defaults.cellAntialiasFade
            self.cellRoundedRadius  = cellGridView?.cellRoundedRadius  ?? Defaults.cellRoundedRadius
            self.restrictShift      = cellGridView?.restrictShift      ?? Defaults.restrictShift
            self.unscaledZoom       = cellGridView?.unscaledZoom       ?? Defaults.unscaledZoom

            self.selectMode               = cellGridView?.selectMode               ?? Defaults.selectMode
            self.automationMode           = cellGridView?.automationMode           ?? Defaults.automationMode
            self.automationInterval       = cellGridView?.automationInterval       ?? Defaults.automationInterval
            self.automationRandom         = cellGridView?.automationRandom         ?? Defaults.automationRandom
            self.automationRandomInterval = cellGridView?.automationRandomInterval ?? Defaults.automationRandomInterval
        }

        public func update(viewBackground: Colour?            = nil,
                           viewTransparency: UInt8?           = nil,
                           viewScaling: Bool?                 = nil,
                           cellSize: Int?                     = nil,
                           cellPadding: Int?                  = nil,
                           cellShape: CellShape?              = nil,
                           cellShading: Bool?                 = nil,
                           cellColor: Colour?                 = nil,
                           cellSizeMax: Int?                  = nil,
                           cellSizeInnerMin: Int?             = nil,
                           cellPaddingMax: Int?               = nil,
                           gridColumns: Int?                  = nil,
                           gridRows: Int?                     = nil,
                           fit: CellGridView.Fit?             = nil,
                           center: Bool?                      = nil,
                           cellAntialiasFade: Float?          = nil,
                           cellRoundedRadius: Float?          = nil,
                           restrictShift: Bool?               = nil,
                           unscaledZoom: Bool?                = nil,
                           selectMode: Bool?                  = nil,
                           automationMode: Bool?              = nil,
                           automationInterval: Double?        = nil,
                           automationRandom: Bool?            = nil,
                           automationRandomeInterval: Double? = nil) -> CellGridView.Config
        {
            return CellGridView.Config(
                viewBackground:           viewBackground           ?? self.viewBackground,
                viewTransparency:         viewTransparency         ?? self.viewTransparency,
                viewScaling:              viewScaling              ?? self.viewScaling,
                cellSize:                 cellSize                 ?? self.cellSize,
                cellPadding:              cellPadding              ?? self.cellPadding,
                cellShape:                cellShape                ?? self.cellShape,
                cellShading:              cellShading              ?? self.cellShading,
                cellColor:                cellColor                ?? self.cellColor,
                cellSizeMax:              cellSizeMax              ?? self.cellSizeMax,
                cellSizeInnerMin:         cellSizeInnerMin         ?? self.cellSizeInnerMin,
                cellPaddingMax:           cellPaddingMax           ?? self.cellPaddingMax,
                gridColumns:              gridColumns              ?? self.gridColumns,
                gridRows:                 gridRows                 ?? self.gridRows,
                fit:                      fit                      ?? self.fit,
                center:                   center                   ?? self.center,
                cellAntialiasFade:        cellAntialiasFade        ?? self.cellAntialiasFade,
                cellRoundedRadius:        cellRoundedRadius        ?? self.cellRoundedRadius,
                restrictShift:            restrictShift            ?? self.restrictShift,
                unscaledZoom:             unscaledZoom             ?? self.unscaledZoom,
                selectMode:               selectMode               ?? self.selectMode,
                automationMode:           automationMode           ?? self.automationMode,
                automationInterval:       automationInterval       ?? self.automationInterval,
                automationRandom:         automationRandom         ?? self.automationRandom,
                automationRandomInterval: automationRandomInterval ?? self.automationRandomInterval)
        }
    }
}

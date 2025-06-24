import SwiftUI
import Utils

extension CellGridView
{
    public struct Defaults
    {
        // The size related properties here (being outward facing) are unscaled.

        public static let viewBackground: Colour = Colour.darkGray
        public static let viewTransparency: UInt8 = Colour.OPAQUE
        public static let viewScaling: Bool = true

        public static let cellSize: Int = 25
        public static let cellPadding: Int = 1
        public static let cellShape: CellShape = CellShape.rounded
        public static let cellColor: Colour = Colour.white

        public static let cellSizeMax: Int = 200
        public static let cellSizeInnerMin: Int = 1
        public static let cellPaddingMax: Int = 8

        public static let gridColumns: Int = 0
        public static let gridRows: Int = 0

        public static let cellAntialiasFade: Float = 0.6  // smaller -> smoother
        public static let cellRoundedRadius: Float = 0.25
        public static let restrictShift: Bool = true
        public static let unscaledZoom: Bool = false

        public static let selectMode: Bool = true
        public static let automationMode: Bool = true
        public static let automationInterval: Double = 0.5

        // Only used on CellGridView.initialize.
        //
        public static let cellSizeFit: Bool = false
        public static let cellPreferredSizeMarginMax: Int = 30
        public static let centerCells: Bool = false

        // Wraparound support is incomplete, half-baked, and of questionable utility.
        //
        public static let gridWrapAround: Bool = false
    }

    open class Config
    {
        private var _viewBackground: Colour
        private var _viewTransparency: UInt8
        private var _viewScaling: Bool

        private var _cellSize: Int
        private var _cellPadding: Int
        private var _cellShape: CellShape
        private var _cellColor: Colour

        private var _cellSizeMax: Int
        private var _cellSizeInnerMin: Int
        private var _cellPaddingMax: Int

        private var _gridColumns: Int
        private var _gridRows: Int

        private var _cellAntialiasFade: Float
        private var _cellRoundedRadius: Float
        private var _restrictShift: Bool
        private var _unscaledZoom: Bool

        private var _selectMode: Bool
        private var _automationMode: Bool
        private var _automationInterval: Double

        public var viewBackground: Colour     { self._viewBackground }
        public var viewTransparency: UInt8    { self._viewTransparency }
        public var viewScaling: Bool          { self._viewScaling }

        public var cellSize: Int              { self._cellSize }
        public var cellPadding: Int           { self._cellPadding }
        public var cellShape: CellShape       { self._cellShape }
        public var cellColor: Colour          { self._cellColor }

        public var cellSizeMax: Int           { self._cellSizeMax }
        public var cellSizeInnerMin: Int      { self._cellSizeInnerMin }
        public var cellPaddingMax: Int        { self._cellPaddingMax }

        public var gridColumns: Int           { self._gridColumns }
        public var gridRows: Int              { self._gridRows }

        public var cellAntialiasFade: Float   { self._cellAntialiasFade }
        public var cellRoundedRadius: Float   { self._cellRoundedRadius }
        public var restrictShift: Bool        { self._restrictShift }
        public var unscaledZoom: Bool         { self._unscaledZoom }

        public var selectMode: Bool           { self._selectMode }
        public var automationMode: Bool       { self._automationMode }
        public var automationInterval: Double { self._automationInterval }

        public init(_ cellGridView: CellGridView) {
            self._viewBackground     = cellGridView.viewBackground
            self._viewTransparency   = cellGridView.viewTransparency
            self._viewScaling        = cellGridView.viewScaling
            self._cellSize           = cellGridView.cellSize
            self._cellPadding        = cellGridView.cellPadding
            self._cellShape          = cellGridView.cellShape
            self._cellColor          = cellGridView.cellColor
            self._cellSizeMax        = cellGridView.cellSizeMax
            self._cellSizeInnerMin   = cellGridView.cellSizeInnerMin
            self._cellPaddingMax     = cellGridView.cellPaddingMax
            self._gridColumns        = cellGridView.gridColumns
            self._gridRows           = cellGridView.gridRows
            self._cellAntialiasFade  = cellGridView.cellAntialiasFade
            self._cellRoundedRadius  = cellGridView.cellRoundedRadius
            self._restrictShift      = cellGridView.restrictShift
            self._unscaledZoom       = cellGridView.unscaledZoom
            self._selectMode         = cellGridView.selectMode
            self._automationMode     = cellGridView.automationMode
            self._automationInterval = cellGridView.automationInterval
        }

        open func with(viewBackground value: Colour) -> Config {
            var copy = self ; copy._viewBackground = value; return copy
        }

        public func with(viewTransparency value: UInt8) -> Config {
            var copy = self ; copy._viewTransparency = value; return copy
        }

        public func with(viewScaling value: Bool) -> Config {
            var copy = self ; copy._viewScaling = value; return copy
        }

        public func with(cellSize value: Int) -> Config {
            var copy = self ; copy._cellSize = value; return copy
        }

        public func with(cellPadding value: Int) -> Config {
            var copy = self ; copy._cellPadding = value; return copy
        }

        public func with(cellShape value: CellShape) -> Config {
            var copy = self ; copy._cellShape = value; return copy
        }

        public func with(cellColor value: Colour) -> Config {
            var copy = self ; copy._cellColor = value; return copy
        }

        public func with(cellSizeMax value: Int) -> Config {
            var copy = self ; copy._cellSizeMax = value; return copy
        }

        public func with(cellSizeInnerMin value: Int) -> Config {
            var copy = self ; copy._cellSizeInnerMin = value; return copy
        }

        public func with(cellPaddingMax value: Int) -> Config {
            var copy = self ; copy._cellPaddingMax = value; return copy
        }

        public func with(gridColumns value: Int) -> Config {
            var copy = self ; copy._gridColumns = value; return copy
        }

        public func with(gridRows value: Int) -> Config {
            var copy = self ; copy._gridRows = value; return copy
        }

        public func with(cellAntialiasFade value: Float) -> Config {
            var copy = self ; copy._cellAntialiasFade = value; return copy
        }

        public func with(cellRoundedRadius value: Float) -> Config {
            var copy = self ; copy._cellRoundedRadius = value; return copy
        }

        public func with(restrictShift value: Bool) -> Config {
            var copy = self ; copy._restrictShift = value; return copy
        }

        public func with(unscaledZoom value: Bool) -> Config {
            var copy = self ; copy._unscaledZoom = value; return copy
        }

        public func with(selectMode value: Bool) -> Config {
            var copy = self ; copy._selectMode = value; return copy
        }

        public func with(automationMode value: Bool) -> Config {
            var copy = self ; copy._automationMode = value; return copy
        }

        public func with(automationInterval value: Double) -> Config {
            var copy = self ; copy._automationInterval = automationInterval ; return copy
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

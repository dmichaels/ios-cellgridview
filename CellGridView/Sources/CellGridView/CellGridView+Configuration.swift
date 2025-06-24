import SwiftUI
import Utils

extension CellGridView
{
    /*
    public struct Defaults
    {
        // The size related properties here (being outward facing) are unscaled.

        public static let viewBackground: Colour = Colour.darkGray
        public static let viewTransparency: UInt8 = Colour.OPAQUE
        public static let viewScaling: Bool = true

        public static let cellSize: Int = 25
        public static let cellSizeFit: Bool = false
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
        public static let cellPreferredSizeMarginMax: Int = 30
        public static let centerCells: Bool = false

        // Wraparound support is incomplete, half-baked, and of questionable utility.
        //
        public static let gridWrapAround: Bool = false
    }
    */

    public struct Configuration
    {
        private var _viewBackground: Colour?
        private var _viewTransparency: UInt8?
        private var _viewScaling: Bool?

        private var _cellSize: Int?
        private var _cellPadding: Int?
        private var _cellShape: CellShape?
        private var _cellColor: Colour?
        private var _cellAntialiasFade: Float?
        private var _cellRoundedRadius: Float?

        private var _cellSizeMax: Int?
        private var _cellSizeInnerMin: Int?
        private var _cellPaddingMax: Int?

        private var _gridColumns: Int?
        private var _gridRows: Int?

        private var _restrictShift: Bool?
        private var _unscaledZoom: Bool?

        private var _selectMode: Bool?
        private var _automationMode: Bool?
        private var _automationInterval: Double?

        public init(
            viewBackground: Colour? = nil,
            viewTransparency: UInt8? = nil,
            viewScaling: Bool? = nil,
            cellSize: Int? = nil,
            cellPadding: Int? = nil,
            cellShape: CellShape? = nil,
            cellColor: Colour? = nil,
            cellAntialiasFade: Float? = nil,
            cellRoundedRadius: Float? = nil,
            cellSizeMax: Int? = nil,
            cellSizeInnerMin: Int? = nil,
            cellPaddingMax: Int? = nil,
            gridColumns: Int? = nil,
            gridRows: Int? = nil,
            restrictShift: Bool? = nil,
            unscaledZoom: Bool? = nil,
            selectMode: Bool? = nil,
            automationMode: Bool? = nil,
            automationInterval: Double? = nil
        ) {
            self._viewBackground = viewBackground
            self._viewTransparency = viewTransparency
            self._viewScaling = viewScaling
            self._cellSize = cellSize
            self._cellPadding = cellPadding
            self._cellShape = cellShape
            self._cellColor = cellColor
            self._cellAntialiasFade = cellAntialiasFade
            self._cellRoundedRadius = cellRoundedRadius
            self._cellSizeMax = cellSizeMax
            self._cellSizeInnerMin = cellSizeInnerMin
            self._cellPaddingMax = cellPaddingMax
            self._gridColumns = gridColumns
            self._gridRows = gridRows
            self._restrictShift = restrictShift
            self._unscaledZoom = unscaledZoom
            self._selectMode = selectMode
            self._automationMode = automationMode
            self._automationInterval = automationInterval
        }

        public init(_ cellGridView: CellGridView) {
            self._viewBackground = cellGridView.viewBackground
            self._viewTransparency = cellGridView.viewTransparency
            self._viewScaling = cellGridView.viewScaling
            self._cellSize = cellGridView.cellSize
            self._cellPadding = cellGridView.cellPadding
            self._cellShape = cellGridView.cellShape
            self._cellColor = cellGridView.cellColor
            self._cellAntialiasFade = cellGridView.cellAntialiasFade
            self._cellRoundedRadius = cellGridView.cellRoundedRadius
            self._cellSizeMax = cellGridView.cellSizeMax
            self._cellSizeInnerMin = cellGridView.cellSizeInnerMin
            self._cellPaddingMax = cellGridView.cellPaddingMax
            self._gridColumns = cellGridView.gridColumns
            self._gridRows = cellGridView.gridRows
            self._restrictShift = cellGridView.restrictShift
            self._unscaledZoom = cellGridView.unscaledZoom
            self._selectMode = cellGridView.selectMode
            self._automationMode = cellGridView.automationMode
            self._automationInterval = cellGridView.automationInterval
        }

        public func with(viewBackground: Colour) -> Configuration {
            var copy = self ; copy._viewBackground = viewBackground ; return copy
        }

        public func with(viewTransparency: UInt8) -> Configuration {
            var copy = self ; copy._viewTransparency = viewTransparency ; return copy
        }

        public func with(viewScaling: Bool) -> Configuration {
            var copy = self ; copy._viewScaling = viewScaling ; return copy
        }

        public func with(cellSize: Int) -> Configuration {
            var copy = self ; copy._cellSize = max(cellSize, 1) ; return copy
        }

        public func with(cellPadding: Int) -> Configuration {
            var copy = self ; copy._cellPadding = max(cellPadding, 0) ; return copy
        }

        public func with(cellShape: CellShape) -> Configuration {
            var copy = self ; copy._cellShape = cellShape ; return copy
        }

        public func with(cellColor: Colour) -> Configuration {
            var copy = self ; copy._cellColor = cellColor ; return copy
        }

        public func with(gridColumns: Int) -> Configuration {
            var copy = self ; copy._gridColumns = gridColumns ; return copy
        }

        public func with(gridRows: Int) -> Configuration {
            var copy = self ; copy._gridRows = gridRows ; return copy
        }

        public func with(cellAntialiasFade: Float) -> Configuration {
            var copy = self ; copy._cellAntialiasFade = cellAntialiasFade ; return copy
        }

        public func with(cellRoundedRadius: Float) -> Configuration {
            var copy = self ; copy._cellRoundedRadius = cellRoundedRadius ; return copy
        }

        public func with(cellSizeMax: Int) -> Configuration {
            var copy = self ; copy._cellSizeMax = cellSizeMax ; return copy
        }

        public func with(cellSizeInnerMin: Int) -> Configuration {
            var copy = self ; copy._cellSizeInnerMin = cellSizeInnerMin ; return copy
        }

        public func with(cellPaddingMax: Int) -> Configuration {
            var copy = self ; copy._cellPaddingMax = cellPaddingMax ; return copy
        }

        public func with(restrictShift: Bool) -> Configuration {
            var copy = self ; copy._restrictShift = restrictShift ; return copy
        }

        public func with(unscaledZoom: Bool) -> Configuration {
            var copy = self ; copy._unscaledZoom = unscaledZoom ; return copy
        }

        public func with(selectMode: Bool) -> Configuration {
            var copy = self ; copy._selectMode = selectMode ; return copy
        }

        public func with(automationMode: Bool) -> Configuration {
            var copy = self ; copy._automationMode = automationMode ; return copy
        }

        public func with(automationInterval: Double) -> Configuration {
            var copy = self ; copy._automationInterval = automationInterval ; return copy
        }

        public var viewBackground: Colour? { self._viewBackground }
        public var viewTransparency: UInt8? { self._viewTransparency }
        public var viewScaling: Bool? { self._viewScaling }
        public var cellSize: Int? { self._cellSize }
        public var cellPadding: Int? { self._cellPadding }
        public var cellShape: CellShape? { self._cellShape }
        public var gridColumns: Int? { self._gridColumns }
        public var gridRows: Int? { self._gridRows }
        public var cellColor: Colour? { self._cellColor }
        public var cellAntialiasFade: Float? { self._cellAntialiasFade }
        public var cellRoundedRadius: Float? { self._cellRoundedRadius }
        public var cellSizeMax: Int? { self._cellSizeMax }
        public var cellSizeInnerMin: Int? { self._cellSizeInnerMin }
        public var cellPaddingMax: Int? { self._cellPaddingMax }
        public var restrictShift: Bool? { self._restrictShift }
        public var unscaledZoom: Bool? { self._unscaledZoom }
        public var selectMode: Bool? { self._selectMode }
        public var automationMode: Bool? { self._automationMode }
        public var automationInterval: Double? { self._automationInterval }

        public func defaultsFrom(_ cellGridView: CellGridView) -> Configuration {
            var config: Configuration  = self
            config._viewBackground     = self._viewBackground     ?? cellGridView.viewBackground
            config._viewTransparency   = self._viewTransparency   ?? cellGridView.viewTransparency
            config._viewScaling        = self._viewScaling        ?? cellGridView.viewScaling
            config._cellSize           = self._cellSize           ?? cellGridView.cellSize
            config._cellPadding        = self._cellPadding        ?? cellGridView.cellPadding
            config._cellShape          = self._cellShape          ?? cellGridView.cellShape
            config._gridColumns        = self._gridColumns        ?? cellGridView.gridColumns
            config._gridRows           = self._gridRows           ?? cellGridView.gridRows
            config._cellColor          = self._cellColor          ?? CellGridView.Defaults.cellColor
            config._cellAntialiasFade  = self._cellAntialiasFade  ?? cellGridView.cellAntialiasFade
            config._cellRoundedRadius  = self._cellRoundedRadius  ?? cellGridView.cellRoundedRadius
            config._cellSizeMax        = self._cellSizeMax        ?? cellGridView.cellSizeMax
            config._cellSizeInnerMin   = self._cellSizeInnerMin   ?? cellGridView.cellSizeInnerMin
            config._cellPaddingMax     = self._cellPaddingMax     ?? cellGridView.cellPaddingMax
            config._restrictShift      = self._restrictShift      ?? cellGridView.restrictShift
            config._unscaledZoom       = self._unscaledZoom       ?? cellGridView.unscaledZoom
            config._selectMode         = self._selectMode         ?? cellGridView.selectMode
            config._automationMode     = self._automationMode     ?? cellGridView.automationMode
            config._automationInterval = self._automationInterval ?? cellGridView.automationInterval
            return config
        }
    }

    /*
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
    */
}

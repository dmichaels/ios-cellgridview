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
        public static let cellSizeFit: Bool = false
        public static let cellPadding: Int = 1
        public static let cellShape: CellShape = CellShape.rounded
        public static let cellForeground: Colour = Colour.white

        public static let cellAntialiasFade: Float = 0.6  // smaller -> smoother
        public static let cellRoundedRectangleRadius: Float = 0.25

        public static let cellSizeMax: Int = 200
        public static let cellSizeInnerMin: Int = 1
        public static let cellPaddingMax: Int = 8
        public static let cellPreferredSizeMarginMax: Int = 30

        public static let gridColumns: Int = 0
        public static let gridRows: Int = 0
        public static let gridCenter: Bool = false
        public static let restrictShiftStrict: Bool = true
        public static let unscaledZoom: Bool = false
        public static let automationInterval: Double = 0.5

        public static let selectMode: Bool = true
        public static let automationMode: Bool = true
        //
        // Wraparound support is incomplete, half-baked, and of questionable utility.
        //
        public static let gridWrapAround: Bool = false
    }

    public struct Configuration
    {
        private var _viewBackground: Colour?
        private var _viewTransparency: UInt8?
        private var _viewScaling: Bool?

        private var _cellSize: Int?
        private var _cellSizeFit: Bool?
        private var _cellPadding: Int?
        private var _cellShape: CellShape?
        private var _cellForeground: Colour?
        private var _cellAntialiasFade: Float?
        private var _cellRoundedRectangleRadius: Float?

        private var _gridColumns: Int?
        private var _gridRows: Int?
        private var _gridCenter: Bool?

        private var _restrictShiftStrict: Bool?
        private var _unscaledZoom: Bool?

        private var _selectMode: Bool?
        private var _automationMode: Bool?
        private var _automationInterval: Double?

        public init(
            viewBackground: Colour? = nil,
            viewTransparency: UInt8? = nil,
            viewScaling: Bool? = nil,
            cellSize: Int? = nil,
            cellSizeFit: Bool? = nil,
            cellPadding: Int? = nil,
            cellShape: CellShape? = nil,
            cellForeground: Colour? = nil,
            cellAntialiasFade: Float? = nil,
            cellRoundedRectangleRadius: Float? = nil,
            gridColumns: Int? = nil,
            gridRows: Int? = nil,
            gridCenter: Bool? = nil,
            restrictShiftStrict: Bool? = nil,
            unscaledZoom: Bool? = nil,
            selectMode: Bool? = nil,
            automationMode: Bool? = nil,
            automationInterval: Double? = nil
        ) {
            self._viewBackground = viewBackground
            self._viewTransparency = viewTransparency
            self._viewScaling = viewScaling
            self._cellSize = cellSize
            self._cellSizeFit = cellSizeFit
            self._cellPadding = cellPadding
            self._cellShape = cellShape
            self._cellForeground = cellForeground
            self._gridColumns = gridColumns
            self._gridRows = gridRows
            self._gridCenter = gridCenter
            self._restrictShiftStrict = restrictShiftStrict
            self._unscaledZoom = unscaledZoom
            self._selectMode = selectMode
            self._automationMode = automationMode
            self._automationInterval = automationInterval
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

        public func with(cellSizeFit: Bool) -> Configuration {
            var copy = self ; copy._cellSizeFit = cellSizeFit ; return copy
        }

        public func with(cellPadding: Int) -> Configuration {
            var copy = self ; copy._cellPadding = max(cellPadding, 0) ; return copy
        }

        public func with(cellShape: CellShape) -> Configuration {
            var copy = self ; copy._cellShape = cellShape ; return copy
        }

        public func with(cellForeground: Colour) -> Configuration {
            var copy = self ; copy._cellForeground = cellForeground ; return copy
        }

        public func with(cellAntialiasFade: Float) -> Configuration {
            var copy = self ; copy._cellAntialiasFade = cellAntialiasFade ; return copy
        }

        public func with(cellRoundedRectangleRadius: Float) -> Configuration {
            var copy = self ; copy._cellRoundedRectangleRadius = cellRoundedRectangleRadius ; return copy
        }

        public func with(gridColumns: Int) -> Configuration {
            var copy = self ; copy._gridColumns = gridColumns ; return copy
        }

        public func with(gridRows: Int) -> Configuration {
            var copy = self ; copy._gridRows = gridRows ; return copy
        }

        public func with(gridCenter: Bool) -> Configuration {
            var copy = self ; copy._gridCenter = gridCenter ; return copy
        }

        public func with(restrictShiftStrict: Bool) -> Configuration {
            var copy = self ; copy._restrictShiftStrict = restrictShiftStrict ; return copy
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
        public var cellSizeFit: Bool? { self._cellSizeFit }
        public var cellPadding: Int? { self._cellPadding }
        public var cellShape: CellShape? { self._cellShape }
        public var cellForeground: Colour? { self._cellForeground }
        public var cellAntialiasFade: Float? { self._cellAntialiasFade }
        public var cellRoundedRectangleRadius: Float? { self._cellRoundedRectangleRadius }
        public var gridColumns: Int? { self._gridColumns }
        public var gridRows: Int? { self._gridRows }
        public var gridCenter: Bool? { self._gridCenter }
        public var restrictShiftStrict: Bool? { self._restrictShiftStrict }
        public var unscaledZoom: Bool? { self._unscaledZoom }
        public var selectMode: Bool? { self._selectMode }
        public var automationMode: Bool? { self._automationMode }
        public var automationInterval: Double? { self._automationInterval }
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

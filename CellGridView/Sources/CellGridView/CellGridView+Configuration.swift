import SwiftUI
import Utils

extension CellGridView
{
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

        public init(
            viewBackground: Colour? = nil,
            viewTransparency: UInt8? = nil,
            viewScaling: Bool? = nil,
            cellSize: Int? = nil,
            cellSizeFit: Bool? = nil,
            cellPadding: Int? = nil,
            cellShape: CellShape? = nil,
            cellForeground: Colour? = nil
        ) {
            self._viewBackground = viewBackground
            self._viewTransparency = viewTransparency
            self._viewScaling = viewScaling
            self._cellSize = cellSize
            self._cellSizeFit = cellSizeFit
            self._cellPadding = cellPadding
            self._cellShape = cellShape
            self._cellForeground = cellForeground
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

        public var viewBackground: Colour? { self._viewBackground }
        public var viewTransparency: UInt8? { self._viewTransparency }
        public var viewScaling: Bool? { self._viewScaling }
        public var cellSize: Int? { self._cellSize }
        public var cellSizeFit: Bool? { self._cellSizeFit }
        public var cellPadding: Int? { self._cellPadding }
        public var cellShape: CellShape? { self._cellShape }
        public var cellForeground: Colour? { self._cellForeground }
    }

    public final var minimumCellSize: Int {
        self.minimumCellSize(cellPadding: self.cellPadding)
    }

    public final func minimumCellSize(cellPadding: Int? = nil) -> Int {
        let cellPadding: Int = max(0, cellPadding ?? self.cellPadding)
        return constrainCellSize(Defaults.cellSizeInnerMin, cellPadding: cellPadding)
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
        return cellSize.clamped(cellSizeInnerMin + (cellPadding * 2)...cellSizeMax)
    }

    internal final func constrainCellPadding(_ cellPadding: Int, scaled: Bool = false) -> Int {
        let cellPaddingMax: Int = self.scaled(Defaults.cellPaddingMax)
        let cellPadding: Int = !scaled ? self.scaled(cellPadding) : cellPadding
        return cellPadding.clamped(0...cellPaddingMax)
    }
}

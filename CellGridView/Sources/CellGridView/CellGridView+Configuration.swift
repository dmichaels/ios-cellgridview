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

        public func with(viewBackground: Colour?) -> Configuration {
            var copy = self ; copy._viewBackground = viewBackground ; return copy
        }

        public func with(viewTransparency: UInt8?) -> Configuration {
            var copy = self ; copy._viewTransparency = viewTransparency ; return copy
        }

        public func with(viewScaling: Bool?) -> Configuration {
            var copy = self ; copy._viewScaling = viewScaling ; return copy
        }

        public func with(cellSize: Int?) -> Configuration {
            var copy = self ; copy._cellSize = cellSize ; return copy
        }

        public func with(cellSizeFit: Bool?) -> Configuration {
            var copy = self ; copy._cellSizeFit = cellSizeFit ; return copy
        }

        public func with(cellPadding: Int?) -> Configuration {
            var copy = self ; copy._cellPadding = cellPadding ; return copy
        }

        public func with(cellShape: CellShape?) -> Configuration {
            var copy = self ; copy._cellShape = cellShape ; return copy
        }

        public func with(cellForeground: Colour?) -> Configuration {
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
}

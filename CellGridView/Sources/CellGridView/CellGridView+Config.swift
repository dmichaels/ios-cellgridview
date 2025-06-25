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
        public var viewBackground: Colour
        public var viewTransparency: UInt8
        public var viewScaling: Bool

        public var cellSize: Int
        public var cellPadding: Int
        public var cellShape: CellShape
        public var cellColor: Colour

        public var cellSizeMax: Int
        public var cellSizeInnerMin: Int
        public var cellPaddingMax: Int

        public var gridColumns: Int
        public var gridRows: Int

        public var cellAntialiasFade: Float
        public var cellRoundedRadius: Float
        public var restrictShift: Bool
        public var unscaledZoom: Bool

        public var selectMode: Bool
        public var automationMode: Bool
        public var automationInterval: Double

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

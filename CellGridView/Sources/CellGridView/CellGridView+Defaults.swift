import SwiftUI
import Utils

extension CellGridView
{
    public struct Defaults
    {
        // The size related properties here (being outward facing) are unscaled.

        public static let viewBackground: Colour     = Colour.darkGray
        public static let viewTransparency: UInt8    = Colour.OPAQUE
        public static let viewScaling: Bool          = true

        public static let cellSize: Int              = 25
        public static let cellPadding: Int           = 1
        public static let cellShape: CellShape       = CellShape.rounded
        public static let cellShading: Bool          = false
        public static let cellColor: Colour          = Colour.white

        public static let cellSizeMax: Int           = 200
        public static let cellSizeInnerMin: Int      = 1
        public static let cellPaddingMax: Int        = 8

        public static let gridColumns: Int           = 0
        public static let gridRows: Int              = 0
        public static let gridColumnsMin: Int        = 2
        public static let gridRowsMin: Int           = 2
        public static let gridColumnsMax: Int        = 5000
        public static let gridRowsMax: Int           = 5000
        public static let fit: CellGridView.Fit      = CellGridView.Fit.disabled
        public static let center: Bool               = false

        public static let cellAntialiasFade: Float   = 0.60 // smaller -> smoother
        public static let cellRoundedRadius: Float   = 0.25 // smaller -> squarer
        public static let restrictShift: Bool        = true
        public static let unscaledZoom: Bool         = false

        public static let selectMode: Bool             = true
        public static let selectRandomMode: Bool       = false
        public static let selectRandomInterval: Double = 0.25
        public static let automationMode: Bool         = true
        public static let automationInterval: Double   = 0.50

        // Only used on CellGridView.initialize
        //
        public static let fitMarginMax: Int          = 100

        // Wraparound support is incomplete, half-baked, and of questionable utility.
        //
        public static let gridWrapAround: Bool       = false
    }
}

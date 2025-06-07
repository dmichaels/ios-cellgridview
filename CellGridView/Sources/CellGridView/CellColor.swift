import SwiftUI

// This is actually only currently used for the background color of the screen/image,
// i.e. for the backgound color if the inset margin is greater than zero.
//
public struct CellColor: Equatable, Sendable
{
    // These values works with Utils.Memory.fastcopy NOT using value.bigEndian;
    // if these were the opposite (RSHIFT: 24, GSHIFT: 16, BSHIFT: 8, ALPHA: 0),
    // then we would need to use value.bigEndian there; slightly faster without.

    public static let RSHIFT: Int   =   0
    public static let GSHIFT: Int   =   8
    public static let BSHIFT: Int   =  16
    public static let ASHIFT: Int   =  24
    public static let OPAQUE: UInt8 = 255

    // Private immutable individual RGBA color values.

    private let _red:   UInt8
    private let _green: UInt8
    private let _blue:  UInt8
    private let _alpha: UInt8

    // Sundry constructors.

    public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8, alpha: UInt8 = CellColor.OPAQUE) {
        self._red   = red
        self._green = green
        self._blue  = blue
        self._alpha = alpha
    }

    public init(_ red: Int, _ green: Int, _ blue: Int, alpha: Int = Int(CellColor.OPAQUE)) {
        self._red   = UInt8(red)
        self._green = UInt8(green)
        self._blue  = UInt8(blue)
        self._alpha = UInt8(alpha)
    }

    public init(_ color: Color) {
        //
        // N.B. Creating UIColor many times an be sloooooooooooooow. 
        // For example doing this 1200 * 2100 = 2,520,000 times can take
        // nearly 2 full seconds. Be careful to avoid this if/when possible.
        //
        self.init(UIColor(color))
    }

    private init(_ color: UIColor) {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self._red   = UInt8(red   * 255)
            self._green = UInt8(green * 255)
            self._blue  = UInt8(blue  * 255)
            self._alpha = UInt8(alpha * 255)
        }
        else {
            self._red   = 0
            self._green = 0
            self._blue  = 0
            self._alpha = CellColor.OPAQUE
        }
    }

    // Readonly immutable property access.

    public var red:   UInt8 { self._red   }
    public var green: UInt8 { self._green }
    public var blue:  UInt8 { self._blue  }
    public var alpha: UInt8 { self._alpha }

    public var value: UInt32 {
        get {
            (UInt32(self._red)   << CellColor.RSHIFT) |
            (UInt32(self._green) << CellColor.GSHIFT) |
            (UInt32(self._blue)  << CellColor.BSHIFT) |
            (UInt32(self._alpha) << CellColor.ASHIFT)
        }
    }

    public var color: Color {
        Color(red: Double(self.red) / 255.0, green: Double(self.green) / 255.0, blue: Double(self.blue) / 255.0)
    }

    public var hex: String {
        String(format: "%02X", self.value)
    }

    // For convenience just replicate all known builtin UIColor colors.

    public static let black: CellColor = CellColor(UIColor.black)
    public static let blue: CellColor = CellColor(UIColor.blue)
    public static let brown: CellColor = CellColor(UIColor.brown)
    public static let clear: CellColor = CellColor(UIColor.clear)
    public static let cyan: CellColor = CellColor(UIColor.cyan)
    public static let darkGray: CellColor = CellColor(UIColor.darkGray)
    public static let gray: CellColor = CellColor(UIColor.gray)
    public static let green: CellColor = CellColor(UIColor.green)
    public static let lightGray: CellColor = CellColor(UIColor.lightGray)
    public static let magenta: CellColor = CellColor(UIColor.magenta)
    public static let orange: CellColor = CellColor(UIColor.orange)
    public static let purple: CellColor = CellColor(UIColor.purple)
    public static let red: CellColor = CellColor(UIColor.red)
    public static let white: CellColor = CellColor(UIColor.white)
    public static let yellow: CellColor = CellColor(UIColor.yellow)

    // For future use.

    public static func random(mode: CellColorMode = CellColorMode.color) -> CellColor {
        if (mode == CellColorMode.monochrome) {
            let value: UInt8 = UInt8.random(in: 0...1) * 255
            return CellColor(value, value, value)
        }
        else if (mode == CellColorMode.grayscale) {
            let value = UInt8.random(in: 0...255)
            return CellColor(value, value, value)
        }
        else {
            let rgb = UInt32.random(in: 0...0xFFFFFF)
            return CellColor(UInt8((rgb >> 16) & 0xFF), UInt8((rgb >> 8) & 0xFF), UInt8(rgb & 0xFF))
        }
    }

    public func darken(by amount: CGFloat = 0.3) -> CellColor {
        CellColor(CellColor.darken(self.color, by: amount))
    }

    private static func darken(_ color: Color, by amount: CGFloat) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return Color(hue: hue, saturation: saturation, brightness: max(brightness - amount, 0), opacity: alpha)
        }
        return color // fallback
    }
}

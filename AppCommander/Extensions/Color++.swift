//
//  Color++.swift
//  Evyrest
//
//  Created by Lakhan Lothiyi on 30/11/2022.
//

import Foundation
import SwiftUI


//
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    init?(_ hex: String) {
        var str = hex
        if str.hasPrefix("#") {
            str.removeFirst()
        }
        if str.count == 3 {
            str = String(repeating: str[str.startIndex], count: 2)
            + String(repeating: str[str.index(str.startIndex, offsetBy: 1)], count: 2)
            + String(repeating: str[str.index(str.startIndex, offsetBy: 2)], count: 2)
        } else if !str.count.isMultiple(of: 2) || str.count > 8 {
            return nil
        }
        guard let color = UInt64(str, radix: 16)
        else {
            return nil
        }
        if str.count == 2 {
            let gray = Double(Int(color) & 0xFF) / 255
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
        } else if str.count == 4 {
            let gray = Double(Int(color >> 8) & 0x00FF) / 255
            let alpha = Double(Int(color) & 0x00FF) / 255
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
        } else if str.count == 6 {
            let red = Double(Int(color >> 16) & 0x0000FF) / 255
            let green = Double(Int(color >> 8) & 0x0000FF) / 255
            let blue = Double(Int(color) & 0x0000FF) / 255
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        } else if str.count == 8 {
            let red = Double(Int(color >> 24) & 0x000000FF) / 255
            let green = Double(Int(color >> 16) & 0x000000FF) / 255
            let blue = Double(Int(color >> 8) & 0x000000FF) / 255
            let alpha = Double(Int(color) & 0x000000FF) / 255
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else {
            return nil
        }
    }
}




//extension UIColor {
//    public convenience init?(hex: String) {
//        let r, g, b, a: CGFloat
//
//        let start = hex.index(hex.startIndex, offsetBy: hex.hasPrefix("#") ? 1 : 0)
//        let hexColor = String(hex[start...])
//
//        if hexColor.count == 8 {
//            let scanner = Scanner(string: hexColor)
//            var hexNumber: UInt64 = 0
//
//            if scanner.scanHexInt64(&hexNumber) {
//                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
//                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
//                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
//                a = CGFloat(hexNumber & 0x000000ff) / 255
//
//                self.init(red: r, green: g, blue: b, alpha: a)
//                return
//            }
//        } else if hexColor.count == 6 {
//            let scanner = Scanner(string: hexColor)
//            var hexNumber: UInt64 = 0
//
//            if scanner.scanHexInt64(&hexNumber) {
//                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
//                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
//                b = CGFloat(hexNumber & 0x0000ff) / 255
//
//                self.init(red: r, green: g, blue: b, alpha: 1)
//                return
//            }
//        }
//
//        return nil
//    }
//}

extension Color {
    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }

    func toHex(includeAlpha: Bool = false, bgra: Bool = false) -> [UInt8] {
        guard let components = self.cgColor.components, components.count >= 3 else {
            return includeAlpha ? [UInt8(255), UInt8(255), UInt8(255), UInt8(255)] : [UInt8(255), UInt8(255), UInt8(255)]
        }

        let red: UInt8 = UInt8(components[0] * 255)
        let green: UInt8 = UInt8(components[1] * 255)
        let blue: UInt8 = UInt8(components[2] * 255)
        var alpha: UInt8 = UInt8(1.0)

        if components.count >= 4 {
            alpha = UInt8(components[3] * 255)
        }

        if includeAlpha {
            if bgra {
                return [blue, green, red, alpha]
            } else {
                return [red, green, blue, alpha]
            }
        } else {
            if bgra {
                return [blue, green, red]
            }
            return [red, green, blue]
        }
    }
}

extension Color {
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.rgba.red),
                  green: Double(uiColor.rgba.green),
                  blue: Double(uiColor.rgba.blue),
                  opacity: Double(uiColor.rgba.alpha))
    }
}

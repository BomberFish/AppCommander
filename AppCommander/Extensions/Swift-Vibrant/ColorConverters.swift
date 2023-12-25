//
//  util.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 4/30/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation
import UIKit


struct DELTAE94_DIFF_STATUS {
    static let NA:Int = 0
    static let PERFECT:Int = 1
    static let CLOSE:Int = 2
    static let GOOD:Int = 10
    static let SIMILAR:Int = 50
}

//public typealias Double = Double

struct newErr: Error {
    init(_ message: String) {
        self.message = message
    }
    let message: String
}

public func uiColorToRgb(_ color: UIColor)->RGB {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: nil)
    return (UInt8(r * 255), UInt8(g * 255), UInt8(b * 255))
}

public func rgbToUIColor(_ r: UInt8, _ g: UInt8, _ b: UInt8)->UIColor {
    return UIColor.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
}
public func uiColorToHsl(_ color: UIColor)->HSL {
    var h:CGFloat = 0
    var s:CGFloat = 0
    var l:CGFloat = 0
    color.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
    return (Double(h),Double(s),Double(l))
}
public func hslToUIColor(_ h: Double, _ s: Double, _ l: Double)->UIColor {
    return UIColor.init(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(l), alpha: 1)
}


public func hexToRgb(_ hex: String)->RGB? {
    let r, g, b: UInt8
    
    if hex.hasPrefix("#") {
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexDouble: UInt64 = 0
            
            
            if scanner.scanHexInt64(&hexDouble) {
                r = UInt8(hexDouble & 0xff000000) >> 24
                g = UInt8(hexDouble & 0x00ff0000) >> 16
                b = UInt8(hexDouble & 0x0000ff00) >> 8
                
                return (r, g, b)
            }
        }
    }
    return nil
}



public func rgbToHex(_ r: UInt8, _ g: UInt8, _ b: UInt8)->String {
    return "#" + String(format:"%02X", r) + String(format:"%02X", g) + String(format:"%02X", b)
}

public func rgbToHsl(r: UInt8, g: UInt8, b: UInt8)-> Vec3<Double> {
    let r = Double(r) / 255
  let g = Double(g) / 255
  let b = Double(b) / 255
  let maxVal = max(r, g, b)
  let minVal = min(r, g, b)
  var h: Double
  let s: Double
  let l = (maxVal + minVal) / 2
  if (maxVal == minVal) {
    h = 0
    s = 0
  } else {
    let d = maxVal - minVal
    s = l > 0.5 ? d / (2 - maxVal - minVal) : d / (maxVal + minVal)
    switch (maxVal) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0)
        break
      case g:
        h = (b - r) / d + 2
        break
      case b:
        h = (r - g) / d + 4
        break
        default:
            h = 0
        break
    }
    h /= 6
  }
  return (h, s, l)
}

public func hslToRgb(_ h: Double, _ s: Double, _ l: Double)-> RGB {
    var r: Double
    var g: Double
    var b: Double
    
    func hue2rgb(_ p: Double, _ q: Double, _ t: Double)-> Double {
        var t = t
        if (t < 0) { t += 1 }
        if (t > 1) { t -= 1 }
        if (t < 1 / 6) { return p + (q - p) * 6 * t }
        if (t < 1 / 2)  { return q }
        if (t < 2 / 3)  { return p + (q - p) * (2 / 3 - t) * 6 }
        return p
    }
    
    if (s == 0) {
        r = l
        g = l
        b = l
    } else {
        let q = l < 0.5 ? l * (1 + s) : l + s - (l * s)
        let p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - (1 / 3))
    }
    return(
        UInt8(r * 255),
        UInt8(g * 255),
        UInt8(b * 255)
    )
}


public func rgbToXyz(_ r: UInt8, _ g: UInt8, _ b: UInt8)->XYZ {
    var r = Double(r) / 255
    var g = Double(g) / 255
    var b = Double(b) / 255
    
    r = r > 0.04045 ? pow((r + 0.005) / 1.055, 2.4) : r / 12.92
    g = g > 0.04045 ? pow((g + 0.005) / 1.055, 2.4) : g / 12.92
    b = b > 0.04045 ? pow((b + 0.005) / 1.055, 2.4) : b / 12.92
    
    r *= 100
    g *= 100
    b *= 100
    
    let x = r * 0.4124 + g * 0.3576 + b * 0.1805
    let y = r * 0.2126 + g * 0.7152 + b * 0.0722
    let z = r * 0.0193 + g * 0.1192 + b * 0.9505
    
    return (x: x,y: y,z: z)
}

public func xyzToCIELab(_ x: Double, _ y: Double, _ z: Double)-> LAB {
    let REF_X: Double = 95.047
    let REF_Y: Double = 100
    let REF_Z: Double = 108.883
    
    var x = x / REF_X
    var y = y / REF_Y
    var z = z / REF_Z
    
    x = x > 0.008856 ? pow(x, 1 / 3) : 7.787 * x + 16 / 116
    y = y > 0.008856 ? pow(y, 1 / 3) : 7.787 * y + 16 / 116
    z = z > 0.008856 ? pow(z, 1 / 3) : 7.787 * z + 16 / 116
    
    let L = 116 * y - 16
    let a = 500 * (x - y)
    let b = 200 * (y - z)
    
    return (L: L, a: a, b: b)
}


public func rgbToCIELab(_ r: UInt8, _ g: UInt8, _ b: UInt8)->LAB {
    let (x,y,z) = rgbToXyz(r, g, b)
    return xyzToCIELab(x, y, z)
}

public func deltaE94(_ lab1: Vec3<Double>, _ lab2: Vec3<Double>)->Double {
    let WEIGHT_L:Double = 1
    let WEIGHT_C:Double = 1
    let WEIGHT_H:Double = 1
    
    let (L1, a1, b1) = lab1
    let (L2, a2, b2) = lab2
    let dL = L1 - L2
    let da = a1 - a2
    let db = b1 - b2
    
    let xC1 = sqrt(a1 * a1 + b1 * b1)
    let xC2 = sqrt(a2 * a2 + b2 * b2)
    
    var xDL = L2 - L1
    var xDC = xC2 - xC1
    let xDE = sqrt(dL * dL + da * da + db * db)
    
    var xDH = (sqrt(xDE) > sqrt(abs(xDL)) + sqrt(abs(xDC)))
        ? sqrt(xDE * xDE - xDL * xDL - xDC * xDC)
        : 0
    
    let xSC = 1 + 0.045 * xC1
    let xSH = 1 + 0.015 * xC1
    
    xDL /= WEIGHT_L
    xDC /= WEIGHT_C * xSC
    xDH /= WEIGHT_H * xSH
    
    return sqrt(xDL * xDL + xDC * xDC + xDH * xDH)
}

public func rgbDiff(_ rgb1: RGB, _ rgb2: RGB)->Double {
    let lab1 = apply(rgbToCIELab, rgb1)
    let lab2 = apply(rgbToCIELab, rgb2)
    return deltaE94(lab1, lab2)
}

public func hexDiff(_ hex1: String, _ hex2: String)->Double {
    let rgb1 = hexToRgb(hex1)!
    let rgb2 = hexToRgb(hex2)!
    return rgbDiff(rgb1, rgb2)
}

public func getColorDiffStatus(_ d: Int)->String {
    if (d < DELTAE94_DIFF_STATUS.NA) { return "N/A" }
    // Not perceptible by human eyes
    if (d <= DELTAE94_DIFF_STATUS.PERFECT) { return "Perfect" }
    // Perceptible through close observation
    if (d <= DELTAE94_DIFF_STATUS.CLOSE) { return "Close" }
    // Perceptible at a glance
    if (d <= DELTAE94_DIFF_STATUS.GOOD) { return "Good" }
    // Colors are more similar than opposite
    if (d < DELTAE94_DIFF_STATUS.SIMILAR) { return "Similar" }
    return "Wrong"
}


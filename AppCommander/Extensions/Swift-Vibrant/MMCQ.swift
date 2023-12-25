//
//  MMCQ.swift
//  ColorThiefSwift
//
//  Created by Kazuki Ohara on 2017/02/11.
//  Copyright © 2019 Kazuki Ohara. All rights reserved.
//
//  License
//  -------
//  MIT License
//  https://github.com/yamoridon/ColorThiefSwift/blob/master/LICENSE
//
//  Thanks
//  ------
//  Lokesh Dhakar - for the original Color Thief JavaScript version
//  http://lokeshdhakar.com/projects/color-thief/
//  Sven Woltmann - for the fast Java Implementation
//  https://github.com/SvenWoltmann/color-thief-java

import Foundation
import UIKit

/// MMCQ (modified median cut quantization) algorithm from
/// the Leptonica library (http://www.leptonica.com/).

/// Get reduced-space color index for a pixel.
///
/// - Parameters:
///   - red: the red value
///   - green: the green value
///   - blue: the blue value
/// - Returns: the color index


public struct SVColor {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    public func makeUIColor() -> UIColor {
        return UIColor(red: CGFloat(r) / CGFloat(255), green: CGFloat(g) / CGFloat(255), blue: CGFloat(b) / CGFloat(255), alpha: CGFloat(1))
    }
}

enum ColorChannel {
    case r
    case g
    case b
}

/// 3D color space box.


/// Color map.
open class ColorMap {
    
    var vboxes = [VBox]()
    
    func push(_ vbox: VBox) {
        vboxes.append(vbox)
    }
    
    open func makePalette() -> [SVColor] {
        return vboxes.map { $0.getAverage() }
    }
    
    open func makeNearestColor(to color: SVColor) -> SVColor {
        var nearestDistance = Int.max
        var nearestColor = SVColor(r: 0, g: 0, b: 0)
        
        for vbox in vboxes {
            let vbColor = vbox.getAverage()
            let dr = abs(Int(color.r) - Int(vbColor.r))
            let dg = abs(Int(color.g) - Int(vbColor.g))
            let db = abs(Int(color.b) - Int(vbColor.b))
            let distance = dr + dg + db
            if distance < nearestDistance {
                nearestDistance = distance
                nearestColor = vbColor
            }
        }
        
        return nearestColor
    }
}

/// Histo (1-d array, giving the number of pixels in each quantized region of color space), or null on error.
internal func makeHistogramAndVBox(from pixels: [UInt8], quality: Int, ignoreWhite: Bool) -> ([Int], VBox) {
    var histogram = [Int](repeating: 0, count: histogramSize)
    var rMin = UInt8.max
    var rMax = UInt8.min
    var gMin = UInt8.max
    var gMax = UInt8.min
    var bMin = UInt8.max
    var bMax = UInt8.min
    
    let pixelCount = pixels.count / 4
    for i in stride(from: 0, to: pixelCount, by: quality) {
        let a = pixels[i * 4 + 0]
        let b = pixels[i * 4 + 1]
        let g = pixels[i * 4 + 2]
        let r = pixels[i * 4 + 3]
        
        // If pixel is not mostly opaque or white
        guard a >= 125 && !(ignoreWhite && r > 250 && g > 250 && b > 250) else {
            continue
        }
        
        let shiftedR = r >> UInt8(rightShift)
        let shiftedG = g >> UInt8(rightShift)
        let shiftedB = b >> UInt8(rightShift)
        
        // find min/max
        rMin = min(rMin, shiftedR)
        rMax = max(rMax, shiftedR)
        gMin = min(gMin, shiftedG)
        gMax = max(gMax, shiftedG)
        bMin = min(bMin, shiftedB)
        bMax = max(bMax, shiftedB)
        
        // increment histgram
        let index = makeColorIndexOf(red: Int(shiftedR), green: Int(shiftedG), blue: Int(shiftedB))
        histogram[index] += 1
    }
    
    let vbox = VBox(rMin: rMin, rMax: rMax, gMin: gMin, gMax: gMax, bMin: bMin, bMax: bMax, histogram: histogram)
    return (histogram, vbox)
}

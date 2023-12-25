//
//  Vbox.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

class VBox {
    
    var rMin: UInt8
    var rMax: UInt8
    var gMin: UInt8
    var gMax: UInt8
    var bMin: UInt8
    var bMax: UInt8
    
    private let histogram: [Int]
    
    private var average: SVColor?
    private var volume: Int?
    private var count: Int?
    
    init(rMin: UInt8, rMax: UInt8, gMin: UInt8, gMax: UInt8, bMin: UInt8, bMax: UInt8, histogram: [Int]) {
        self.rMin = rMin
        self.rMax = rMax
        self.gMin = gMin
        self.gMax = gMax
        self.bMin = bMin
        self.bMax = bMax
        self.histogram = histogram
    }
    
    init(vbox: VBox) {
        self.rMin = vbox.rMin
        self.rMax = vbox.rMax
        self.gMin = vbox.gMin
        self.gMax = vbox.gMax
        self.bMin = vbox.bMin
        self.bMax = vbox.bMax
        self.histogram = vbox.histogram
    }
    
    func makeRange(min: UInt8, max: UInt8) -> CountableRange<Int> {
        if min <= max {
            return Int(min) ..< Int(max + 1)
        } else {
            return Int(max) ..< Int(max)
        }
    }
    
    var rRange: CountableRange<Int> { return makeRange(min: rMin, max: rMax) }
    var gRange: CountableRange<Int> { return makeRange(min: gMin, max: gMax) }
    var bRange: CountableRange<Int> { return makeRange(min: bMin, max: bMax) }
    
    /// Get 3 dimensional volume of the color space
    ///
    /// - Parameter force: force recalculate
    /// - Returns: the volume
    func getVolume(forceRecalculate force: Bool = false) -> Int {
        if let volume = volume, !force {
            return volume
        } else {
            let volume = (Int(rMax) - Int(rMin) + 1) * (Int(gMax) - Int(gMin) + 1) * (Int(bMax) - Int(bMin) + 1)
            self.volume = volume
            return volume
        }
    }
    
    /// Get total count of histogram samples
    ///
    /// - Parameter force: force recalculate
    /// - Returns: the volume
    func getCount(forceRecalculate force: Bool = false) -> Int {
        if let count = count, !force {
            return count
        } else {
            var count = 0
            for i in rRange {
                for j in gRange {
                    for k in bRange {
                        let index = makeColorIndexOf(red: i, green: j, blue: k)
                        count += histogram[index]
                    }
                }
            }
            self.count = count
            return count
        }
    }
    
    func getAverage(forceRecalculate force: Bool = false) -> SVColor {
        if let average = average, !force {
            return average
        } else {
            var ntot = 0
            
            var rSum = 0
            var gSum = 0
            var bSum = 0
            
            for i in rRange {
                for j in gRange {
                    for k in bRange {
                        let index = makeColorIndexOf(red: i, green: j, blue: k)
                        let hval = histogram[index]
                        ntot += hval
                        rSum += Int(Double(hval) * (Double(i) + 0.5) * Double(multiplier))
                        gSum += Int(Double(hval) * (Double(j) + 0.5) * Double(multiplier))
                        bSum += Int(Double(hval) * (Double(k) + 0.5) * Double(multiplier))
                    }
                }
            }
            
            let average: SVColor
            if ntot > 0 {
                let r = UInt8(rSum / ntot)
                let g = UInt8(gSum / ntot)
                let b = UInt8(bSum / ntot)
                average = SVColor(r: r, g: g, b: b)
            } else {
                let r = UInt8(min(multiplier * (Int(rMin) + Int(rMax) + 1) / 2, 255))
                let g = UInt8(min(multiplier * (Int(gMin) + Int(gMax) + 1) / 2, 255))
                let b = UInt8(min(multiplier * (Int(bMin) + Int(bMax) + 1) / 2, 255))
                average = SVColor(r: r, g: g, b: b)
            }
            
            self.average = average
            return average
        }
    }
    
    
    func rgb() -> RGB {
        let color = self.getAverage()
        return (color.r, color.g, color.b)
    }
    
    func widestColorChannel() -> ColorChannel {
        let rWidth = rMax - rMin
        let gWidth = gMax - gMin
        let bWidth = bMax - bMin
        switch max(rWidth, gWidth, bWidth) {
            case rWidth:
                return .r
            case gWidth:
                return .g
            default:
                return .b
        }
    }
    
}

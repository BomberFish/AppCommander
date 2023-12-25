//
//  Util.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

internal func applyMedianCut(with histogram: [Int], vbox: VBox) -> [VBox] {
    guard vbox.getCount() != 0 else {
        return []
    }
    
    // only one pixel, no split
    guard vbox.getCount() != 1 else {
        return [vbox]
    }
    
    // Find the partial sum arrays along the selected axis.
    var total = 0
    var partialSum = [Int](repeating: -1, count: vboxLength) // -1 = not set / 0 = 0
    
    let axis = vbox.widestColorChannel()
    switch axis {
        case .r:
            for i in vbox.rRange {
                var sum = 0
                for j in vbox.gRange {
                    for k in vbox.bRange {
                        let index = makeColorIndexOf(red: i, green: j, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
        }
        case .g:
            for i in vbox.gRange {
                var sum = 0
                for j in vbox.rRange {
                    for k in vbox.bRange {
                        let index = makeColorIndexOf(red: j, green: i, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
        }
        case .b:
            for i in vbox.bRange {
                var sum = 0
                for j in vbox.rRange {
                    for k in vbox.gRange {
                        let index = makeColorIndexOf(red: j, green: k, blue: i)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
        }
    }
    
    var lookAheadSum = [Int](repeating: -1, count: vboxLength) // -1 = not set / 0 = 0
    for (i, sum) in partialSum.enumerated() where sum != -1 {
        lookAheadSum[i] = total - sum
    }
    
    return cut(by: axis, vbox: vbox, partialSum: partialSum, lookAheadSum: lookAheadSum, total: total)
}

internal func cut(by axis: ColorChannel, vbox: VBox, partialSum: [Int], lookAheadSum: [Int], total: Int) -> [VBox] {
    let vboxMin: Int
    let vboxMax: Int
    
    switch axis {
        case .r:
            vboxMin = Int(vbox.rMin)
            vboxMax = Int(vbox.rMax)
        case .g:
            vboxMin = Int(vbox.gMin)
            vboxMax = Int(vbox.gMax)
        case .b:
            vboxMin = Int(vbox.bMin)
            vboxMax = Int(vbox.bMax)
    }
    
    for i in vboxMin ... vboxMax where partialSum[i] > total / 2 {
        let vbox1 = VBox(vbox: vbox)
        let vbox2 = VBox(vbox: vbox)
        
        let left = i - vboxMin
        let right = vboxMax - i
        
        var d2: Int
        if left <= right {
            d2 = min(vboxMax - 1, i + right / 2)
        } else {
            // 2.0 and cast to int is necessary to have the same
            // behaviour as in JavaScript
            d2 = max(vboxMin, Int(Double(i - 1) - Double(left) / 2.0))
        }
        
        // avoid 0-count
        while d2 < 0 || partialSum[d2] <= 0 {
            d2 += 1
        }
        var count2 = lookAheadSum[d2]
        while count2 == 0 && d2 > 0 && partialSum[d2 - 1] > 0 {
            d2 -= 1
            count2 = lookAheadSum[d2]
        }
        
        // set dimensions
        switch axis {
            case .r:
                vbox1.rMax = UInt8(d2)
                vbox2.rMin = UInt8(d2 + 1)
            case .g:
                vbox1.gMax = UInt8(d2)
                vbox2.gMin = UInt8(d2 + 1)
            case .b:
                vbox1.bMax = UInt8(d2)
                vbox2.bMin = UInt8(d2 + 1)
        }
        
        return [vbox1, vbox2]
    }
    
    fatalError("VBox can't be cut")
}

internal func iterate(over queue: inout [VBox], comparator: (VBox, VBox) -> Bool, target: Int, histogram: [Int]) {
    var color = 1

    for _ in 0 ..< maxIterations {
        guard let vbox = queue.last else {
            return
        }

        if vbox.getCount() == 0 {
            queue.sort(by: comparator)
            continue
        }
        queue.removeLast()

        // do the cut
        let vboxes = applyMedianCut(with: histogram, vbox: vbox)
        queue.append(vboxes[0])
        if vboxes.count == 2 {
            queue.append(vboxes[1])
            color += 1
        }
        queue.sort(by: comparator)

        if color >= target {
            return
        }
    }
}

internal func compareByCount(_ a: VBox, _ b: VBox) -> Bool {
    return a.getCount() < b.getCount()
}

internal func compareByProduct(_ a: VBox, _ b: VBox) -> Bool {
    let aCount = a.getCount()
    let bCount = b.getCount()
    let aVolume = a.getVolume()
    let bVolume = b.getVolume()
    
    if aCount == bCount {
        // If count is 0 for both (or the same), sort by volume
        return aVolume < bVolume
    } else {
        // Otherwise sort by products
        let aProduct = Int64(aCount) * Int64(aVolume)
        let bProduct = Int64(bCount) * Int64(bVolume)
        return aProduct < bProduct
    }
}

func makeColorIndexOf(red: Int, green: Int, blue: Int) -> Int {
    return (red << (2 * signalBits)) + (green << signalBits) + blue
}

func apply<T, V>(_ fn: (T) -> V, _ args: T) -> V {
    return fn(args)
}

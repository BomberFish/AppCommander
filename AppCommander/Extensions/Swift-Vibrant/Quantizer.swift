//
//  Quantize.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

public class Quantizer {
    public typealias quantizer = (_ pixels: [UInt8], _ options: Vibrant.Options)->[Swatch]
    
    public static let defaultQuantizer: quantizer = Quantizer().quantize
    
    private func quantize(pixels: [UInt8], options: Vibrant.Options)->[Swatch] {
        let quality = options.quality
        let colorcount = options.colorCount
        return Quantizer.vibrantQuantizer(pixels: pixels, quality: quality, colorCount: colorcount)
    }
    
    private static func splitBoxes (_ pq: inout [VBox], _ target: Int, hist: [Int]) {
        var lastSize = pq.count
        while pq.count < target {
            let vbox = pq.popLast()
            
            if (vbox != nil && vbox!.getCount() > 0) {
                let vboxes = applyMedianCut(with: hist, vbox: vbox!)
                let vbox1 = vboxes.count > 0 ? vboxes[0] : nil
                let vbox2 = vboxes.count > 1 ? vboxes[1] : nil
                pq.append(vbox1!)
                if vbox2 != nil && vbox2!.getCount() > 0 { pq.append(vbox2!) }
                
                if pq.count == lastSize {
                    break
                } else {
                    lastSize = pq.count
                }
            } else {
                break
            }
        }
    }
    
    static func vibrantQuantizer(pixels: [UInt8], quality: Int, colorCount: Int)->[Swatch] {
        let (hist, vbox) = makeHistogramAndVBox(from: pixels, quality: quality, ignoreWhite: false)
        var pq = [vbox]
        splitBoxes(&pq, Int(fractionByPopulation * Double(colorCount)), hist: hist)
        pq.sort { (a, b) -> Bool in
            a.getCount() * a.getVolume() > b.getCount() * b.getVolume()
        }
        splitBoxes(&pq, colorCount - pq.count, hist: hist)
        return generateSwatches(pq)
    }
    
    private static func generateSwatches (_ pq: [VBox])->[Swatch] {
        return pq.map { (box) in
            let color = box.rgb()
            return Swatch(color, box.getCount())
        }
    }
}

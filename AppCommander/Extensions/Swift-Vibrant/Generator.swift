
//
//  default.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 4/30/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import UIKit

public class Generator {
    
    public typealias generator = (_ swatches: [Swatch])->Palette
    
    public struct Options {
        var targetDarkLuma:  Double = 0.26
        var maxDarkLuma:  Double = 0.45
        var minLightLuma:  Double = 0.55
        var targetLightLuma:  Double = 0.74
        var minNormalLuma:  Double = 0.3
        var targetNormalLuma:  Double = 0.5
        var maxNormalLuma:  Double = 0.7
        var targetMutesSaturation:  Double = 0.3
        var maxMutesSaturation:  Double = 0.4
        var targetVibrantSaturation:  Double = 1.0
        var minVibrantSaturation:  Double = 0.35
        var weightSaturation:  Double = 3.0
        var weightLuma:  Double = 6.5
        var weightPopulation:  Double = 0.5
    }
    var options: Options
    init(options: Options) {
        self.options = options
    }
    
    
    public static let defaultGenerator:generator = Generator(options: Options()).generate
    
    private func generate(swatches: [Swatch])->Palette {
        let maxPopulation = findMaxPopulation(swatches: swatches)
        var palette = generateVariationColors(swatches: swatches, maxPopulation: maxPopulation, opts: options)
        palette = generateEmptySwatches(palette: palette, opts: options)
        return palette
    }
    
    func findMaxPopulation( swatches: [Swatch])->Int {
        var p: Int = 0
        swatches.forEach { (s: Swatch) in
            p = max(p, s.population)
        }
        return p
    }
    
    func isAlreadySelected (palette: Palette, s: Swatch)->Bool {
        return palette.Vibrant == s ||
            palette.DarkVibrant == s ||
            palette.LightVibrant == s ||
            palette.Muted == s ||
            palette.DarkMuted == s ||
            palette.LightMuted == s
    }
    
    func createComparisonValue (
        saturation: Double, targetSaturation: Double,
        luma: Double, targetLuma: Double,
        population: Int, maxPopulation: Int, opts: Options) -> Double {
        
        func weightedMean (values: Double...)->Double {
            var sum: Double = 0
            var weightSum: Double = 0
            var i = 0
            while i < values.count {
                let value = values[i]
                let weight = values[i + 1]
                sum += value * weight
                weightSum += weight
                i+=2
            }
            return sum / weightSum
        }
        
        func invertDiff (value: Double, targetValue: Double)->Double {
            return 1 - abs(value - targetValue)
        }
        
        
        return weightedMean(
            values: invertDiff(value: saturation, targetValue: targetSaturation), opts.weightSaturation,
            invertDiff(value: luma, targetValue: targetLuma), opts.weightLuma,
            Double(population) / Double(maxPopulation), opts.weightPopulation
        )
    }
    
    func findColorVariation (palette: Palette, swatches: [Swatch], maxPopulation: Int,
                              targetLuma: Double,
                              minLuma: Double,
                              maxLuma: Double,
                              targetSaturation: Double,
                              minSaturation: Double,
                              maxSaturation: Double,
                              opts: Options)->Swatch? {
        
        var max: Swatch? = nil
        var maxValue: Double = 0
        
        swatches.forEach({swatch in
            let (_,s,l) = swatch.hsl
            
            if (s >= minSaturation && s <= maxSaturation &&
                l >= minLuma && l <= maxLuma &&
                !isAlreadySelected(palette: palette, s: swatch)
                ) {
                let value = createComparisonValue(saturation: s, targetSaturation: targetSaturation, luma: l, targetLuma: targetLuma, population: swatch.population, maxPopulation: maxPopulation, opts: opts)
                if (max == nil || value > maxValue) {
                    max = swatch
                    maxValue = value
                }
            }
        })
        return max
    }
    
    func generateVariationColors (swatches: [Swatch], maxPopulation: Int, opts: Options)->Palette {
        
        var palette = Palette()
        
        palette.Vibrant = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                              targetLuma: opts.targetNormalLuma,
                                              minLuma: opts.minNormalLuma,
                                              maxLuma: opts.maxNormalLuma,
                                              targetSaturation: opts.targetVibrantSaturation,
                                              minSaturation: opts.minVibrantSaturation,
                                              maxSaturation: 1,
                                              opts: opts
        )
        
        palette.LightVibrant = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                                   targetLuma: opts.targetLightLuma,
                                                   minLuma: opts.minLightLuma,
                                                   maxLuma: 1,
                                                   targetSaturation: opts.targetVibrantSaturation,
                                                   minSaturation: opts.minVibrantSaturation,
                                                   maxSaturation: 1,
                                                   opts: opts
        )
        
        palette.DarkVibrant = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                                  targetLuma: opts.targetDarkLuma,
                                                  minLuma: 0,
                                                  maxLuma: opts.maxDarkLuma,
                                                  targetSaturation: opts.targetVibrantSaturation,
                                                  minSaturation: opts.minVibrantSaturation,
                                                  maxSaturation: 1,
                                                  opts: opts
        )
        
        palette.Muted = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                            targetLuma: opts.targetNormalLuma,
                                            minLuma: opts.minNormalLuma,
                                            maxLuma: opts.maxNormalLuma,
                                            targetSaturation: opts.targetMutesSaturation,
                                            minSaturation: 0,
                                            maxSaturation: opts.maxMutesSaturation,
                                            opts: opts
        )
        
        palette.LightMuted = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                                 targetLuma: opts.targetLightLuma,
                                                 minLuma: opts.minLightLuma,
                                                 maxLuma: 1,
                                                 targetSaturation: opts.targetMutesSaturation,
                                                 minSaturation: 0,
                                                 maxSaturation: opts.maxMutesSaturation,
                                                 opts: opts
        )
        
        palette.DarkMuted = findColorVariation(palette: palette, swatches: swatches, maxPopulation: maxPopulation,
                                                targetLuma: opts.targetDarkLuma,
                                                minLuma: 0,
                                                maxLuma: opts.maxDarkLuma,
                                                targetSaturation: opts.targetMutesSaturation,
                                                minSaturation: 0,
                                                maxSaturation: opts.maxMutesSaturation,
                                                opts: opts
        )
        return palette
        
    }
    //
    func generateEmptySwatches (palette: Palette, opts: Options)->Palette {
        
        var palette = palette
        //function _generateEmptySwatches (palette: Palette, maxPopulation: number, opts: DefaultGeneratorOptions): void {
        if (palette.Vibrant == nil && palette.DarkVibrant == nil && palette.LightVibrant == nil) {
            if (palette.DarkVibrant == nil && palette.DarkMuted != nil) {
                var (h, s, l) = palette.DarkMuted!.hsl
                l = opts.targetDarkLuma
                palette.DarkVibrant = Swatch(hslToRgb(h, s, l), 0)
            }
            if (palette.LightVibrant == nil && palette.LightMuted != nil) {
                var (h, s, l) = palette.LightMuted!.hsl
                l = opts.targetDarkLuma
                palette.DarkVibrant = Swatch(hslToRgb(h, s, l), 0)
            }
        }
        if (palette.Vibrant == nil && palette.DarkVibrant != nil) {
            var (h, s, l) = palette.DarkVibrant!.hsl
            l = opts.targetNormalLuma
            palette.Vibrant =  Swatch(hslToRgb(h, s, l), 0)
        } else if (palette.Vibrant == nil && palette.LightVibrant != nil) {
            var (h, s, l) = palette.LightVibrant!.hsl
            l = opts.targetNormalLuma
            palette.Vibrant =  Swatch(hslToRgb(h, s, l), 0)
        }
        if (palette.DarkVibrant == nil && palette.Vibrant != nil) {
            var (h, s, l) = palette.Vibrant!.hsl
            l = opts.targetDarkLuma
            palette.DarkVibrant =  Swatch(hslToRgb(h, s, l), 0)
        }
        if (palette.LightVibrant == nil && palette.Vibrant != nil) {
            var (h, s, l) = palette.Vibrant!.hsl
            l = opts.targetLightLuma
            palette.LightVibrant =  Swatch(hslToRgb(h, s, l), 0)
        }
        if (palette.Muted == nil && palette.Vibrant != nil) {
            var (h, s, l) = palette.Vibrant!.hsl
            l = opts.targetMutesSaturation
            palette.Muted =  Swatch(hslToRgb(h, s, l), 0)
        }
        if (palette.DarkMuted == nil && palette.DarkVibrant != nil) {
            var (h, s, l) = palette.DarkVibrant!.hsl
            l = opts.targetMutesSaturation
            palette.DarkMuted =  Swatch(hslToRgb(h, s, l), 0)
        }
        if (palette.LightMuted == nil && palette.LightVibrant != nil) {
            var (h, s, l) = palette.LightVibrant!.hsl
            l = opts.targetMutesSaturation
            palette.LightMuted =  Swatch(hslToRgb(h, s, l), 0)
        }
        return palette
    }
}
/**
 ````
 const DefaultGenerator: Generator = (swatches: Array<Swatch>, opts?: DefaultGeneratorOptions): Palette => {
 opts = <DefaultGeneratorOptions>defaults({}, opts, DefaultOpts)
 let maxPopulation = _findMaxPopulation(swatches)
 
 let palette = _generateVariationColors(swatches, maxPopulation, opts)
 _generateEmptySwatches(palette, maxPopulation, opts)
 
 return palette
 }
 ````
 */

//
//  Image.swift
//  swift-vibrant-ios
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation
import UIKit

public class SVImage {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func applyFilter(_ filter: Filter)->[UInt8] {
        guard let imageData = self.getImageData() else {
            return []
        }
        var pixels = imageData
        let n = pixels.count / 4
        var offset: Int
        var r, g, b, a: UInt8
        
        for i in 0..<n {
            offset = i * 4
            r = pixels[offset + 0]
            g = pixels[offset + 1]
            b = pixels[offset + 2]
            a = pixels[offset + 3]
            
            if (!filter.f(r,g,b,a)) {
                pixels[offset + 3] = 0
            }
        }
        return imageData
    }
    
    func getImageData()->[UInt8]? {
        return SVImage.makeBytes(from: self.image)
    }
    
    func scaleTo(size maxSize: CGFloat?, quality: Int) {
        let width = image.size.width
        let height = image.size.height
        
        var ratio:CGFloat = 1.0
        if maxSize != nil && maxSize! > 0 {
            let maxSide = max(width, height)
            if maxSide > CGFloat(maxSize!) {
                ratio = CGFloat(maxSize!) / maxSide
            }
        } else {
            ratio = 1 / CGFloat(quality)
        }
        if ratio < 1 {
            self.scale(by: ratio)
        }
    }
    
    func scale(by scale: CGFloat) {
        self.image = SVImage.scaleImage(image: self.image, by: scale)
    }
    
    private static func scaleImage(image: UIImage, by scale: CGFloat)->UIImage {
        if scale == 1 { return image }
        
        let imageRef = image.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        
        var bounds = CGSize(width: width, height: height)
        
        bounds.width = CGFloat(width) * scale
        bounds.height = CGFloat(height) * scale
        
        UIGraphicsBeginImageContext(bounds)
        image.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageCopy ?? image
    }
    
    private static func makeBytes(from image: UIImage) -> [UInt8]? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        if isCompatibleImage(cgImage) {
            return makeBytesFromCompatibleImage(cgImage)
        } else {
            return makeBytesFromIncompatibleImage(cgImage)
        }
    }
    
    private static func isCompatibleImage(_ cgImage: CGImage) -> Bool {
        guard let colorSpace = cgImage.colorSpace else {
            return false
        }
        if colorSpace.model != .rgb {
            return false
        }
        let bitmapInfo = cgImage.bitmapInfo
        let alpha = bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let alphaRequirement = (alpha == CGImageAlphaInfo.noneSkipLast.rawValue || alpha == CGImageAlphaInfo.last.rawValue)
        let byteOrder = bitmapInfo.rawValue & CGBitmapInfo.byteOrderMask.rawValue
        let byteOrderRequirement = (byteOrder == CGBitmapInfo.byteOrder32Little.rawValue)
        if !(alphaRequirement && byteOrderRequirement) {
            return false
        }
        if cgImage.bitsPerComponent != 8 {
            return false
        }
        if cgImage.bitsPerPixel != 32 {
            return false
        }
        if cgImage.bytesPerRow != cgImage.width * 4 {
            return false
        }
        return true
    }
    private static func makeBytesFromCompatibleImage(_ image: CGImage) -> [UInt8]? {
        guard let dataProvider = image.dataProvider else {
            return nil
        }
        guard let data = dataProvider.data else {
            return nil
        }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        return rawData
    }

    private static func makeBytesFromIncompatibleImage(_ image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
                return nil
        }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return rawData
    }
}

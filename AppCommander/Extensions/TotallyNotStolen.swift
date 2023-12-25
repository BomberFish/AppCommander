//
//  TotallyNotStolenFromPicasso.swift
//  Picasso
//
//  Created by sourcelocation on 12/08/2023.
//

import Foundation

//func addEmptyData(matchingSize: Int, to plist: [String: Any]) throws -> Data {
//    var newPlist = plist
//    // create the new data
//    guard var newData = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { throw "Unable to get data" }
//    // add data if too small
//    // while loop to make data match because recursive function didn't work
//    // very slow, will hopefully improve
//    if newData.count == matchingSize {
//        return newData
//    }
//    var newDataSize = newData.count
//    var added = matchingSize - newDataSize
//    if added < 0 {
//        added = 1
//    }
//    var count = 0
//    while newDataSize != matchingSize && count < 200 {
//        count += 1
//        if added < 0 {
//            print("[Plist] LESS THAN 0")
//            break
//        }
//        newPlist.updateValue(String(repeating: "#", count: added), forKey: "kfd")
//        do {
//            newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
//        } catch {
//            newDataSize = -1
//            print("[Plist] ERROR SERIALIZING DATA")
//            break
//        }
//        newDataSize = newData.count
//        if count < 5 {
//            // max out this method at 5 if it isn't working
//            added += matchingSize - newDataSize
//        } else {
//            if newDataSize > matchingSize {
//                added -= 1
//            } else if newDataSize < matchingSize {
//                added += 1
//            }
//        }
//    }
//
//    return newData
//}
//
//
//func padDataWithPaddingBytes(_ inputData: Data, padToBytes: Int) -> Data {
//    print("paddmethodcalled_woahs")
//    var data = inputData
//    let trailerData = Array(data.suffix(32))
//    var offsetTableOffset = trailerData[24..<32].withUnsafeBytes {
//        $0.load(as: UInt64.self).bigEndian
//    }
//    //  print("og count: \(data.count)")
//    if trailerData[0] == 170 && trailerData[1] == 170 {
//        let amountOfPaddingBytes = trailerData[2..<6]
//        var amountOfPadding = 0
//        for byte in amountOfPaddingBytes {
//            amountOfPadding = amountOfPadding << 8
//            amountOfPadding = amountOfPadding | Int(byte)
//        }
////    print("padding digits: \(amountOfPadding)")
//        offsetTableOffset = offsetTableOffset - UInt64(amountOfPadding)
//
//        data =
//            data[0..<Int(offsetTableOffset)]
//                + data[(Int(offsetTableOffset) + amountOfPadding)..<data.count]
////    print("count after padding removal: \(data.count)")
//    }
//
//    if data.count > padToBytes {
//        print("data is too big")
//        return data
//    }
//
//    let amountOfBytesBeingAdded = padToBytes - data.count
//    let amountOfBytesBeingAddedAs4Bytes = withUnsafeBytes(
//        of: Int32(amountOfBytesBeingAdded).bigEndian, Array.init)
//
//    var newData = data[0..<Int(offsetTableOffset)]
//    //  print("added \(newData.count) bytes - original data upto offsetTable")
//
//    newData += Data(repeating: 0xAA, count: amountOfBytesBeingAdded)
//    //  print("added \(amountOfBytesBeingAdded) bytes of padding...")
//
//    let beingAddedOffsetPositions = data[Int(offsetTableOffset)..<data.count - 32]
//    newData += beingAddedOffsetPositions
//    //  print("added \(beingAddedOffsetPositions) bytes - offset table")
//
//    newData += Data(repeating: 0xAA, count: 2)
//    newData += Data(amountOfBytesBeingAddedAs4Bytes)
//    newData += Data(trailerData[6..<24])
//    newData += withUnsafeBytes(
//        of: (Int(offsetTableOffset) + amountOfBytesBeingAdded).bigEndian, Array.init)
//
//    //  print(newData)
//
//    guard let _ = try? PropertyListSerialization.propertyList(from: newData, options: [], format: nil)
//    else {
//        print("failed for unknown reason")
//        return data
//    }
//    return newData
//}

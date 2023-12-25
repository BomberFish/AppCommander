//
//  File.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import Foundation

import Foundation

func insaneNewPaddingMethodUsingBytes(_ inputData: Data, padToBytes: Int) -> Data {

  let data = inputData
  let trailerData = Array(data.suffix(32))

  var amountOfPadding = 0
  var offsetTableOffset = trailerData[24..<32].withUnsafeBytes {
    $0.load(as: UInt64.self).bigEndian
  }
  // print("offsetTableOffset: \(offsetTableOffset)")
  var numObjects = trailerData[8..<16].withUnsafeBytes {
    $0.load(as: UInt64.self).bigEndian
  }
  let offsetSize = trailerData[6]
  if offsetSize < 1 {
    print("[padding.err] offsetSize is less than 1 - \(inputData.count) -> \(padToBytes)")
    return data
  }
  // print("offsetSize: \(offsetSize)")

  // 0xFF and 0xFA = enlargen table method
  if trailerData[0] == 255 && trailerData[1] == 250 {
    // print("[padding] enlargen table method detected")
    let amountOfPaddingBytes = trailerData[2..<6]
    for byte in amountOfPaddingBytes {
      amountOfPadding = amountOfPadding << 8
      amountOfPadding = amountOfPadding | Int(byte)
    }
    numObjects = numObjects - UInt64(amountOfPadding)
  }

  // 0xFF and 0xFE = pretable padding method
  if trailerData[0] == 255 && trailerData[1] == 254 {
    // print("[padding] pretable padding method detected")
    let amountOfPaddingBytes = trailerData[2..<6]
    for byte in amountOfPaddingBytes {
      amountOfPadding = amountOfPadding << 8
      amountOfPadding = amountOfPadding | Int(byte)
    }
    offsetTableOffset = offsetTableOffset - UInt64(amountOfPadding)
  }

  if amountOfPadding == 0 {
    // print("[padding] no padding detected")
  }

  if data.count - amountOfPadding > padToBytes || data.count - amountOfPadding > Int32.max {
    print("[padding.err] data is too big - \(inputData.count) -> \(padToBytes)")
    return data
  }

  let amountOfBytesBeingAdded = padToBytes - (data.count - amountOfPadding)

  //pretable padding method first, if fails, enlargen table method

  var newData = data[0..<Int(offsetTableOffset)]
  newData += Data(repeating: 0xFF, count: amountOfBytesBeingAdded)
  newData += data[(Int(offsetTableOffset) + amountOfPadding)..<data.count - 32]
  // 0xFF and 0xFE = pretable padding method
  newData += Data([0xFF, 0xFE])
  newData += Data(withUnsafeBytes(of: Int32(amountOfBytesBeingAdded).bigEndian, Array.init))
  newData += Data(trailerData[6..<24])
  newData += withUnsafeBytes(
    of: (Int(offsetTableOffset) + amountOfBytesBeingAdded).bigEndian, Array.init)

  guard let _ = try? PropertyListSerialization.propertyList(from: newData, options: [], format: nil)
  else {
    // print("[padding.err] pretable padding method failed - \(inputData.count) -> \(padToBytes)")
    var newData = data[0..<Int(offsetTableOffset)]
    newData +=
      data[Int(offsetTableOffset)..<Int(offsetTableOffset) + (Int(numObjects) * Int(offsetSize))]
    newData += Data(repeating: 0x00, count: amountOfBytesBeingAdded)
    newData += Data([0xFF, 0xFA])
    newData += Data(withUnsafeBytes(of: Int32(amountOfBytesBeingAdded).bigEndian, Array.init))
    newData += Data(trailerData[6..<8])
    newData += Data(
      withUnsafeBytes(
        of: ((Int64(numObjects))
          + (Int64(amountOfBytesBeingAdded) / Int64(offsetSize))).bigEndian,
        Array.init))
    newData += Data(trailerData[16..<32])

    guard
      let _ = try? PropertyListSerialization.propertyList(from: newData, options: [], format: nil)
    else {
      // print("[padding.err] enlargen table method failed - \(inputData.count) -> \(padToBytes)")
      print("[padding.err] both methods failed - \(inputData.count) -> \(padToBytes)")
      return data
    }
    print("[padding.lar] success! - \(inputData.count) -> \(padToBytes)")
    return newData
  }

  print("[padding.pre] success! - \(inputData.count) -> \(padToBytes)")
  return newData
}

//
//  Print.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-05.
//

import Foundation
import OSLog

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let data = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(data, terminator: terminator)
    Logger().debug("\(data)")
//    remLog(data + terminator)
//    log += "\(data)\n"
}

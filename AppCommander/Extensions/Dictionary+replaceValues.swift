//
//  Dictionary+replaceValues.swift
//  Picasso
//
//  Created by sourcelocation on 09/08/2023.
//

import Foundation

extension Dictionary {
    /// Replaces all values in the dictionary with the given value if the key matches the given predicate recursively
    /// - Parameters:
    ///   - predicate: The predicate to match the keys against
    ///   - value: The value to replace the matched values with
    mutating func replaceValues(where predicate: (Key) -> Bool, with value: Value) {
        for (key, value1) in self {
            if let dict = value1 as? [Key: Value] {
                var dict = dict
                dict.replaceValues(where: predicate, with: value)
                self[key] = dict as? Value
            } else if predicate(key) {
                self[key] = value
            }
        }
    }
}

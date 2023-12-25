//
//  SafeIndex.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-09-04.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

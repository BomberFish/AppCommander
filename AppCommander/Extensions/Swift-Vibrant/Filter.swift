//
//  Filter.swift
//  swift-vibrant-ios
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

public class Filter {
    public typealias filterFunction = (_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: UInt8)->Bool
    
    var f: filterFunction
    var id: String
    
    public init(_ f: @escaping filterFunction) {
        self.f = f
        self.id = UUID().uuidString
    }
    
    private init(_ f: @escaping filterFunction, id: String) {
        self.f = f
        self.id = id
    }
    
    public static func combineFilters (filters: [Filter])->Filter? {
        if filters.count == 0 { return nil }
        let newFilterFunction:filterFunction = { r,g,b,a in
            if a == 0 { return false }
            for f in filters {
                if !f.f(r,g,b,a) { return false }
            }
            return true
        }
        return Filter(newFilterFunction)
    }
    
    public static let defaultFilter: Filter = Filter({r, g, b, a in
        return a >= 125 && !(r > 250 && g > 250 && b > 250)
    }, id: "default")
}

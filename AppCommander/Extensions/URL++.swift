//
//  URL++.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-22.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    var isSymLink: Bool {
        (try? resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink == true
    }
}

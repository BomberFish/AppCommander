// bomberfish
// String+LocalizedError.swift – Picasso
// created 2023-10-09

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

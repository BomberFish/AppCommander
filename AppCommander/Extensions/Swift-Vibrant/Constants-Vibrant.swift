//
//  Constants.swift
//  swift-vibrant
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

internal let signalBits = 5
internal let rightShift = 8 - signalBits
internal let multiplier = 1 << rightShift
internal let histogramSize = 1 << (3 * signalBits)
internal let vboxLength = 1 << signalBits
internal let fractionByPopulation = 0.75
internal let maxIterations = 1000

//
//  MirroringMode.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

enum MirroringMode: UInt8 {
    case horizontal = 0,
    vertical = 1,
    single0 = 2,
    single1 = 3,
    fourScreen = 4
}

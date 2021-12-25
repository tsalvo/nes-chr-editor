//
//  Constants.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 12/24/21.
//  Copyright © 2021 Tom Salvo. All rights reserved.
//

import Foundation

struct Constants {
    static private let bitsPerPixel = 2

    static let tileWidth: Int = 8
    static let tileHeight: Int = 8

    static let maxCHRGridHistory:UInt = 64

    static let tileSizeInBytes = tileWidth * tileHeight * bitsPerPixel / 8
}

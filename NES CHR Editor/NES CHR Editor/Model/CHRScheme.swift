//
//  CHRScheme.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 12/24/21.
//  Copyright © 2021 Tom Salvo. All rights reserved.
//

import Foundation

enum CHRScheme {
    /// data for a CHR tile is arranged in order of all 64 pixels' first color bits, followed by all 64 pixels' second color bits
    case nes
    
    /// data for a CHR tile is arranged row-by-row, with each row being 2 bytes long.  each 2-byte row set is composed of the first color bit of the 8 pixels in the row, followed by the second color bit of the 8 pixels in the row
    case gb
}

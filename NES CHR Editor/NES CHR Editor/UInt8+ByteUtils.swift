//
//  UInt8+ByteUtils.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 5/24/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

extension UInt8
{
    /// Returns an assembler-friendly representation of the hex value of this byte (e.g. 0 = $00, 255 = $FF)
    var hexString: String
    {
        return String(format: "$%02X", self)
    }
}

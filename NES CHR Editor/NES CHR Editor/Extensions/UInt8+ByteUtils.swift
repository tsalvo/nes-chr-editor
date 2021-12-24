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
    var asmHexString: String
    {
        return String(format: "$%02X", self)
    }
    
    /// Returns a C-style hex representation of the hex value of this byte (e.g. 0 = 0x00, 255 = 0xFF)
    var cHexString: String
    {
        return String(format: "0x%02X", self)
    }
    
    /// Returns a UInt8 value from an array of 8 boolean values in big endian order (more significant, or "higher", bits first)
    init(fromBigEndianBitArray aBigEndianBitArray: [Bool])
    {
        var retValue: UInt8 = 0
        if aBigEndianBitArray.count == 8
        {
            retValue += aBigEndianBitArray[7] ? 1 : 0
            retValue += aBigEndianBitArray[6] ? 2 : 0
            retValue += aBigEndianBitArray[5] ? 4 : 0
            retValue += aBigEndianBitArray[4] ? 8 : 0
            retValue += aBigEndianBitArray[3] ? 16 : 0
            retValue += aBigEndianBitArray[2] ? 32 : 0
            retValue += aBigEndianBitArray[1] ? 64 : 0
            retValue += aBigEndianBitArray[0] ? 128 : 0
        }
        
        self.init(retValue)
    }
    
    /// Returns an array of 8 boolean values in little-endian order (less significant, or "lower", bits first)
    var littleEndianBitArray: [Bool]
    {
        let lE = self.littleEndian
        var retValue: [Bool] = [Bool].init(repeating: false, count: 8)
        
        retValue[0] = lE >> 0 & 1 == 1
        retValue[1] = lE >> 1 & 1 == 1
        retValue[2] = lE >> 2 & 1 == 1
        retValue[3] = lE >> 3 & 1 == 1
        retValue[4] = lE >> 4 & 1 == 1
        retValue[5] = lE >> 5 & 1 == 1
        retValue[6] = lE >> 6 & 1 == 1
        retValue[7] = lE >> 7 & 1 == 1
        
        return retValue
    }
    
    /// Returns a UInt8 value from an array of 8 boolean values in little endian order (less significant, or "lower", bits first)
    init(fromLittleEndianBitArray aLittleEndianBitArray: [Bool])
    {
        var retValue: UInt8 = 0
        if aLittleEndianBitArray.count == 8
        {
            retValue += aLittleEndianBitArray[0] ? 1 : 0
            retValue += aLittleEndianBitArray[1] ? 2 : 0
            retValue += aLittleEndianBitArray[2] ? 4 : 0
            retValue += aLittleEndianBitArray[3] ? 8 : 0
            retValue += aLittleEndianBitArray[4] ? 16 : 0
            retValue += aLittleEndianBitArray[5] ? 32 : 0
            retValue += aLittleEndianBitArray[6] ? 64 : 0
            retValue += aLittleEndianBitArray[7] ? 128 : 0
        }
        
        self.init(retValue)
    }
}

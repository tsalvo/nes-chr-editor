//
//  CHR.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

struct CHR {
    
    var pixels:[PaletteColor] = [PaletteColor](repeating:.Color0, count: kCHRWidthInPixels * kCHRHeightInPixels)
    
    func color(atRow aRow:Int, atCol aCol:Int) -> PaletteColor {
        return pixels[kCHRWidthInPixels * aRow + aCol] //width * row + col
    }
    
    func isEmpty() -> Bool {
        return self.pixels.filter( { $0 == .Color0 } ).count == self.pixels.count
    }
    
    mutating func setColor(palleteColor:PaletteColor, atRow aRow:Int, atCol aCol:Int) {
        pixels[kCHRWidthInPixels * aRow + aCol] = palleteColor
    }
    
    func toBytes() -> [UInt8] {
        /* How a single CHR is represented:
        - Each CHR is 128 bits (16 bytes)
        - Each CHR is 8x8 pixels
        - Each pixel within a CHR is one of 4 colors
        - Each pixel within a CHR is 2 bits (0b00 = color0, 0b10 = color1, 0b01 = color2, 0b11 = color3)

        - The first 64 bits of the CHR represent the first color bit for each of the 8x8 pixels, starting from top-left, traversing horizontally through each of the 8 rows from left to right
        - The second 64 bits of the CHR represent the second color bit for each of the 8x8 pixels, starting from top-left, traversing horizontally through each of the 8 rows from left to right
        */
        
        // create an array of bits (should be 128 length)
        var bits:[Bool] = [Bool](repeating:false, count: kCHRWidthInPixels * kCHRHeightInPixels * 2)  // 2 bits per CHR pixel
        
        // for all pixels, write the first and second color bit to 1 wherever needed
        for (pixelIndex, pixel) in pixels.enumerated() {
            switch pixel {
            case .Color0: break // both color bits = 0, do nothing
            case .Color1: bits[pixelIndex] = true // first color bit = 1
            case .Color2: bits[kCHRWidthInPixels * kCHRHeightInPixels + pixelIndex] = true // second color bit = 1
            case .Color3: bits[pixelIndex] = true; bits[kCHRWidthInPixels * kCHRHeightInPixels + pixelIndex] = true // both color bits = 1
            }
        }
        
        // create array of bytes from the bits array
        var bytes = [UInt8](repeating : 0, count : (bits.count + 7) / 8)
        
        // populate the bytes array
        for (index, bit) in bits.enumerated() {
            if bit == true {
                bytes[index / 8] += (1 << (7 - UInt8(index) % 8))
            }
        }
        
        return bytes
    }
    
    func toData() -> Data {
        
        return Data(self.toBytes())
    }
    
    func toAsm6String() -> String {
        var retValue: String = ""
        for (i, b) in self.toBytes().enumerated() {
            if i % 8 == 0 {
                retValue.append(".byte ")
            }
            
            retValue.append(b.asmHexString)
            
            if i % 8 == 7 {
                retValue.append("\n")
            } else {
                retValue.append(",")
            }
        }
        
        return retValue
    }
    
    func toCArrayElementString() -> String {
        var retValue: String = ""
        for (i, b) in self.toBytes().enumerated() {
            retValue.append(b.cHexString)
            
            if i % 8 == 7 {
                retValue.append("\n")
            } else {
                retValue.append(",")
            }
        }
        
        return retValue
    }
    
    init() { }
    init(fromData aData:Data) {
        
        self.pixels = [PaletteColor](repeating:.Color0, count: kCHRWidthInPixels * kCHRHeightInPixels)
        
        if aData.count == kCHRSizeInBytes {
            
            var bits:[Bool] = [Bool](repeating:false, count: kCHRWidthInPixels * kCHRHeightInPixels * 2)  // 2 bits per CHR pixel
            
            var byteArray: [UInt8] = [UInt8](repeating: 0, count: kCHRSizeInBytes)
            aData.copyBytes(to: &byteArray, count: kCHRSizeInBytes)
            
            for (byteIndex, byte) in byteArray.enumerated() {
                for i:UInt8 in 0..<8 {
                    
                    if (byte >> (7 - i)) & UInt8(1) == 1 {
                        bits[Int(byteIndex) * 8 + Int(i)] = true
                    }
                }
            }
            
            // for all pixels, write the first and second color bit to 1 wherever needed
            for (pixelIndex, _) in pixels.enumerated() {
                
                let firstColorBit:Bool = bits[pixelIndex]
                let secondColorBit:Bool = bits[kCHRWidthInPixels * kCHRHeightInPixels + pixelIndex]
                
                if firstColorBit == false && secondColorBit == false {
                    pixels[pixelIndex] = .Color0
                } else if firstColorBit == true && secondColorBit == false {
                    pixels[pixelIndex] = .Color1
                } else if firstColorBit == false && secondColorBit == true {
                    pixels[pixelIndex] = .Color2
                } else if firstColorBit == true && secondColorBit == true {
                    pixels[pixelIndex] = .Color3
                }
            }
            
        }
    }
}

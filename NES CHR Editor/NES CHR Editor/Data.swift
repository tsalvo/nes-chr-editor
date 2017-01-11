//
//  Data.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/30/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

public enum PaletteColor {
    case Color0, Color1, Color2, Color3
    
    var color: NSColor {
        
        let isUsingCustomIndexedPaletteSet = UserDefaults.standard.bool(forKey: "UseCustomPaletteSet")
        
        let indexOfSelectedPaletteSet = UserDefaults.standard.integer(forKey: "IndexedPaletteSet")
        let indexedPaletteSet = isUsingCustomIndexedPaletteSet ?
            IndexedPaletteSet(
                color0: UInt8(UserDefaults.standard.integer(forKey: "CustomPaletteSetIndexedColor0")),
                color1: UInt8(UserDefaults.standard.integer(forKey: "CustomPaletteSetIndexedColor1")),
                color2: UInt8(UserDefaults.standard.integer(forKey: "CustomPaletteSetIndexedColor2")),
                color3: UInt8(UserDefaults.standard.integer(forKey: "CustomPaletteSetIndexedColor3"))) :
            IndexedPaletteSets[indexOfSelectedPaletteSet % IndexedPaletteSets.count]
        
        switch self {
        case .Color0: return NESPaletteColors[Int(indexedPaletteSet.color0)]
        case .Color1: return NESPaletteColors[Int(indexedPaletteSet.color1)]
        case .Color2: return NESPaletteColors[Int(indexedPaletteSet.color2)]
        case .Color3: return NESPaletteColors[Int(indexedPaletteSet.color3)]
        }
    }
}

public struct IndexedPaletteSet {
    var color0:UInt8 = 13 // black
    var color1:UInt8 = 42 // white
    var color2:UInt8 = 19 // red
    var color3:UInt8 = 1  // blue
    var colorForSelectedCHR:UInt8 = 36 // orange
    var colorForSelectedPalette:UInt8 = 18 // magenta
    var colorForGridLines:UInt8 = 0 // gray
    init() { }
    init(color0 aC0:UInt8, color1 aC1:UInt8, color2 aC2:UInt8, color3 aC3:UInt8) {
        let count = UInt8(NESPaletteColors.count)
        self.color0 = aC0 % count
        self.color1 = aC1 % count
        self.color2 = aC2 % count
        self.color3 = aC3 % count
    }
    init(color0 aC0:UInt8, color1 aC1:UInt8, color2 aC2:UInt8, color3 aC3:UInt8, selectedCHR aSC:UInt8, selectedPalette aSP:UInt8, gridLines aG:UInt8) {
        let count = UInt8(NESPaletteColors.count)
        self.color0 = aC0 % count
        self.color1 = aC1 % count
        self.color2 = aC2 % count
        self.color3 = aC3 % count
        self.colorForSelectedCHR = aSC % count
        self.colorForSelectedPalette = aSP % count
        self.colorForGridLines = aG % count
    }
}

public struct PaletteSet {
    var color0:NSColor
    var color1:NSColor
    var color2:NSColor
    var color3:NSColor
    var colorForSelectedCHR:NSColor
    var colorForSelectedPalette:NSColor
    var colorForGridLines:NSColor
    init(color0 aC0:NSColor, color1 aC1:NSColor, color2 aC2:NSColor, color3 aC3:NSColor, selectedCHR aSC:NSColor, selectedPalette aSP:NSColor, gridLines aG:NSColor) {
        self.color0 = aC0
        self.color1 = aC1
        self.color2 = aC2
        self.color3 = aC3
        self.colorForSelectedCHR = aSC
        self.colorForSelectedPalette = aSP
        self.colorForGridLines = aG
    }
}

public struct CHRGrid {
    var fileSize:SupportedFileSize = .Size8KB
    var grid:[CHR] = [CHR](repeating:CHR(), count: Int(SupportedFileSize.Size8KB.numCHRsInFile))
    
    mutating func setCHR(chr:CHR, atIndex aIndex:UInt) {
        self.grid[Int(aIndex)] = chr
    }
    
    func getCHR(atIndex aIndex:UInt) -> CHR {
        return self.grid[Int(aIndex)]
    }
    
    var selectedCHRIndex:UInt = 0
    
    func toData() -> Data {
        var retValue = Data()
        for chr in grid {
            retValue.append(chr.toData())
        }
        
        return retValue
    }
    
    init() { }
    
    init(withFileSize aSupportedFileSize:SupportedFileSize) {
        self.fileSize = aSupportedFileSize
        self.grid = [CHR](repeating:CHR(), count: Int(aSupportedFileSize.numCHRsInFile))
    }
    
    init(fromData aData:Data) {
        if let safeFileSize:SupportedFileSize = SupportedFileSize(rawValue: UInt(aData.count) / 1024) {
            self.fileSize = safeFileSize
            self.grid = [CHR](repeating:CHR(), count: Int(safeFileSize.numCHRsInFile))
            
            for (chrIndex, _) in grid.enumerated() {
                self.grid[chrIndex] = CHR(fromData: aData.subdata(in: Range(uncheckedBounds: (chrIndex * kCHRSizeInBytes, chrIndex * kCHRSizeInBytes + kCHRSizeInBytes))))
            }
        } else {
            Swift.print("Error Creating CHR Grid From Data.  The number of bytes in the data (\(aData.count)) does not match an expected value")
        }
 
    }
}

public struct CHR {
    
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
    
    func toData() -> Data {
    
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
        
        // create array of bytes to be put into Data object
        var bytes = [UInt8](repeating : 0, count : (bits.count + 7) / 8)
        
        // populate the bytes array from the bits array
        for (index, bit) in bits.enumerated() {
            if bit == true {
                bytes[index / 8] += (1 << (7 - UInt8(index) % 8))
            }
        }
        
        return Data(bytes: bytes)
    }
    
    init() { }
    init(fromData aData:Data) {
        
        self.pixels = [PaletteColor](repeating:.Color0, count: kCHRWidthInPixels * kCHRHeightInPixels)
        
        if aData.count == kCHRSizeInBytes {
            
            var bits:[Bool] = [Bool](repeating:false, count: kCHRWidthInPixels * kCHRHeightInPixels * 2)  // 2 bits per CHR pixel
            
            let byteArray:[UInt8] = aData.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: aData.count))
            }
            
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

public let IndexedPaletteSets:[IndexedPaletteSet] = [
    IndexedPaletteSet(color0: 13, color1: 42, color2: 19, color3: 1, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 13, color1: 1, color2: 19, color3: 42, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 13, color2: 19, color3: 1, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 1, color2: 19, color3: 13, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 14, color2: 0, color3: 13, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 13, color1: 0, color2: 14, color3: 42, selectedCHR: 36, selectedPalette: 18, gridLines: 0)
]

public let NESPaletteColors:[NSColor] = [
    NSColor(colorLiteralRed: 124 / 255.0, green: 124 / 255.0, blue: 124.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 000 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 000 / 255.0, blue: 188.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 068 / 255.0, green: 040 / 255.0, blue: 188.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 148 / 255.0, green: 000 / 255.0, blue: 132.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 168 / 255.0, green: 000 / 255.0, blue: 032.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 168 / 255.0, green: 016 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 136 / 255.0, green: 020 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 080 / 255.0, green: 048 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 120 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 104 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 088 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 064 / 255.0, blue: 088.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 000 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 188 / 255.0, green: 188 / 255.0, blue: 188.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 120 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 088 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 104 / 255.0, green: 068 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 216 / 255.0, green: 000 / 255.0, blue: 204.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 228 / 255.0, green: 000 / 255.0, blue: 088.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 056 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 228 / 255.0, green: 092 / 255.0, blue: 016.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 172 / 255.0, green: 124 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 184 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 168 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 168 / 255.0, blue: 068.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 136 / 255.0, blue: 136.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 000 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 248 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 060 / 255.0, green: 188 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 104 / 255.0, green: 136 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 152 / 255.0, green: 120 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 120 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 088 / 255.0, blue: 152.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 120 / 255.0, blue: 088.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 252 / 255.0, green: 160 / 255.0, blue: 068.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 184 / 255.0, blue: 000.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 184 / 255.0, green: 248 / 255.0, blue: 024.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 088 / 255.0, green: 216 / 255.0, blue: 084.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 088 / 255.0, green: 248 / 255.0, blue: 152.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 232 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 120 / 255.0, green: 120 / 255.0, blue: 120.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 252 / 255.0, green: 252 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 164 / 255.0, green: 228 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 184 / 255.0, green: 184 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 216 / 255.0, green: 184 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 184 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 164 / 255.0, blue: 192.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 240 / 255.0, green: 208 / 255.0, blue: 176.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 252 / 255.0, green: 224 / 255.0, blue: 168.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 216 / 255.0, blue: 120.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 216 / 255.0, green: 248 / 255.0, blue: 120.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 184 / 255.0, green: 248 / 255.0, blue: 184.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 184 / 255.0, green: 248 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 000 / 255.0, green: 252 / 255.0, blue: 252.0 / 255.0, alpha: 1.0),
    NSColor(colorLiteralRed: 248 / 255.0, green: 216 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
]

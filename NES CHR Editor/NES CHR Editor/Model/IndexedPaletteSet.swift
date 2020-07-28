//
//  IndexedPaletteSet.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

struct IndexedPaletteSet {
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

let IndexedPaletteSets:[IndexedPaletteSet] = [
    IndexedPaletteSet(color0: 13, color1: 42, color2: 19, color3: 1, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 13, color1: 1, color2: 19, color3: 42, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 13, color2: 19, color3: 1, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 1, color2: 19, color3: 13, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 42, color1: 14, color2: 0, color3: 13, selectedCHR: 36, selectedPalette: 18, gridLines: 0),
    IndexedPaletteSet(color0: 13, color1: 0, color2: 14, color3: 42, selectedCHR: 36, selectedPalette: 18, gridLines: 0)
]

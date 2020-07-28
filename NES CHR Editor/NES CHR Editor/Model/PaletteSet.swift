//
//  PaletteSet.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import AppKit

struct PaletteSet {
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

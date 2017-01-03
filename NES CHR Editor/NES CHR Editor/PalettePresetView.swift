//
//  PalettePresetView.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/13/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Cocoa

class PalettePresetView: NSView {

    var palettePreset:IndexedPaletteSet = IndexedPaletteSet()
    var isSelected = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        let count = NESPaletteColors.count
        let blockSize = CGSize(width: bounds.width, height: bounds.height/4)
        NESPaletteColors[Int(palettePreset.color0) % count].setFill()
        NSRectFill(
            CGRect(x: 0,
                   y: 0,
                   width: blockSize.width,
                   height: blockSize.height))
        NESPaletteColors[Int(palettePreset.color1) % count].setFill()
        NSRectFill(
            CGRect(x: 0,
                   y: blockSize.height,
                   width: blockSize.width,
                   height: blockSize.height))
        NESPaletteColors[Int(palettePreset.color2) % count].setFill()
        NSRectFill(
            CGRect(x: 0,
                   y: blockSize.height*2,
                   width: blockSize.width,
                   height: blockSize.height))
        NESPaletteColors[Int(palettePreset.color3) % count].setFill()
        NSRectFill(
            CGRect(x: 0,
                   y: blockSize.height*3,
                   width: blockSize.width,
                   height: blockSize.height))
    }
    
}

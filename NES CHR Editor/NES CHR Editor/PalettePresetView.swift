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
        
        let count:Int = NESPaletteColors.count
        let colorSizeAsPercentageOfFullBounds:CGFloat = 0.7
        
        let blockSize = CGSize(width: bounds.width * colorSizeAsPercentageOfFullBounds,
                               height: bounds.height * colorSizeAsPercentageOfFullBounds / 4)
        
        if self.isSelected
        {
            NSColor.purple.setFill()
            self.bounds.fill()
        }
        
        let xOffset:CGFloat = (1.0 - colorSizeAsPercentageOfFullBounds) * 0.5 * bounds.width
        let yOffset:CGFloat = (1.0 - colorSizeAsPercentageOfFullBounds) * 0.5 * bounds.height
        
        NESPaletteColors[Int(palettePreset.color0) % count].setFill()
        CGRect(x: xOffset,
                   y: yOffset,
                   width: blockSize.width,
                   height: blockSize.height).fill()
        NESPaletteColors[Int(palettePreset.color1) % count].setFill()
        CGRect(x: xOffset,
                   y: yOffset + blockSize.height,
                   width: blockSize.width,
                   height: blockSize.height).fill()
        NESPaletteColors[Int(palettePreset.color2) % count].setFill()
        CGRect(x: xOffset,
                   y: yOffset + blockSize.height * 2,
                   width: blockSize.width,
                   height: blockSize.height).fill()
        NESPaletteColors[Int(palettePreset.color3) % count].setFill()
        CGRect(x: xOffset,
                   y: yOffset + blockSize.height * 3,
                   width: blockSize.width,
                   height: blockSize.height).fill()
    }
}

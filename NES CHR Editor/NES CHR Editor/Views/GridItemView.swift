//
//  GridItemView.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/5/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Cocoa

class GridItemView: NSView {

    var isSelected:Bool = false
    var chr:CHR = CHR()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        let indexOfSelectedPaletteSet = UserDefaults.standard.integer(forKey: "IndexedPaletteSet")
        let indexedPaletteSet = IndexedPaletteSets[indexOfSelectedPaletteSet % IndexedPaletteSets.count]
        
        // draw background
        
        let bgColor = self.isSelected ? NESPaletteColors[Int(indexedPaletteSet.colorForSelectedCHR)] : PaletteColor.Color0.color
        bgColor.setFill()
        
        bounds.fill()
        
        let blockSize = CGSize(width: bounds.size.width / CGFloat(Constants.tileWidth), height: bounds.size.height / CGFloat(Constants.tileHeight))
        
        for chrRow in 0 ..< Constants.tileHeight {
            for chrCol in 0 ..< Constants.tileWidth {
                let currentPaletteColor = chr.color(atRow: chrRow, atCol: chrCol)
                
                if currentPaletteColor != .Color0 {
                    currentPaletteColor.color.setFill()
                    CGRect(x: CGFloat(chrCol) * blockSize.width,
                               y: CGFloat(Constants.tileHeight - chrRow - 1) * blockSize.height,
                               width: blockSize.width,
                               height: blockSize.height).fill()
                }
                
            }
        }

        NSColor(white: 0.5, alpha: 0.5).setStroke()
        for rowGridlineX in stride(from: blockSize.width, to: bounds.width, by: blockSize.width) {
            NSBezierPath.strokeLine(from: NSPoint(x:rowGridlineX, y: 0), to: NSPoint(x: rowGridlineX, y: bounds.height))
        }
        
        for rowGridlineY in stride(from: blockSize.height, to: bounds.height, by: blockSize.height) {
            NSBezierPath.strokeLine(from: NSPoint(x:0, y: rowGridlineY), to: NSPoint(x: bounds.width, y: rowGridlineY))
        }
        
        NESPaletteColors[Int(indexedPaletteSet.colorForGridLines)].setStroke()
        NSBezierPath.strokeLine(from: NSPoint(x:0, y: 0), to: NSPoint(x: 0, y: bounds.height))
        NSBezierPath.strokeLine(from: NSPoint(x:0, y: bounds.height), to: NSPoint(x: bounds.width, y: bounds.height))
    }
    
}

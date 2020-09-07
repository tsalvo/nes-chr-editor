//
//  TileEditView.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/18/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

class EditView: NSView {
    
    var tileEditDelegate:CHREditProtocol?
    var gridHistoryDelegate:CHRGridHistoryProtocol?
    
    var brushColor:PaletteColor = .Color3
    
    var didStartEditing = false
    
    var chr:CHR = CHR()
    var colors:[PaletteColor] = [PaletteColor](repeating:.Color0, count: kCHRWidthInPixels * kCHRHeightInPixels)

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        PaletteColor.Color0.color.setFill()
        bounds.fill()
        
        let blockSize = CGSize(width: bounds.width/CGFloat(kCHRWidthInPixels), height: bounds.height/CGFloat(kCHRHeightInPixels))
        
        for row in 0..<kCHRHeightInPixels {
            for col in 0..<kCHRWidthInPixels {
                
                let currentPaleteColor = self.chr.color(atRow: row, atCol: col)
                
                if currentPaleteColor != .Color0 {
                    
                    currentPaleteColor.color.setFill()
                    CGRect(x: CGFloat(col) * blockSize.width,
                               y: CGFloat(((kCHRHeightInPixels - 1)) - row) * blockSize.height,
                               width: blockSize.height,
                               height: blockSize.height).fill()
                }
            }
        }
        
        // pixel grid
        NSColor(white: 0.5, alpha: 1.0).setStroke()
        for rowGridlineX in stride(from: 0, to: bounds.width, by: blockSize.width) {
            NSBezierPath.strokeLine(from: NSPoint(x:rowGridlineX, y: 0), to: NSPoint(x: rowGridlineX, y: bounds.height))
        }
        
        for rowGridlineY in stride(from: 0, to: bounds.height, by: blockSize.height) {
            NSBezierPath.strokeLine(from: NSPoint(x:0, y: rowGridlineY), to: NSPoint(x: bounds.width, y: rowGridlineY))
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        let blockSize = CGSize(width: bounds.width/CGFloat(kCHRWidthInPixels), height: bounds.height/CGFloat(kCHRHeightInPixels))
        
        let loc = convert(event.locationInWindow, from: nil)
        
        let point = NSPoint(x: CGFloat(kCHRWidthInPixels) * loc.x / bounds.width, y: CGFloat(kCHRHeightInPixels) * loc.y / bounds.height)
        
        let col:Int = (point.x < 0 ? 0 : Int(point.x) > kCHRWidthInPixels-1 ? kCHRWidthInPixels-1 : Int(point.x))
        let row:Int = (kCHRHeightInPixels - 1) - (point.y < 0 ? 0 : Int(point.y) > kCHRHeightInPixels-1 ? kCHRHeightInPixels-1 : Int(point.y))
        
        if self.chr.color(atRow: row, atCol: col) != brushColor {
            
            // a new edit has begun
            if !self.didStartEditing {
                self.gridHistoryDelegate?.CHRGridWillChange()
                self.didStartEditing = true
            }
            
            self.chr.setColor(palleteColor: brushColor, atRow: row, atCol: col)
            self.setNeedsDisplay(CGRect(x: CGFloat(col) * blockSize.width,
                                        y: CGFloat(((kCHRHeightInPixels - 1)) - row) * blockSize.height,
                                        width: blockSize.height,
                                        height: blockSize.height))
            self.tileEditDelegate?.tileEdited(withCHR: self.chr)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDragged(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.didStartEditing = false
    }
    
    // MARK: - TileSelectionProtocol
    
    func tileSelected(withCHR aCHR: CHR) {
        self.chr = aCHR
        self.setNeedsDisplay(bounds)
    }
}

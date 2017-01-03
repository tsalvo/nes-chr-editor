//
//  PaletteSelectionArrowView.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 10/15/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

class PaletteSelectionArrowView: NSView {
    
    var isUp = true
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        var points:[CGPoint] = isUp ?
            [CGPoint(x: NSMidX(self.bounds), y: self.bounds.height - 1),
             CGPoint(x: 1, y: 1),
             CGPoint(x: self.bounds.width - 1, y: 1)]
            :
            [CGPoint(x: NSMidX(self.bounds), y: 1),
             CGPoint(x: 1, y: self.bounds.height - 1),
             CGPoint(x: self.bounds.width - 1, y: self.bounds.height - 1)]
        
        let path = NSBezierPath()
        path.move(to: points[0])
        path.line(to: points[1])
        path.line(to: points[2])
        path.close()
        NSColor.black.set()
        path.fill()
    }
    
}

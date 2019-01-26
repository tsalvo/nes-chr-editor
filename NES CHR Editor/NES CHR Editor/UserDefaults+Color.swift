//
//  UserDefaults+Color.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 10/15/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

extension UserDefaults {
    
    func color(forKey key: String) -> NSColor? {
        var color: NSColor?
        if let colorData = data(forKey: key) {
            do
            {
                color = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSColor.self], from: colorData) as? NSColor
            }
            catch
            {
                
            }
            
        }
        return color
    }
    
    func set(color aColor:NSColor?, forKey key: String) {
        var colorData: Data?
        if let color = aColor {
            do
            {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
                
            }
            catch
            {
                
            }
        }
        set(colorData, forKey: key)
    }
}


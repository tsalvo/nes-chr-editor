//
//  PaletteColor.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import AppKit

 enum PaletteColor {
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

//
//  PalettePresetCollectionViewItem.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/13/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Cocoa

class PalettePresetCollectionViewItem: NSCollectionViewItem {

    var presetView:PalettePresetView = PalettePresetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        presetView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(presetView)
        self.view.addConstraints([
            NSLayoutConstraint(item: presetView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: presetView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: presetView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: presetView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 1),
            ])
    }
    
}

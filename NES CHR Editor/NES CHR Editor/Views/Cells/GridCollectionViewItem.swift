//
//  GridCollectionViewItem.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/5/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Cocoa

class GridCollectionViewItem: NSCollectionViewItem {

    var itemView:GridItemView = GridItemView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(itemView)
        self.view.addConstraints([
            NSLayoutConstraint(item: itemView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: itemView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: itemView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: itemView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 1),
            ])
    }
    
}

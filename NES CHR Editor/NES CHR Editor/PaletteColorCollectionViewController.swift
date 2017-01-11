//
//  PaletteColorCollectionViewController.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/13/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

protocol PaletteColorSelectionProtocol {
    func paletteColorSelected(withColor aColor:NSColor, atIndex aIndex:UInt)
}

class PaletteColorCollectionViewController: NSViewController, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {

    @IBOutlet weak var paletteSelectionCollectionView:NSCollectionView!
    var paletteColorSelectionDelegate:PaletteColorSelectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paletteSelectionCollectionView.delegate = self
        self.paletteSelectionCollectionView.dataSource = self
        
        self.paletteSelectionCollectionView.register(PaletteCollectionViewItem.self, forItemWithIdentifier: "paletteCollectionViewItem")
    }
    
    // MARK: - NSCollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width / 14, height: collectionView.bounds.height / 4)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        if let safeFirstIndexPath = indexPaths.first {
            self.paletteColorSelectionDelegate?.paletteColorSelected(withColor: NESPaletteColors[safeFirstIndexPath.item], atIndex:UInt(safeFirstIndexPath.item))
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return NESPaletteColors.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // Recycle or create an item.
        guard let item = collectionView.makeItem(withIdentifier: "paletteCollectionViewItem", for: indexPath) as? PaletteCollectionViewItem else { return NSCollectionViewItem() }
        
        item.view.wantsLayer = true
        item.view.layer?.backgroundColor = NESPaletteColors[indexPath.item].cgColor
        item.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        item.view.setNeedsDisplay(item.view.bounds)
        
        return item
    }
}

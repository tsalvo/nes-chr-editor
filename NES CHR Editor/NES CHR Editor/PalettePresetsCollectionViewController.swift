//
//  PalettePresetsCollectionViewController.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/13/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Cocoa

protocol PalettePresetSelectionProtocol {
    func palettePresetSelected(withPreset aPreset:IndexedPaletteSet, atIndex aIndex:Int)
}

class PalettePresetsCollectionViewController: NSViewController, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    
    @IBOutlet weak var paletteSelectionCollectionView:NSCollectionView!
    var palettePresetSelectionDelegate:PalettePresetSelectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paletteSelectionCollectionView.delegate = self
        self.paletteSelectionCollectionView.dataSource = self
        
        self.paletteSelectionCollectionView.register(PalettePresetCollectionViewItem.self, forItemWithIdentifier: "palettePresetCollectionViewItem")
    }
    
    // MARK: - NSCollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width / 10.5, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        if let safeFirstIndexPath = indexPaths.first {
            self.palettePresetSelectionDelegate?.palettePresetSelected(withPreset: IndexedPaletteSets[safeFirstIndexPath.item], atIndex: safeFirstIndexPath.item)
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return IndexedPaletteSets.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // Recycle or create an item.
        guard let item = collectionView.makeItem(withIdentifier: "palettePresetCollectionViewItem", for: indexPath) as? PalettePresetCollectionViewItem else { return NSCollectionViewItem() }
        
        item.presetView.palettePreset = IndexedPaletteSets[indexPath.item]
        item.presetView.setNeedsDisplay(item.presetView.bounds)
        
        return item
    }
}

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
    
    @IBOutlet weak private var paletteSelectionCollectionView:NSCollectionView!
    var palettePresetSelectionDelegate:PalettePresetSelectionProtocol?
    
    var selectedIndexPaletteSet:Int { return UserDefaults.standard.integer(forKey: "IndexedPaletteSet")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.paletteSelectionCollectionView.allowsMultipleSelection = false
        self.paletteSelectionCollectionView.allowsEmptySelection = false
        
        self.paletteSelectionCollectionView.register(PalettePresetCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "palettePresetCollectionViewItem"))
        
        self.paletteSelectionCollectionView.delegate = self
        self.paletteSelectionCollectionView.dataSource = self
    }
    
//    override func viewWillAppear() {
//        super.viewWillAppear()
//        self.paletteSelectionCollectionView.reloadData()
//    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self.paletteSelectionCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    // MARK: - NSCollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let width = min(collectionView.bounds.width, collectionView.bounds.width / 10.5)
        let height = min(collectionView.bounds.height, width * 4)
        let size = NSSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return NSEdgeInsetsZero
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize.zero
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize.zero
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
        guard let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "palettePresetCollectionViewItem"), for: indexPath) as? PalettePresetCollectionViewItem else { return NSCollectionViewItem() }
        
        item.presetView.palettePreset = IndexedPaletteSets[indexPath.item]
        item.isSelectedPreset = (indexPath.item == self.selectedIndexPaletteSet)
        item.presetView.setNeedsDisplay(item.presetView.bounds)
        
        return item
    }
}

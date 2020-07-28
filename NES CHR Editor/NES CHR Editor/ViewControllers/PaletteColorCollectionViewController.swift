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

    @IBOutlet weak private var paletteSelectionCollectionView:NSCollectionView!
    var paletteColorSelectionDelegate:PaletteColorSelectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paletteSelectionCollectionView.allowsMultipleSelection = false
        self.paletteSelectionCollectionView.allowsEmptySelection = false
        self.paletteSelectionCollectionView.register(PaletteCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "paletteCollectionViewItem"))
        
        self.paletteSelectionCollectionView.delegate = self
        self.paletteSelectionCollectionView.dataSource = self
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self.paletteSelectionCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    // MARK: - NSCollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width: CGFloat = min(collectionView.bounds.width / 14.0, collectionView.bounds.width)
        let size = NSSize(width: width, height: width)
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
            self.paletteColorSelectionDelegate?.paletteColorSelected(withColor: NESPaletteColors[safeFirstIndexPath.item], atIndex:UInt(safeFirstIndexPath.item))
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return NESPaletteColors.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // Recycle or create an item.
        guard let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "paletteCollectionViewItem"), for: indexPath) as? PaletteCollectionViewItem else { return NSCollectionViewItem() }
        
        item.view.wantsLayer = true
        item.view.layer?.backgroundColor = NESPaletteColors[indexPath.item].cgColor
        item.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        item.view.setNeedsDisplay(item.view.bounds)
        
        return item
    }
}

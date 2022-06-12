//
//  FullGridCollectionViewController.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 11/5/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

class FullGridCollectionViewController: NSViewController, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource, CHREditProtocol, CHRGridHistoryProtocol {

    @IBOutlet weak private var gridCollectionView:NSCollectionView!
    
    var CHRGridHistory:[CHRGrid] = []    // for tracking undo operations, most recent = beginning
    var CHRGridFuture:[CHRGrid] = []    // for tracking redo operations
    
    var tileSelectionDelegate:CHRSelectionProtocol?
    var fileEditDelegate:FileEditProtocol?
    
    var grid:CHRGrid = CHRGrid() {
        didSet {
            self.gridCollectionView.reloadData()
        }
    }
    
    static var CHRClipboard:CHR?
    
    var brushColor:PaletteColor = .Color3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gridCollectionView.allowsMultipleSelection = false
        self.gridCollectionView.allowsEmptySelection = false
        self.gridCollectionView.register(GridCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "gridCollectionItem"))
        self.gridCollectionView.delegate = self
        self.gridCollectionView.dataSource = self
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.gridCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    // MARK: - NSCollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let possibleNumbersOfItemsPerRow:[CGFloat] = [32, 16, 8, 4, 2]
        
        let collectionViewWidth = collectionView.bounds.width
        
        let minimumItemWidth:CGFloat = min(collectionViewWidth, 50)
        
        var itemWidth:CGFloat = collectionViewWidth  // default
        
        for possibleNumberOfItemsPerRow in possibleNumbersOfItemsPerRow {
            if collectionViewWidth / possibleNumberOfItemsPerRow >= minimumItemWidth {
                itemWidth = collectionViewWidth / possibleNumberOfItemsPerRow
                break
            }
        }

        return NSSize(width: itemWidth, height: itemWidth)
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
            let previousIndexPath = IndexPath(item: Int(self.grid.selectedCHRIndex), section: 0)
            self.grid.selectedCHRIndex = UInt(safeFirstIndexPath.item)
            collectionView.reloadItems(at: [previousIndexPath, IndexPath(item: Int(self.grid.selectedCHRIndex), section: 0)])
            self.tileSelectionDelegate?.tileSelected(withCHR: self.grid.getCHR(atIndex: self.grid.selectedCHRIndex))
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(ChrFileSize(numChrBlocks: grid.numChrBlocks).numCHRsInFile)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // Recycle or create an item.
        guard let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "gridCollectionItem"), for: indexPath) as? GridCollectionViewItem else { return NSCollectionViewItem() }
        
        item.itemView.chr = self.grid.getCHR(atIndex: UInt(indexPath.item))
        item.itemView.isSelected = UInt(indexPath.item) == self.grid.selectedCHRIndex
        item.itemView.setNeedsDisplay(item.itemView.bounds)
        
        return item
    }
    
    // MARK: - TileEditProtocol
    
    func tileEdited(withCHR aCHR: CHR) {
        
        self.grid.setCHR(chr: aCHR, atIndex: self.grid.selectedCHRIndex)
        
        self.gridCollectionView.reloadItems(at: [IndexPath(item: Int(self.grid.selectedCHRIndex), section: 0)])
    }
    
    
    // MARK : - CHRGridHistoryProtocol
    
    func CHRGridWillChange() {
        
        // remove the oldest CHR grids from the history until we're below the maximum allowed
        while self.CHRGridHistory.count >= Int(Constants.maxCHRGridHistory) {
            let _ = self.CHRGridHistory.popLast()
        }
        
        // if the user edited the grid, there should be no grid future for Redo operations
        self.CHRGridFuture.removeAll()
        
        self.CHRGridHistory.insert(self.grid, at: 0)    // add most recent grid to the front of the history
        
        self.fileEditDelegate?.fileWasEdited()
    }
    
    func undo() {
        
        // if there's a CHR grid in the history
        if let safeMostRecentGrid = self.CHRGridHistory.first {
            
            // remove the oldest CHR grids from the grid future until we're below the maximum allowed
            while self.CHRGridFuture.count >= Int(Constants.maxCHRGridHistory) {
                let _ = self.CHRGridFuture.popLast()
            }
            
            self.CHRGridFuture.insert(self.grid, at: 0)    // add current grid to the front of the future
            
            self.grid = safeMostRecentGrid
            
            self.gridCollectionView.reloadData()
            
            self.tileSelectionDelegate?.tileSelected(withCHR: self.grid.getCHR(atIndex: self.grid.selectedCHRIndex))
            
            self.CHRGridHistory.removeFirst()   // remove most recent grid from the front of the history
        }
    }
    
    func redo() {
        
        // if there's a CHR Grid in the future
        if let safeNextFutureGrid = self.CHRGridFuture.first {
            self.CHRGridHistory.insert(self.grid, at: 0)    // add current grid to the front of the history
            
            self.grid = safeNextFutureGrid
            
            self.gridCollectionView.reloadData()
            
            self.tileSelectionDelegate?.tileSelected(withCHR: self.grid.getCHR(atIndex: self.grid.selectedCHRIndex))
            
            self.CHRGridFuture.removeFirst()   // remove most recent grid from the front of the future
        }
    }
    
    func cutCHR() {
        
        FullGridCollectionViewController.CHRClipboard = self.grid.getCHR(atIndex: self.grid.selectedCHRIndex)
        
        if let safeCHRClipboard = FullGridCollectionViewController.CHRClipboard, !safeCHRClipboard.isEmpty() {
            self.CHRGridWillChange()
            self.grid.setCHR(chr: CHR(), atIndex: self.grid.selectedCHRIndex)
            self.gridCollectionView.reloadItems(at: [IndexPath(item: Int(self.grid.selectedCHRIndex), section: 0)])
            self.tileSelectionDelegate?.tileSelected(withCHR: self.grid.getCHR(atIndex: self.grid.selectedCHRIndex))
        }
    }
    
    func copyCHR() {
        
        FullGridCollectionViewController.CHRClipboard = self.grid.getCHR(atIndex: self.grid.selectedCHRIndex)
    }
    
    func pasteCHR() {
        if let safeCHRClipboard = FullGridCollectionViewController.CHRClipboard {
            self.CHRGridWillChange()
            
            self.grid.setCHR(chr: safeCHRClipboard, atIndex: self.grid.selectedCHRIndex)

            self.gridCollectionView.reloadItems(at: [IndexPath(item: Int(self.grid.selectedCHRIndex), section: 0)])
            self.tileSelectionDelegate?.tileSelected(withCHR: self.grid.getCHR(atIndex: self.grid.selectedCHRIndex))

        }
    }
}

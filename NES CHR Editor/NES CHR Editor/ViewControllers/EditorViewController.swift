//
//  EditorViewController.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/18/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

protocol CHRSelectionProtocol {
    func tileSelected(withCHR aCHR: CHR)
}

protocol CHREditProtocol {
    func tileEdited(withCHR aCHR: CHR)
}

protocol CHRGridHistoryProtocol {
    var CHRGridHistory:[CHRGrid] { get set }
    var CHRGridFuture:[CHRGrid] { get set }
    func CHRGridWillChange()
    func undo()
    func redo()
}

protocol FileEditProtocol {
    func fileWasEdited()
}

class EditorViewController: NSViewController, FileEditProtocol, FileSizeSelectionProtocol, PaletteColorSelectionProtocol, PalettePresetSelectionProtocol, CHRSelectionProtocol, NSWindowDelegate{

    var fullGridCollectionView:FullGridCollectionViewController?
    @IBOutlet weak var editView:EditView!
    
    @IBOutlet weak var palletteView0:NSView!
    @IBOutlet weak var palletteView1:NSView!
    @IBOutlet weak var palletteView2:NSView!
    @IBOutlet weak var palletteView3:NSView!
    
    @IBOutlet weak var selectionLabel:NSTextField!
    
    var shouldShowFileSizeSelectionDialog = false
    var windowControllerDelegate:WindowControllerProtocol?
    var fileURL:URL?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.delegate = self
        self.refreshControls()
        if self.shouldShowFileSizeSelectionDialog {
            self.performSegue(withIdentifier: "presentFileSelectionDialog", sender: self)
            self.shouldShowFileSizeSelectionDialog = false
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.refreshControls()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? FileSizeDialogViewController {
            vc.fileSizeSelectionDelegate = self
        } else if let vc = segue.destinationController as? FullGridCollectionViewController {
            vc.fileEditDelegate = self
            vc.tileSelectionDelegate = self
            self.editView.tileEditDelegate = vc
            self.editView.gridHistoryDelegate = vc
            self.fullGridCollectionView = vc
        } else if let vc = segue.destinationController as? PaletteColorCollectionViewController {
            vc.paletteColorSelectionDelegate = self
        } else if let vc = segue.destinationController as? PalettePresetsCollectionViewController {
            vc.palettePresetSelectionDelegate = self
        }
    }
    
    // MARK: - Palette Selection
    
    @IBAction func palette0Pressed(sender:NSClickGestureRecognizer) {
        self.editView.brushColor = .Color0
        self.refreshControls()
    }
    
    @IBAction func palette1Pressed(sender:NSClickGestureRecognizer) {
        self.editView.brushColor = .Color1
        self.refreshControls()
    }
    
    @IBAction func palette2Pressed(sender:NSClickGestureRecognizer) {
        self.editView.brushColor = .Color2
        self.refreshControls()
    }
    
    @IBAction func palette3Pressed(sender:NSClickGestureRecognizer) {
        self.editView.brushColor = .Color3
        self.refreshControls()
    }
    
    // MARK: - PaletteColorSelectionProtocol
    
    func paletteColorSelected(withColor aColor: NSColor, atIndex aIndex:UInt) {
        Swift.print("paletteColorSelected:\(aColor) index: \(aIndex)")
        
        let isUsingCustomIndexedPaletteSet = UserDefaults.standard.bool(forKey: "UseCustomPaletteSet")
        
        if !isUsingCustomIndexedPaletteSet {
            let indexOfSelectedPaletteSet = UserDefaults.standard.integer(forKey: "IndexedPaletteSet")
            let indexedPaletteSet = IndexedPaletteSets[indexOfSelectedPaletteSet % IndexedPaletteSets.count]
            UserDefaults.standard.set(Int(indexedPaletteSet.color0), forKey:"CustomPaletteSetIndexedColor0")
            UserDefaults.standard.set(Int(indexedPaletteSet.color1), forKey:"CustomPaletteSetIndexedColor1")
            UserDefaults.standard.set(Int(indexedPaletteSet.color2), forKey:"CustomPaletteSetIndexedColor2")
            UserDefaults.standard.set(Int(indexedPaletteSet.color3), forKey:"CustomPaletteSetIndexedColor3")
            UserDefaults.standard.set(true, forKey: "UseCustomPaletteSet")
        }
        
        switch self.editView.brushColor {
        case .Color0: UserDefaults.standard.set(aIndex, forKey: "CustomPaletteSetIndexedColor0")
        case .Color1: UserDefaults.standard.set(aIndex, forKey: "CustomPaletteSetIndexedColor1")
        case .Color2: UserDefaults.standard.set(aIndex, forKey: "CustomPaletteSetIndexedColor2")
        case .Color3: UserDefaults.standard.set(aIndex, forKey: "CustomPaletteSetIndexedColor3")
        }
        
        UserDefaults.standard.synchronize()
        
        self.refreshControls()
        self.editView.setNeedsDisplay(editView.bounds)
    }
    
    // MARK: - PalettePresetSelectionProtocol
    
    func palettePresetSelected(withPreset aPreset:IndexedPaletteSet, atIndex aIndex:Int) {
        Swift.print("palettePresetSelected : colors \(aPreset.color0), \(aPreset.color1), \(aPreset.color2), \(aPreset.color3)")
        
        UserDefaults.standard.set(false, forKey: "UseCustomPaletteSet")
        UserDefaults.standard.set(aIndex, forKey: "IndexedPaletteSet")
        UserDefaults.standard.synchronize()
        
        self.refreshControls()
        self.editView.setNeedsDisplay(editView.bounds)
    }
    
    // MARK: - Menu Item Actions
    
    @IBAction func saveMenuItemSelected(sender:NSMenuItem) {
        print("Save")
        if let safeURL = self.fileURL, let safeGrid = self.fullGridCollectionView?.grid {
            saveCHRFile(withCHRGrid: safeGrid, scheme: .nes, toURL: safeURL)
            self.windowControllerDelegate?.fileWasEdited(edited: false)
        } else {
            if let safeGrid = self.fullGridCollectionView?.grid, let safeURL = saveCHRFile(withCHRGrid: safeGrid, scheme: .nes) {
                self.windowControllerDelegate?.fileNameChanged(newFileName: safeURL.lastPathComponent)
                self.windowControllerDelegate?.fileWasEdited(edited: false)
                self.windowControllerDelegate?.fileWasOpened()
                self.fileURL = safeURL
            } else {
                print("Error saving file")
            }
        }
    }
    
    @IBAction func saveAsMenuItemSelected(sender:NSMenuItem) {
        print("Save as...")
        if let safeGrid = self.fullGridCollectionView?.grid, let safeURL = saveCHRFile(withCHRGrid: safeGrid, scheme: .nes) {
            self.windowControllerDelegate?.fileNameChanged(newFileName: safeURL.lastPathComponent)
            self.windowControllerDelegate?.fileWasEdited(edited: false)
            self.windowControllerDelegate?.fileWasOpened()
            self.fileURL = safeURL
        } else {
            print("Error saving file")
        }
    }
    
    func openFile() {
        let resultsOfOpenOperation = openCHRFile()
        
        if let safeGrid = resultsOfOpenOperation.grid, let safeURL = resultsOfOpenOperation.url {
            self.fullGridCollectionView?.grid = safeGrid
            self.editView.tileSelected(withCHR: safeGrid.getCHR(atIndex: safeGrid.selectedCHRIndex))
            self.view.setNeedsDisplay(view.bounds)
            
            self.fileURL = safeURL
            self.windowControllerDelegate?.fileNameChanged(newFileName: safeURL.lastPathComponent)
            self.windowControllerDelegate?.fileWasEdited(edited: false)
            self.windowControllerDelegate?.fileWasOpened()
            self.refreshControls()
        } else {
            print("Error opening file")
        }
    }
    
    func importFromNESROMFile() {
        let resultsOfOpenOperation = importCHRFromNESROMFile()
        
        if let safeGrid = resultsOfOpenOperation.grid {
            self.fullGridCollectionView?.grid = safeGrid
            self.editView.tileSelected(withCHR: safeGrid.getCHR(atIndex: safeGrid.selectedCHRIndex))
            self.view.setNeedsDisplay(view.bounds)
            self.refreshControls()
        } else {
            print("Error opening file")
        }
    }
    
    @IBAction func exportToNESROMFileMenuItemSelected(sender:NSMenuItem) {
        
        if let safeCHRGrid = self.fullGridCollectionView?.grid {
            let resultOfExportOperation = exportCHRToNESROMFile(withCHRGrid: safeCHRGrid)
            
            if resultOfExportOperation == true {
                Swift.print("Export Succeeded")
            } else {
                Swift.print("Export Failed")
            }
        }
    }
    
    @IBAction func exportToNESAssemblyCodeFileMenuItemSelected(sender:NSMenuItem) {
        if let safeCHRGrid = self.fullGridCollectionView?.grid {
            saveAsm6File(withCHRGrid: safeCHRGrid, scheme: .nes)
        }
    }
    
    @IBAction func exportToGameBoyAssemblyCodeFileMenuItemSelected(sender:NSMenuItem) {
        if let safeCHRGrid = self.fullGridCollectionView?.grid {
            saveAsm6File(withCHRGrid: safeCHRGrid, scheme: .gb)
        }
    }
    
    @IBAction func exportToNESCArrayCodeFileMenuItemSelected(sender:NSMenuItem) {
        if let safeCHRGrid = self.fullGridCollectionView?.grid {
            saveCArrayFile(withCHRGrid: safeCHRGrid, scheme: .nes)
        }
    }
    
    @IBAction func exportToGameBoyCArrayCodeFileMenuItemSelected(sender:NSMenuItem) {
        if let safeCHRGrid = self.fullGridCollectionView?.grid {
            saveCArrayFile(withCHRGrid: safeCHRGrid, scheme: .gb)
        }
    }
    
    @IBAction func undoMenuItemSelected(sender:NSMenuItem) {
        print("Undo - Menu")
        self.fullGridCollectionView?.undo()
    }
    
    @IBAction func redoMenuItemSelected(sender:NSMenuItem) {
        print("Redo - Menu")
        self.fullGridCollectionView?.redo()
    }
    
    @IBAction func cutMenuItemSelected(sender:NSMenuItem) {
        print("Cut - Menu")
        self.fullGridCollectionView?.cutCHR()
    }
    
    @IBAction func copyMenuItemSelected(sender:NSMenuItem) {
        print("Copy - Menu")
        self.fullGridCollectionView?.copyCHR()
    }
    
    @IBAction func pasteMenuItemSelected(sender:NSMenuItem) {
        print("Paste - Menu")
        self.fullGridCollectionView?.pasteCHR()
    }
    
    // MARK: - FileEditprotocol
    
    func fileWasEdited() {
        self.windowControllerDelegate?.fileWasEdited(edited: true)
    }
    
    // MARK: - File Size Selection protocol
    
    func fileSizeSelected(_ aNumChrBlocks: UInt8) {
        self.fullGridCollectionView?.grid = CHRGrid(withNumChrBlocks: aNumChrBlocks)
        self.refreshControls()
        
        if let safeCHR = self.fullGridCollectionView?.grid.getCHR(atIndex: 0) {
            self.editView.tileSelected(withCHR: safeCHR)
        }

        self.view.setNeedsDisplay(view.bounds)
    }
    
    // MARK: - Private Methods
    
    private func refreshControls() {
        
        self.palletteView0.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.palletteView1.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.palletteView2.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.palletteView3.layerContentsRedrawPolicy = .onSetNeedsDisplay

        self.palletteView0.layer?.backgroundColor = PaletteColor.Color0.color.cgColor
        self.palletteView1.layer?.backgroundColor = PaletteColor.Color1.color.cgColor
        self.palletteView2.layer?.backgroundColor = PaletteColor.Color2.color.cgColor
        self.palletteView3.layer?.backgroundColor = PaletteColor.Color3.color.cgColor
        
        self.palletteView0.layer?.borderColor = .clear
        self.palletteView1.layer?.borderColor = .clear
        self.palletteView2.layer?.borderColor = .clear
        self.palletteView3.layer?.borderColor = .clear
        
        self.palletteView0.layer?.borderWidth = 0
        self.palletteView1.layer?.borderWidth = 0
        self.palletteView2.layer?.borderWidth = 0
        self.palletteView3.layer?.borderWidth = 0
        
        switch self.editView.brushColor {
        case .Color0:
            self.palletteView0.layer?.borderColor = NSColor.purple.cgColor
            self.palletteView0.layer?.borderWidth = 6
        case .Color1:
            self.palletteView1.layer?.borderColor = NSColor.purple.cgColor
            self.palletteView1.layer?.borderWidth = 6
        case .Color2:
            self.palletteView2.layer?.borderColor = NSColor.purple.cgColor
            self.palletteView2.layer?.borderWidth = 6
        case .Color3:
            self.palletteView3.layer?.borderColor = NSColor.purple.cgColor
            self.palletteView3.layer?.borderWidth = 6
        }
        
        self.palletteView0.setNeedsDisplay(self.palletteView0.bounds)
        self.palletteView1.setNeedsDisplay(self.palletteView1.bounds)
        self.palletteView2.setNeedsDisplay(self.palletteView2.bounds)
        self.palletteView3.setNeedsDisplay(self.palletteView3.bounds)
        
        self.renderSelectedOffset()
    }
    
    // Renders useful information about the selected CHR index to selectionLabel
    private func renderSelectedOffset() {
        if let safeCHRIndex = self.fullGridCollectionView?.grid.selectedCHRIndex {
            // Which pattern table this index is in
            let table = String(format:"%3d", safeCHRIndex / 256)
            // Index relative to the pattern table
            let relativeIndex = safeCHRIndex % 256
            // Formatted string for the actual index
            let chrString = String(format:"%3d", safeCHRIndex)
            // Formatted string for the relative index
            let relativeString = String(format:"%3d", relativeIndex)
            // Asm formatted hex string for the relative index
            let relativeHex = String(format:"%02X", relativeIndex)
            
            selectionLabel.stringValue = "Selection\n Index:\t\t\(chrString)\n Table:\t\t\(String(table))\n Offset:\t\(relativeString)\n Hex:\t\t$\(relativeHex)"
        }
    }
    
    func tileSelected(withCHR aCHR: CHR) {
        self.editView.tileSelected(withCHR: aCHR)
        renderSelectedOffset()
    }
    
    // MARK: - NSWindowDelegate
    
    func windowDidResize(_ notification: Notification) {
        self.fullGridCollectionView?.updateViewConstraints()
    }
}


//
//  AppDelegate.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/18/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var saveMenuItem:NSMenuItem!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.validateUserDefaults()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.synchronize()
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (!flag) {
            let windowController = NSStoryboard(name: "Main", bundle: nil)
                .instantiateController(withIdentifier: "EditorWindowControllerIdentifier") as! EditorWindowController;
            windowController.showWindow(self);
        }
        return true;
    }
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        // TODO: - tsalvo - Test This
        
        let resultsOfOpenOperation = openCHRFile(withFileName: filename)
        
        if let safeGrid = resultsOfOpenOperation.grid, let safeURL = resultsOfOpenOperation.url {
            
            if let safeEditorWC = NSStoryboard.init(name: "Main", bundle: Bundle.main).instantiateInitialController() as? EditorWindowController,
                let safeEditorVC = safeEditorWC.contentViewController as? EditorViewController {
                
                safeEditorVC.fullGridCollectionView?.grid = safeGrid
                safeEditorVC.editView.tileSelected(withCHR: safeGrid.getCHR(atIndex: safeGrid.selectedCHRIndex))
                
                safeEditorVC.fileURL = safeURL
                safeEditorVC.windowControllerDelegate?.fileNameChanged(newFileName: safeURL.lastPathComponent)
                safeEditorVC.windowControllerDelegate?.fileWasEdited(edited: false)
                safeEditorVC.windowControllerDelegate?.fileWasOpened()
                
                safeEditorWC.showWindow(sender)
                
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @IBAction func newWindowMenuItemSelected(sender:NSMenuItem) {
        Swift.print("New - Menu - AppDelegate")
        if let safeEditorWC = NSStoryboard.init(name: "Main", bundle: Bundle.main).instantiateInitialController() as? EditorWindowController,
            let safeEditorVC = safeEditorWC.contentViewController as? EditorViewController {
            safeEditorVC.shouldShowFileSizeSelectionDialog = true
            safeEditorWC.showWindow(sender)
        }
    }
    
    @IBAction func openMenuItemSelected(sender:NSMenuItem) {
        Swift.print("Open - Menu - AppDelegate")
        
        if let safeEditorWC = NSStoryboard.init(name: "Main", bundle: Bundle.main).instantiateInitialController() as? EditorWindowController,
            let safeEditorVC = safeEditorWC.contentViewController as? EditorViewController {
            safeEditorWC.showWindow(sender)
            safeEditorVC.openFile()
        }
    }
    
    @IBAction func importFromNESROMMenuItemSelected(sender:NSMenuItem) {
        Swift.print("Open - Menu - AppDelegate")
        
        if let safeEditorWC = NSStoryboard.init(name: "Main", bundle: Bundle.main).instantiateInitialController() as? EditorWindowController,
            let safeEditorVC = safeEditorWC.contentViewController as? EditorViewController {
            safeEditorWC.showWindow(sender)
            safeEditorVC.importFromNESROMFile()
        }
    }
    
    private func validateUserDefaults() {
        let selectedPaletteSet = UserDefaults.standard.integer(forKey: "PaletteSet")
        if selectedPaletteSet < 0 {
            UserDefaults.standard.set(0, forKey: "PaletteSet")
            UserDefaults.standard.synchronize()
        }
        
        let selectedIndexedPaletteSet = UserDefaults.standard.integer(forKey: "IndexedPaletteSet")
        if selectedIndexedPaletteSet < 0 {
            UserDefaults.standard.set(0, forKey: "IndexedPaletteSet")
            UserDefaults.standard.synchronize()
        }
    }
}


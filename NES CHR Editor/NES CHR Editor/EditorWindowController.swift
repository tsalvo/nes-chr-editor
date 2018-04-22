//
//  EditorWindow.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 10/3/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

protocol WindowControllerProtocol {
    func fileNameChanged(newFileName aNewFileName:String)
    func fileWasEdited(edited aFileWasEditedStatus:Bool)
    func fileWasOpened()
}

class EditorWindowController: NSWindowController, WindowControllerProtocol {
    
    var fileName = ""
    var fileHasUnsavedChanges = false
    var fileIsOpen = false
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.isReleasedWhenClosed = true
        
        if let editorVC = self.contentViewController as? EditorViewController {
            editorVC.windowControllerDelegate = self
        }
    }
    
    // MARK: - WindowControllerProtocol
    
    func fileNameChanged(newFileName aNewFileName:String) {
        self.fileName = aNewFileName
        self.fileHasUnsavedChanges = false
    }
    
    func fileWasEdited(edited aFileWasEditedStatus:Bool) {
        if fileHasUnsavedChanges != aFileWasEditedStatus {
            self.fileHasUnsavedChanges = aFileWasEditedStatus
            self.updateWindow()
        }
    }
    
    func fileWasOpened() {
        self.fileIsOpen = true
        self.updateWindow()
    }

    // MARK: - Private Methods
    
    fileprivate func updateWindow() {
        
        if let safeAppDelegate = NSApplication.shared.delegate as? AppDelegate {
            safeAppDelegate.saveMenuItem.title = (self.fileIsOpen ? "Save" : "Save...")
        }
        
        if self.fileName == "" {
            self.window?.title = self.fileHasUnsavedChanges ? "untitled.chr - Edited" : "CHR Editor"
        } else {
            self.window?.title = self.fileName + (self.fileHasUnsavedChanges ? " - Edited" : "")
        }
    }
}

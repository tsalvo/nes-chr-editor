//
//  CHRFileIO.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/30/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import AppKit

func saveCHRFile(withCHRGrid aChrGrid:CHRGrid, toURL aURL:URL) {
    
    let fileData = aChrGrid.toData()
    let chrFileSize: ChrFileSize = ChrFileSize(numChrBlocks: aChrGrid.numChrBlocks)
    
    if fileData.count == Int(chrFileSize.fileSizeInBytes) {
        // write to file
        do {
            try fileData.write(to: aURL, options: Data.WritingOptions.atomicWrite)
        }
        catch {
            let alert: NSAlert = NSAlert(error: error)
            alert.messageText = "Error saving to CHR file. \(error.localizedDescription)"
            alert.runModal()
        }
    } else {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Error saving to file.  The number of bytes to be saved (\(fileData.count) ) does not match the expected value of \(chrFileSize.fileSizeInBytes)"
        alert.runModal()
    }
}

@discardableResult func saveAsm6File(withCHRGrid aChrGrid:CHRGrid) -> URL? {
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = "untitled" + ".s"
    
    let result = savePanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        
        guard let fileURL = savePanel.url else { return nil }
        
        let fileText = aChrGrid.toAsm6Text()
        
        guard let fileData = fileText.data(using: .utf8) else { return nil }
        
        // write to file
        do {
            try fileData.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
            return fileURL
        }
        catch {
            let alert: NSAlert = NSAlert(error: error)
            alert.messageText = "Error saving to file. \(error.localizedDescription)"
            alert.runModal()
            return nil
        }
        
    } else {
        Swift.print("File was not saved (User canceled Save)")
        return nil
    }
}

@discardableResult func saveCArrayFile(withCHRGrid aChrGrid:CHRGrid) -> URL? {
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = "untitled" + ".c"
    
    let result = savePanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        
        guard let fileURL = savePanel.url else { return nil }
        
        let fileText = aChrGrid.toCArrayText()
        
        guard let fileData = fileText.data(using: .utf8) else { return nil }
        
        // write to file
        do {
            try fileData.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
            return fileURL
        }
        catch {
            let alert: NSAlert = NSAlert(error: error)
            alert.messageText = "Error saving to file. \(error.localizedDescription)"
            alert.runModal()
            return nil
        }
        
    } else {
        Swift.print("File was not saved (User canceled Save)")
        return nil
    }
}

func saveCHRFile(withCHRGrid aChrGrid:CHRGrid) -> URL? {
    
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = "untitled" + ".chr"
    
    let chrFileSize: ChrFileSize = ChrFileSize(numChrBlocks: aChrGrid.numChrBlocks)
    
    let result = savePanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        
        guard let fileURL = savePanel.url else { return nil }
        
        let fileData = aChrGrid.toData()
        
        if fileData.count == Int(chrFileSize.fileSizeInBytes) {
            // write to file
            do {
                try fileData.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
                return fileURL
            }
            catch {
                let alert: NSAlert = NSAlert(error: error)
                alert.messageText = "Error saving to file. \(error.localizedDescription)"
                alert.runModal()
                return nil
            }
        } else {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Error saving to file.  The number of bytes to be saved (\(fileData.count) ) does not match the expected value of \(chrFileSize.fileSizeInBytes)"
            alert.runModal()
            return nil
        }
    } else {
        Swift.print("File was not saved (User canceled Save)")
        return nil
    }
}

func openCHRFile() -> (grid: CHRGrid?, url:URL?) {
    
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseFiles = true
    
    let result = openPanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        guard let fileURL = openPanel.url else {
            return (nil, nil)
        }
        
        // read from file
        do {
            let data = try Data(contentsOf: fileURL)
            
            if data.count >= ChrFileSize(numChrBlocks: 1).fileSizeInBytes {
                return (CHRGrid(fromData: data), fileURL)
            } else {
                let alert: NSAlert = NSAlert()
                alert.messageText = "Error opening CHR file.  The number of bytes in the file (\(data.count)) does not match an expected value"
                alert.runModal()
                return (nil, nil)
            }
        }
        catch {
            return (nil, nil)
        }
    } else {
        return (nil, nil)
    }
}

func openCHRFile(withFileName aFileName:String) -> (grid: CHRGrid?, url:URL?) {
    
    if !FileManager.default.fileExists(atPath: aFileName) {
        return (nil, nil)
    }
    
    let fileURL = URL(fileURLWithPath: aFileName)
    
    // read from file
    do {
        let data = try Data(contentsOf: fileURL)
        
        if data.count >= ChrFileSize(numChrBlocks: 1).fileSizeInBytes {
            return (CHRGrid(fromData: data), fileURL)
        } else {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Error opening CHR file.  The number of bytes in the file (\(data.count)) does not match an expected value"
            alert.runModal()
            return (nil, nil)
        }
    }
    catch {
        return (nil, nil)
    }
}


// MARK: - Import / Export from NES ROM

func importCHRFromNESROMFile() -> (grid: CHRGrid?, url:URL?) {
    
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseFiles = true
    
    let result = openPanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        guard let fileURL = openPanel.url else {
            return (nil, nil)
        }
        
        // read from file
        do {
            let data = try Data(contentsOf: fileURL)
            
            let cartridge = Cartridge(fromData: data)
            
            guard cartridge.isValid else {
                let alert: NSAlert = NSAlert()
                alert.messageText = "The NES ROM appears to be invalid"
                alert.runModal()
                return (nil, nil)
            }
            
            var chrData: Data = Data()
            
            for b in cartridge.chrBlocks {
                chrData.append(contentsOf: b)
            }
            
            if cartridge.header.numChrBlocks > 0,
                chrData.count >= ChrFileSize(numChrBlocks: 1).fileSizeInBytes {
                return (CHRGrid(fromData: chrData), nil)
            } else {
                let alert: NSAlert = NSAlert()
                alert.messageText = "Error opening CHR from NES ROM. The ROM header specifies that there are 0 CHR blocks, so tile data is defined programmatically."
                alert.runModal()
                return (nil, nil)
            }
        }
        catch {
            return (nil, nil)
        }
    } else {
        return (nil, nil)
    }
}

func exportCHRToNESROMFile(withCHRGrid aChrGrid:CHRGrid) -> Bool {
    
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseFiles = true
    
    let result = openPanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        guard let fileURL = openPanel.url else {
            return false
        }
        
        // read from file
        do {
            let data = try Data(contentsOf: fileURL)
            
            let cartridge = Cartridge(fromData: data)
            
            guard cartridge.isValid else {
                Swift.print("NES ROM: ROM appears to be invalid")
                return false
            }
            
            guard cartridge.chrBlocks.count == aChrGrid.numChrBlocks else {
                let alert: NSAlert = NSAlert()
                alert.messageText = "NES ROM: The CHR Grid size (\(aChrGrid.numChrBlocks) blocks) does not match the number of CHR blocks specified in the ROM header (\(cartridge.chrBlocks.count))"
                alert.runModal()
                return false
            }
            
            let prgBlockSize: Int = 16384
            let trainerSize: Int = cartridge.header.hasTrainer ? 512 : 0
            let totalPrgSize: Int = Int(cartridge.header.numPrgBlocks) * prgBlockSize
            let trainerOffset: Int = RomHeader.sizeInBytes // trainer (if present) comes after header
            let prgOffset: Int = trainerOffset + trainerSize // prg blocks come after trainer (if present)
            let chrOffset: Int = prgOffset + totalPrgSize // chr blocks come after prg blocks
            
            let leadingData: Data = data.subdata(in: 0 ..< chrOffset)
            let newChrData: Data = aChrGrid.toData()
            
            var outputData: Data = Data()
            outputData.append(leadingData)
            outputData.append(newChrData)
    
            do {
                try outputData.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
                return true
            }
            catch {
                let alert: NSAlert = NSAlert(error: error)
                alert.messageText = "Error saving to file. \(error.localizedDescription)"
                alert.runModal()
                return false
            }
                
        }
        catch {
            return false
        }
    } else {
        return false
    }
}


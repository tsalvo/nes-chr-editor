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
    
    if fileData.count == Int(aChrGrid.fileSize.fileSizeInBytes) {
        // write to file
        do {
            try fileData.write(to: aURL, options: Data.WritingOptions.atomicWrite)
        }
        catch {
            // error handling here
            Swift.print("Error saving to file. \(error.localizedDescription)")
        }
    } else {
        Swift.print("Error saving to file.  The number of bytes to be saved (\(fileData.count) ) does not match the expected value of \(aChrGrid.fileSize.fileSizeInBytes)")
    }
}

func saveCHRFile(withCHRGrid aChrGrid:CHRGrid) -> URL? {
    
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = "untitled" + ".chr"
    
    let result = savePanel.runModal()
    
    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        
        guard let fileURL = savePanel.url else { return nil }
        
        let fileData = aChrGrid.toData()
        
        if fileData.count == Int(aChrGrid.fileSize.fileSizeInBytes) {
            // write to file
            do {
                try fileData.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
                return fileURL
            }
            catch {
                // error handling here
                Swift.print("Error saving to file. \(error.localizedDescription)")
                return nil
            }
        } else {
            Swift.print("Error saving to file.  The number of bytes to be saved (\(fileData.count) ) does not match the expected value of \(aChrGrid.fileSize.fileSizeInBytes)")
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
            
            if let _:SupportedFileSize = SupportedFileSize(rawValue: UInt(data.count) / 1024) {
                return (CHRGrid(fromData: data), fileURL)
            } else {
                Swift.print("Error opening file.  The number of bytes in the file (\(data.count)) does not match an expected value")
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
        
        if let _:SupportedFileSize = SupportedFileSize(rawValue: UInt(data.count) / 1024) {
            return (CHRGrid(fromData: data), fileURL)
        } else {
            Swift.print("Error opening file.  The number of bytes in the file (\(data.count)) does not match an expected value")
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
            
            // there must be a 16-byte header at the beginning of the ROM file, or return otherwise
            if (data.count < 16) {
                Swift.print("NES ROM: Error getting 16 byte header")
                return (nil, nil)
            }
            
            // get the first 16 bytes into an array of bytes
            let romHeaderByteArray:[UInt8] = data.withUnsafeBytes { [UInt8](UnsafeBufferPointer(start: $0, count: 16)) }
            
            // double-check that we've gotten 16 bytes, or return otherwise
            if (romHeaderByteArray.count != 16) {
                Swift.print("NES ROM: Error getting 16 byte header")
                return (nil, nil)
            }
            
            // offset 4 = num of CHR banks (16384 bytes each)
            let numPRGBanks:UInt8 = romHeaderByteArray[4]
            
            // offset 5 = number of CHR banks (8192 bytes each)
            let numCHRBanks:UInt8 = romHeaderByteArray[5]
            
            let offsetToCHRData:Int = 16 + 16384 * Int(numPRGBanks)
            let lengthOfCHRData:Int = 8192 * Int(numCHRBanks)
            
            if (data.count < offsetToCHRData + lengthOfCHRData) {
                Swift.print("NES ROM: CHR Data location is out of bounds.  CHR Data starts at byte offset \(offsetToCHRData), with length of \(lengthOfCHRData) bytes, but the length of the file is only \(data.count) bytes")
                return (nil, nil)
            }
            
            Swift.print("NES ROM: Found \(numPRGBanks) banks of PRG data, \(numCHRBanks) banks of CHR data.  CHR Data starts at byte offset \(offsetToCHRData), with length of \(lengthOfCHRData) bytes")
            
            let chrData = data.subdata(in: offsetToCHRData ..< (offsetToCHRData + lengthOfCHRData))
            
            if let _:SupportedFileSize = SupportedFileSize(rawValue: UInt(chrData.count) / 1024) {
                return (CHRGrid(fromData: chrData), nil)
            } else {
                Swift.print("Error opening CHR from NES file.  The number of bytes in the file (\(data.count)) does not match an expected value")
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
            
            // there must be a 16-byte header at the beginning of the ROM file, or return otherwise
            if (data.count < 16) {
                Swift.print("NES ROM: Error getting 16 byte header")
                return false
            }
            
            // get the first 16 bytes into an array of bytes
            let romHeaderByteArray:[UInt8] = data.withUnsafeBytes { [UInt8](UnsafeBufferPointer(start: $0, count: 16)) }
            
            // double-check that we've gotten 16 bytes, or return otherwise
            if (romHeaderByteArray.count != 16) {
                Swift.print("NES ROM: Error getting 16 byte header")
                return false
            }
            
            // offset 4 = num of CHR banks (16384 bytes each)
            let numPRGBanks:UInt8 = romHeaderByteArray[4]
            
            // offset 5 = number of CHR banks (8192 bytes each)
            let numCHRBanks:UInt8 = romHeaderByteArray[5]
            
            let offsetToCHRData:Int = 16 + 16384 * Int(numPRGBanks)
            let lengthOfCHRData:Int = 8192 * Int(numCHRBanks)
            
            if (data.count < offsetToCHRData + lengthOfCHRData) {
                Swift.print("NES ROM: CHR Data location is out of bounds.  CHR Data starts at byte offset \(offsetToCHRData), with length of \(lengthOfCHRData) bytes, but the length of the file is only \(data.count) bytes")
                return false
            }
            
            Swift.print("NES ROM: Found \(numPRGBanks) banks of PRG data, \(numCHRBanks) banks of CHR data.  CHR Data starts at byte offset \(offsetToCHRData), with length of \(lengthOfCHRData) bytes")
            
            
            let headerAndPRGDataFromNESROM = data.subdata(in: 0 ..< offsetToCHRData)
            let chrDataFromNESROM = data.subdata(in: offsetToCHRData ..< (offsetToCHRData + lengthOfCHRData))
            let trailingData:Data? = (data.count > offsetToCHRData + lengthOfCHRData) ? data.subdata(in: (offsetToCHRData + lengthOfCHRData) ..< data.count - (offsetToCHRData + lengthOfCHRData)) : nil
            
            let chrDataToSave = aChrGrid.toData()
            
            if let _:SupportedFileSize = SupportedFileSize(rawValue: UInt(chrDataFromNESROM.count) / 1024), chrDataToSave.count == chrDataFromNESROM.count {
                

                var dataToSave = Data(count: 0)
                dataToSave.append(headerAndPRGDataFromNESROM)
                dataToSave.append(chrDataToSave)
                
                if let safeTrailingData = trailingData {
                    dataToSave.append(safeTrailingData)
                }
                
                do {
                    try dataToSave.write(to: fileURL, options: Data.WritingOptions.atomicWrite)
                    return true
                }
                catch {
                    // error handling here
                    Swift.print("Error saving to file. \(error.localizedDescription)")
                    return false
                }
                
            } else {
                Swift.print("Error opening CHR from NES file.  The number of bytes in the file (\(data.count)) does not match an expected value")
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


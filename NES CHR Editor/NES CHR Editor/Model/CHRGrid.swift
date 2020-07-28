//
//  CHRGrid.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

struct CHRGrid {
    var numChrBlocks:UInt8 = 1
    var grid:[CHR] = [CHR](repeating:CHR(), count: Int(ChrFileSize(numChrBlocks: 1).numCHRsInFile))
    
    mutating func setCHR(chr:CHR, atIndex aIndex:UInt) {
        self.grid[Int(aIndex)] = chr
    }
    
    func getCHR(atIndex aIndex:UInt) -> CHR {
        return self.grid[Int(aIndex)]
    }
    
    var selectedCHRIndex:UInt = 0
    
    func toAsm6Text() -> String {
        var retValue = ""
        
        for (index, chr) in grid.enumerated() {
            retValue.append("; \(index)\n")
            retValue.append(chr.toAsm6String())
        }
        
        return retValue
    }
    
    func toData() -> Data {
        var retValue = Data()
        for chr in grid {
            retValue.append(chr.toData())
        }
        
        return retValue
    }
    
    init() { }
    
    init(withNumChrBlocks aNumChrBlocks:UInt8) {
        self.numChrBlocks = aNumChrBlocks
        self.grid = [CHR](repeating:CHR(), count: Int(ChrFileSize(numChrBlocks: aNumChrBlocks).numCHRsInFile))
    }
    
    init(fromData aData:Data) {
        
        let numChrBlocks: UInt8 = UInt8(aData.count / 8192)
        guard numChrBlocks > 0 else {
            Swift.print("Error Creating CHR Grid From Data.  The number of bytes in the data (\(aData.count)) does not match an expected value")
            return
        }
        
        self.numChrBlocks = numChrBlocks
        self.grid = [CHR](repeating:CHR(), count: Int(ChrFileSize(numChrBlocks: numChrBlocks).numCHRsInFile))
        
        for (chrIndex, _) in grid.enumerated() {
            self.grid[chrIndex] = CHR(fromData: aData.subdata(in: Range(uncheckedBounds: (chrIndex * kCHRSizeInBytes, chrIndex * kCHRSizeInBytes + kCHRSizeInBytes))))
        }
    }
}

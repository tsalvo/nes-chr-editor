//
//  Cartridge.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 7/27/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

struct Cartridge {
    init(fromData aData: Data) {
        let header = RomHeader(fromData: aData.prefix(RomHeader.sizeInBytes))
        self.data = aData
        self.header = header
        
        guard header.isValid
            else
        {
            self.chrBlocks = []
            self.prgBlocks = []
            self.trainerData = Data()
            self.isValid = false
            return
        }
        
        let prgBlockSize: Int = 16384
        let chrBlockSize: Int = 8192
        let headerSize: Int = RomHeader.sizeInBytes
        let trainerSize: Int = header.hasTrainer ? 512 : 0
        let totalPrgSize: Int = Int(header.numPrgBlocks) * prgBlockSize
        let totalChrSize: Int = Int(header.numChrBlocks) * chrBlockSize
        let trainerOffset: Int = RomHeader.sizeInBytes // trainer (if present) comes after header
        let prgOffset: Int = trainerOffset + trainerSize // prg blocks come after trainer (if present)
        let chrOffset: Int = prgOffset + totalPrgSize // chr blocks come after prg blocks
        
        let expectedFileSizeOfEntireRomInBytes: Int = headerSize + trainerSize + totalPrgSize + totalChrSize
        
        // make sure the the total file size is at least what the header indicates.  any traling data is ignored
        guard aData.count >= expectedFileSizeOfEntireRomInBytes
            else
        {
            self.chrBlocks = []
            self.prgBlocks = []
            self.trainerData = Data()
            self.isValid = false
            return
        }
        
        self.trainerData = header.hasTrainer ? aData.subdata(in: trainerOffset ..< prgOffset) : Data()
        
        var pBlocks: [[UInt8]] = []
        for i in 0 ..< Int(header.numPrgBlocks)
        {
            let offset: Int = prgOffset + (i * prgBlockSize)
            pBlocks.append([UInt8](aData.subdata(in: offset ..< offset + prgBlockSize)))
        }
        
        var cBlocks: [[UInt8]] = []
        for i in 0 ..< Int(header.numChrBlocks)
        {
            let offset: Int = chrOffset + (i * chrBlockSize)
            cBlocks.append([UInt8](aData.subdata(in: offset ..< offset + chrBlockSize)))
        }
        
        self.prgBlocks = pBlocks
        self.chrBlocks = cBlocks
        
        self.isValid = true
    }
    
    let header: RomHeader
    let data: Data
    let trainerData: Data
    let prgBlocks: [[UInt8]]
    var chrBlocks: [[UInt8]]
    let isValid: Bool
}

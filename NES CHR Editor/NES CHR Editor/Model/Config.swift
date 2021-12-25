//
//  Config.swift
//  NES CHR Editor
//
//  Created by Tom Salvo on 9/18/16.
//  Copyright © 2016 Tom Salvo. All rights reserved.
//

import Foundation

struct ChrFileSize
{
    let numChrBlocks: UInt8
    
    var sizeInKB: UInt { return UInt(self.numChrBlocks) * 8 }
    
    var friendlyName:String { return "\(self.sizeInKB) KB" }
    
    var fileSizeInBytes:UInt { return self.sizeInKB * 1024 }
    
    var numCHRsInFile:UInt { return self.fileSizeInBytes / UInt(Constants.tileSizeInBytes) }
    
    var numCHRCols:UInt { return 16 }
    
    var numCHRRows:UInt { return self.numCHRsInFile / self.numCHRCols }
    
    var sizeinPixels:(width: UInt, height:UInt) { return (UInt(Constants.tileWidth) * self.numCHRCols, UInt(Constants.tileHeight) * self.numCHRRows) }
}

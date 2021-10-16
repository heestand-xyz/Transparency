//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-10-16.
//

import CoreGraphics
#if os(macOS)
import AppKit
#endif

extension Image {
    
    var pixelSize: CGSize {
        #if os(macOS)
        guard let imageRep: NSImageRep = representations.first else {
            fatalError("Transparency: Image representation not found.")
        }
        return CGSize(width: imageRep.pixelsWide,
                      height: imageRep.pixelsHigh)
        #else
        return CGSize(width: size.width * scale,
                      height: size.height * scale)
        #endif
    }
    
}

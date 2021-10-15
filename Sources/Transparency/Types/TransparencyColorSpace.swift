//
//  Created by Anton Heestand on 2021-10-15.
//

import CoreGraphics

public enum TransparencyColorSpace: CaseIterable {
    
    case linear
    case sRGB
    case displayP3
 
    var cgColorSpace: CGColorSpace {
        switch self {
        case .linear:
            return CGColorSpace(name: CGColorSpace.linearSRGB)!
        case .sRGB:
            return CGColorSpace(name: CGColorSpace.sRGB)!
        case .displayP3:
            return CGColorSpace(name: CGColorSpace.displayP3)!
        }
    }
    
    init(image: Image) {
        #if os(macOS)
        guard let cgImage: CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Transparency: CGImage not found.")
        }
        #else
        guard let cgImage: CGImage = image.cgImage else {
            fatalError("Transparency: CGImage not found.")
        }
        #endif
        guard let cgColorSpace: CGColorSpace = cgImage.colorSpace else {
            fatalError("Transparency: CGColorSpace not found.")
        }
        var colorSpace: Self?
        for colorSpaceCase in Self.allCases {
            if colorSpaceCase.cgColorSpace == cgColorSpace {
                colorSpace = colorSpaceCase
            }
        }
        if colorSpace == nil {
            fatalError("Transparency: Color Space not supported.")
        }
        self = colorSpace!
    }
    
}

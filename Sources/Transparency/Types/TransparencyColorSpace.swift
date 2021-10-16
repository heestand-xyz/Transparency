//
//  Created by Anton Heestand on 2021-10-15.
//

import CoreGraphics
import CoreImage

public enum TransparencyColorSpace: CaseIterable {
    
    case linear
    case sRGB
    case displayP3
    
    enum TransparencyColorSpaceError: Error {
        case ciImage
        case commandQueue
        case commandBuffer
        case emptyTexture
    }
 
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
        var colorSpace: Self!
        for colorSpaceCase in Self.allCases {
            if colorSpaceCase.cgColorSpace == cgColorSpace {
                colorSpace = colorSpaceCase
            }
        }
        if colorSpace == nil {
            fatalError("Transparency: Color Space not supported.")
        }
        self = colorSpace
    }
    
}

extension TransparencyColorSpace {
    
    static func convert(image: Image, to colorSpace: Self) -> Image? {
        
        let imageColorSpace = TransparencyColorSpace(image: image)
        
        return convert(image: image, from: imageColorSpace, to: colorSpace)
    }
    
    static func convert(image: Image, from imageColorSpace: Self, to colorSpace: Self) -> Image? {
        
        let filterName: String
        switch imageColorSpace {
        case .linear:
            switch colorSpace {
            case .linear:
                return image
            case .sRGB:
                filterName = "CILinearToSRGBToneCurve"
            case .displayP3:
                print("Transparency: Warning: Display P3 color space is currently not fully supported.")
                return image
            }
        case .sRGB:
            switch colorSpace {
            case .linear:
                filterName = "CISRGBToneCurveToLinear"
            case .sRGB:
                return image
            case .displayP3:
                print("Transparency: Warning: Display P3 color space is currently not fully supported.")
                return image
            }
        case .displayP3:
            #warning("Add Support for Display P3")
            print("Transparency: Warning: Display P3 color space is currently not fully supported.")
            return image
        }
        
        guard let ciImage: CIImage = TransparencyConverter.ciImage(image: image) else {
            return nil
        }
        
        let parameters: [String : Any]? = [
            kCIInputImageKey : ciImage
        ]
        
        guard let filter: CIFilter = CIFilter(name: filterName, parameters: parameters) else {
            return nil
        }
        guard let finalImage: CIImage = filter.outputImage else {
            return nil
        }
        
        let bits = TransparencyBits(image: image)
        
        return TransparencyConverter.image(ciImage: finalImage, bits: bits, colorSpace: colorSpace)
        
    }
    
    static func convert(image: Image, to colorSpace: Self) throws -> MTLTexture {
        
        guard let ciImage: CIImage = TransparencyConverter.ciImage(image: image) else {
            throw TransparencyColorSpaceError.ciImage
        }
        
        guard let commandQueue = Transparency.metalDevice.makeCommandQueue() else {
            throw TransparencyColorSpaceError.commandQueue
        }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw TransparencyColorSpaceError.commandBuffer
        }
        
        let size: CGSize = image.pixelSize
        let bits = TransparencyBits(image: image)
        
        guard let finalTexture: MTLTexture = try? Transparency.emptyTexture(size: size, bits: bits) else {
            throw TransparencyColorSpaceError.emptyTexture
        }
        
        let context = CIContext(mtlDevice: Transparency.metalDevice)

        let destination = CIRenderDestination(width: Int(size.width),
                                              height: Int(size.height),
                                              pixelFormat: .rgba8Unorm,
                                              commandBuffer: commandBuffer,
                                              mtlTextureProvider: { finalTexture })
        destination.colorSpace = CGColorSpace(name: CGColorSpace.displayP3)

        let task = try context.startTask(toRender: ciImage, to: destination)
        
        try task.waitUntilCompleted()
        
        return finalTexture
    }
}

//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import MetalKit

struct TransparencyConverter {
    
    enum TransparencyConverterError: Error {
        case cgImage
    }
    
}

extension TransparencyConverter {
    
    static func texture(image: Image, device: MTLDevice = Transparency.metalDevice) throws -> MTLTexture {
        guard let cgImage: CGImage = Self.cgImage(image: image) else {
            throw TransparencyConverterError.cgImage
        }
        return try Self.texture(cgImage: cgImage, device: device)
    }
    
    static func texture(cgImage: CGImage, device: MTLDevice = Transparency.metalDevice) throws -> MTLTexture {
        let loader = MTKTextureLoader(device: device)
        return try loader.newTexture(cgImage: cgImage, options: nil)
    }
    
    static func texture(ciImage: CIImage, at size: CGSize, colorSpace: CGColorSpace, bits: TransparencyBits) throws -> MTLTexture {
        guard let cgImage: CGImage = Self.cgImage(ciImage: ciImage, at: size, colorSpace: colorSpace, bits: bits) else {
            throw TransparencyConverterError.cgImage
        }
        return try Self.texture(cgImage: cgImage)
    }
    
}

extension TransparencyConverter {
    
    static func image(texture: MTLTexture, colorSpace: CGColorSpace) -> Image? {
        let size = CGSize(width: texture.width, height: texture.height)
        guard let ciImage = ciImage(texture: texture, colorSpace: colorSpace) else { return nil }
        guard let bits = TransparencyBits.bits(for: texture.pixelFormat) else { return nil }
        guard let cgImage = cgImage(ciImage: ciImage, at: size, colorSpace: colorSpace, bits: bits) else { return nil }
        return image(cgImage: cgImage)
    }
    
    static func image(cgImage: CGImage) -> Image {
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        #else
        return UIImage(cgImage: cgImage)
        #endif
    }
    
    public static func image(ciImage: CIImage, bits: TransparencyBits, colorSpace: TransparencyColorSpace) -> Image? {
        #if os(macOS)
        guard let cgImage = Self.cgImage(ciImage: ciImage, at: ciImage.extent.size, colorSpace: colorSpace.cgColorSpace, bits: bits) else { return nil }
        return NSImage(cgImage: cgImage, size: ciImage.extent.size)
        #else
        return UIImage(ciImage: ciImage)
        #endif
    }
    
}

extension TransparencyConverter {
    
    static func ciImage(texture: MTLTexture, colorSpace: CGColorSpace) -> CIImage? {
        CIImage(mtlTexture: texture, options: [.colorSpace: colorSpace])
    }
    
    static func ciImage(image: Image) -> CIImage? {
        #if os(macOS)
        guard let data = image.tiffRepresentation else { return nil }
        return CIImage(data: data)
        #else
        return CIImage(image: image)
        #endif
    }
    
}

extension TransparencyConverter {
    
    static func cgImage(ciImage: CIImage, at size: CGSize, colorSpace: CGColorSpace, bits: TransparencyBits) -> CGImage? {
        CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: bits.ci, colorSpace: colorSpace)
    }
    
    static func cgImage(image: Image) -> CGImage? {
        #if os(macOS)
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        #else
        return image.cgImage
        #endif
    }
}

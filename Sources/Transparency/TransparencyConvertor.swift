//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import MetalKit

struct TransparencyConvertor {
    
    enum TransparencyConvertorError: Error {
        case cgImage
    }
    
}

extension TransparencyConvertor {
    
    static func texture(image: Image, device: MTLDevice = Transparency.metalDevice) throws -> MTLTexture {
        guard let cgImage: CGImage = Self.cgImage(image: image) else {
            throw TransparencyConvertorError.cgImage
        }
        return try Self.texture(cgImage: cgImage, device: device)
    }
    
    static func texture(cgImage: CGImage, device: MTLDevice = Transparency.metalDevice) throws -> MTLTexture {
        let loader = MTKTextureLoader(device: device)
        return try loader.newTexture(cgImage: cgImage, options: nil)
    }
    
}

extension TransparencyConvertor {
    
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
    
    static func ciImage(texture: MTLTexture, colorSpace: CGColorSpace) -> CIImage? {
        CIImage(mtlTexture: texture, options: [.colorSpace: colorSpace])
    }
    
    static func cgImage(image: Image) -> CGImage? {
        #if os(macOS)
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        #else
        return image.cgImage
        #endif
    }
    
    static func cgImage(ciImage: CIImage, at size: CGSize, colorSpace: CGColorSpace, bits: TransparencyBits) -> CGImage? {
        CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: bits.ci, colorSpace: colorSpace)
    }
    
}

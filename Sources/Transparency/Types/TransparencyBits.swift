//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import MetalKit

public enum TransparencyBits: Int, Codable, CaseIterable {
  
    case _8 = 8
    case _16 = 16
    
    public var pixelFormat: MTLPixelFormat {
        switch self {
        case ._8: return .bgra8Unorm // .rgba8Unorm
        case ._16: return .rgba16Float
        }
    }
    
    public var ci: CIFormat {
        switch self {
        case ._8: return .RGBA8
        case ._16: return .RGBAh
        }
    }
    
    public var os: OSType {
        kCVPixelFormatType_32BGRA
    }
    
    public static func bits(for pixelFormat: MTLPixelFormat) -> Self? {
        for bits in self.allCases {
            if bits.pixelFormat == pixelFormat {
                return bits
            }
        }
        return nil
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
        var bits: Self!
        switch cgImage.bitsPerComponent {
        case 8:
            bits = ._8
        case 16:
            bits = ._16
        default:
            fatalError("Transparency: Bits not found in image.")
        }
        self = bits
    }
    
    init(texture: MTLTexture) {
        guard let bits = Self.bits(for: texture.pixelFormat) else {
            fatalError("Transparency: Bits not found in texture.")
        }
        self = bits
    }
    
}

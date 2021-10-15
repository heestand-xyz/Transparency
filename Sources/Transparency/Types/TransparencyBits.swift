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
    
}

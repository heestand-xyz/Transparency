//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import CoreGraphics
import MetalKit
#if os(macOS)
import AppKit
#endif

struct TransparencyTexture {
    
    var originalImage: Image?
    var originalTexture: MTLTexture?
    
    let colorSpace: TransparencyColorSpace
    
    var image: Image {
        if let image: Image = originalImage {
            return image
        } else if let texture: MTLTexture = originalTexture {
            guard let image: Image = TransparencyConverter.image(texture: texture, colorSpace: colorSpace.cgColorSpace) else {
                fatalError("Transparency: Texture to image conversion failed.")
            }
            return image
        } else {
            fatalError("Transparency: Texture not found.")
        }
    }
    
    var ciImage: CIImage? {
        if let image: Image = originalImage {
            return TransparencyConverter.ciImage(image: image)
        } else if let texture: MTLTexture = originalTexture {
            return TransparencyConverter.ciImage(texture: texture, colorSpace: colorSpace.cgColorSpace)
        } else {
            return nil
        }
    }
    
    var texture: MTLTexture {
        if let texture: MTLTexture = originalTexture {
            return texture
        } else if let image: Image = originalImage {
            do {
                return try TransparencyConverter.texture(image: image)
            } catch {
                print("Transparency: Image to texture conversion error:", error)
                fatalError("Transparency: Image to texture conversion failed.")
            }
        } else {
            fatalError("Transparency: Texture not found.")
        }
    }
    
    var size: CGSize {
        if let texture: MTLTexture = originalTexture {
            return CGSize(width: texture.width, height: texture.height)
        } else if let image: Image = originalImage {
            #if os(macOS)
            guard let imageRep: NSImageRep = image.representations.first else {
                fatalError("Transparency: Image representation not found.")
            }
            return CGSize(width: imageRep.pixelsWide,
                          height: imageRep.pixelsHigh)
            #else
            return CGSize(width: image.size.width * image.scale,
                          height: image.size.height * image.scale)
            #endif
        } else {
            fatalError("Transparency: Texture not found.")
        }
    }
    
    var bits: TransparencyBits {
        if let texture: MTLTexture = originalTexture {
            return TransparencyBits(texture: texture)
        } else if let image: Image = originalImage {
            return TransparencyBits(image: image)
        } else {
            fatalError("Transparency: Texture not found.")
        }
    }
    
    init(image: Image) {
        originalImage = image
        colorSpace = TransparencyColorSpace(image: image)
        
    }
    
    init(texture: MTLTexture, colorSpace: TransparencyColorSpace) {
        originalTexture = texture
        self.colorSpace = colorSpace
    }
    
}

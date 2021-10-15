//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import Metal

struct TransparencyTexture {
    
    private var originalImage: Image?
    private var originalTexture: MTLTexture?
    
    private let colorSpace: TransparencyColorSpace
    
    var image: Image {
        if let image: Image = originalImage {
            return image
        } else if let texture: MTLTexture = originalTexture {
            guard let image: Image = TransparencyConvertor.image(texture: texture, colorSpace: colorSpace.cgColorSpace) else {
                fatalError("Transparency: Texture to image conversion failed.")
            }
            return image
        } else {
            fatalError("Transparency: Texture not found.")
        }
    }
    
    var texture: MTLTexture {
        if let texture: MTLTexture = originalTexture {
            return texture
        } else if let image: Image = originalImage {
            do {
                return try TransparencyConvertor.texture(image: image)
            } catch {
                print("Transparency: Image to texture conversion error:", error)
                fatalError("Transparency: Image to texture conversion failed.")
            }
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

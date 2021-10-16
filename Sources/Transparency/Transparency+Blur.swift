//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import CoreImage
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Transparency {
    
    static func blur(transparencyTexture: TransparencyTexture,
                     with transparencyBlurTexture: TransparencyTexture) throws -> MTLTexture {
        
        let ciImage: CIImage = try blur(transparencyTexture: transparencyTexture, with: transparencyBlurTexture)
        
        let texture: MTLTexture = try TransparencyConverter.texture(ciImage: ciImage,
                                                                    at: transparencyTexture.size,
                                                                    colorSpace: transparencyTexture.colorSpace.cgColorSpace,
                                                                    bits: transparencyTexture.bits)
        
        return texture
        
    }
    
    static func blur(transparencyTexture: TransparencyTexture,
                     with transparencyBlurTexture: TransparencyTexture) throws -> CIImage {
        
        guard let ciImage: CIImage = transparencyTexture.ciImage else {
            throw TransparencyError.blur(0)
        }
        guard var ciBlurImage: CIImage = transparencyBlurTexture.ciImage else {
            throw TransparencyError.blur(1)
        }
        
        if ciBlurImage.extent.size != ciImage.extent.size {
            guard let blurImage = TransparencyConverter.image(ciImage: ciBlurImage, bits: transparencyBlurTexture.bits, colorSpace: transparencyBlurTexture.colorSpace) else {
                throw TransparencyError.blur(2)
            }
            let stretchedBlurImage = Self.resize(blurImage, to: ciImage.extent.size)
            guard let stretchedCIImageB = TransparencyConverter.ciImage(image: stretchedBlurImage) else {
                throw TransparencyError.blur(3)
            }
            ciBlurImage = stretchedCIImageB
        }
        
        let radius: CGFloat = 100
        
        let parameters: [String : Any]? = [
            kCIInputImageKey : ciImage,
            "inputMask" : ciBlurImage,
            "inputRadius" : NSNumber(value: radius),
        ]
            
        guard let filter: CIFilter = CIFilter(name: "CIMaskedVariableBlur", parameters: parameters) else {
            throw TransparencyError.blur(4)
        }
        guard let finalImage: CIImage = filter.outputImage else {
            throw TransparencyError.blur(5)
        }
        
        let croppedImage: CIImage = finalImage.cropped(to: ciImage.extent)

        return croppedImage
        
    }
    
    static func resize(_ image: Image, to size: CGSize) -> Image {
        
        #if os(macOS)
        let frame: CGRect = CGRect(origin: .zero, size: CGSize(width: size.width / 2.0, height: size.height / 2.0))
        #else
        let frame: CGRect = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
        #endif
        
        #if os(macOS)
       
        let sourceRect = NSMakeRect(0, 0, image.size.width, image.size.height)
        let destSize = NSMakeSize(frame.width, frame.height)
        let destRect = NSMakeRect(0, 0, destSize.width, destSize.height)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: destRect, from: sourceRect, operation: .sourceOver, fraction: 1.0)
        newImage.unlockFocus()
        newImage.size = destSize
        let resized_image = NSImage(data: newImage.tiffRepresentation!)!
        
        #else
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: frame)
        let resized_image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        #endif
        
        return resized_image
    }
    
}

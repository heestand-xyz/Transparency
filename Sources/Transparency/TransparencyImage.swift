//
//  Created by Anton Heestand on 2021-10-15.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import MetalKit

#if os(macOS)
public typealias Image = NSImage
#else
public typealias Image = UIImage
#endif

/// Transparency Image
///
/// A transparency image is an image with multiple displacement properties.
/// This image can represent a looking glass, or a window with distortions and blur.
public struct TransparencyImage {
    
    let transparencyTexture: TransparencyTexture
    var transparencyMapTexture: TransparencyTexture?
    var transparencyBlurTexture: TransparencyTexture?
    
    var colorSpace: TransparencyColorSpace {
        transparencyTexture.colorSpace
    }
    
    var size: CGSize {
        transparencyTexture.size
    }
    
    var bits: TransparencyBits {
        transparencyTexture.bits
    }
    
    /// Transparency Image
    ///
    /// - **Named** image with an alpha channel. This image will be overlayed on top.
    /// - Optional Named **Map** will displace the underlying background.
    /// - Optional Named  **Blur** will blur the underlying background based on luminance. This mask image should be monochrome.
    ///
    /// To create a default **Map** create two gradients. One from black to red on the horizontal axis and one from black to green in the vertical axis and blend them with add or screen.
    public init(named name: String, map mapName: String? = nil, blur blurName: String? = nil) {
        guard let image: Image = Image(named: name) else {
            fatalError("Transparency: Image not found.")
        }
        var map: Image?
        if let mapName: String = mapName {
            guard let mapImage: Image = Image(named: mapName) else {
                fatalError("Transparency: Image not found.")
            }
            map = mapImage
        }
        var blur: Image?
        if let blurName: String = blurName {
            guard let blurImage: Image = Image(named: blurName) else {
                fatalError("Transparency: Image not found.")
            }
            blur = blurImage
        }
        self.init(image: image, map: map, blur: blur)
    }

    /// Transparency Image
    ///
    /// - **Image** with an alpha channel. This image will be overlayed on top.
    /// - Optional **Map** will displace the underlying background.
    /// - Optional **Blur** will blur the underlying background based on luminance. This mask image should be monochrome.
    ///
    /// To create a default **Map** create two gradients. One from black to red on the horizontal axis and one from black to green in the vertical axis and blend them with add or screen.
    public init(image: Image, map: Image? = nil, blur: Image? = nil) {
        transparencyTexture = TransparencyTexture(image: image)
        if let map: Image = map {
//            guard let linearMap: Image = TransparencyColorSpace.convert(image: map, to: .linear) else {
//                fatalError("Transparency: Color space conversion failed.")
//            }
            transparencyMapTexture = TransparencyTexture(image: map)
//            do {
//                let linearMap: Image = try TransparencyColorSpace.convert(image: map, to: .linear)
//                transparencyMapTexture = TransparencyTexture(texture: linearMap, colorSpace: .linear)
//            } catch {
//                print("Transparency: Color space conversion failed with error:", error)
//                fatalError("Transparency: Color space conversion failed.")
//            }
        }
        if let blur: Image = blur {
            transparencyBlurTexture = TransparencyTexture(image: blur)
        }
    }
    
    /// Transparency Image
    ///
    /// - **Texture** with an alpha channel. This image will be overlayed on top.
    /// - Optional **Map** will displace the underlying background.
    /// - Optional **Blur** will blur the underlying background based on luminance. This mask image should be monochrome.
    ///
    /// To create a default **Map** create two gradients. One from black to red on the horizontal axis and one from black to green in the vertical axis and blend them with add or screen.
    public init(texture: MTLTexture, map: MTLTexture? = nil, blur: MTLTexture? = nil, colorSpace: TransparencyColorSpace = .linear) {
        transparencyTexture = TransparencyTexture(texture: texture, colorSpace: colorSpace)
        if let map: MTLTexture = map {
            transparencyMapTexture = TransparencyTexture(texture: map, colorSpace: colorSpace)
        }
        if let blur: MTLTexture = blur {
            transparencyBlurTexture = TransparencyTexture(texture: blur, colorSpace: colorSpace)
        }
    }
}

extension TransparencyImage {
    
    public func layer(over backgroundName: String) -> Image {
        guard let background: Image = Image(named: backgroundName) else {
            fatalError("Transparency: Image not found.")
        }
        return layer(over: background)
    }
    
    public func layer(over background: Image) -> Image {
        Transparency.render(transparencyImage: self, over: background)
    }
    
    public func layer(over background: MTLTexture) -> MTLTexture {
        Transparency.render(transparencyImage: self, over: background, colorSpace: colorSpace)
    }
}

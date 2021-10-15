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
typealias Image = NSImage
#else
typealias Image = UIImage
#endif

/// Transparency Image
///
/// A transparency image is an image with multiple displacement properties.
/// This image can represent a looking glass, or a window with distortions and blur.
public struct TransparencyImage {
    
    private let transparencyTexture: TransparencyTexture
    private let transparencyMapTexture: TransparencyTexture?
    private let transparencyBlurTexture: TransparencyTexture?
    
    /// Transparency Image
    ///
    /// - **Named** image with an alpha channel. This image will be overlayed on top.
    /// - Optional Named **Map** will displace the underlying background.
    /// - Optional Named  **Blur** will blur the underlying background based on luminance. This mask image should be monochrome.
    ///
    /// To create a default **Map** create two gradients. One from black to red on the horizontal axis and one from black to green in the vertical axis and blend them with add or screen.
    init(named name: String, map mapName: String? = nil, blur blurName: String? = nil) {
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
    init(image: Image, map: Image? = nil, blur: Image? = nil) {
        transparencyTexture = TransparencyTexture(image: image)
        transparencyMapTexture = map != nil ? TransparencyTexture(image: map!) : nil
        transparencyBlurTexture = blur != nil ? TransparencyTexture(image: blur!) : nil
    }
    
    /// Transparency Image
    ///
    /// - **Texture** with an alpha channel. This image will be overlayed on top.
    /// - Optional **Map** will displace the underlying background.
    /// - Optional **Blur** will blur the underlying background based on luminance. This mask image should be monochrome.
    ///
    /// To create a default **Map** create two gradients. One from black to red on the horizontal axis and one from black to green in the vertical axis and blend them with add or screen.
    init(texture: MTLTexture, map: MTLTexture? = nil, blur: MTLTexture? = nil, colorSpace: TransparencyColorSpace = .linear) {
        transparencyTexture = TransparencyTexture(texture: texture, colorSpace: colorSpace)
        transparencyMapTexture = map != nil ? TransparencyTexture(texture: map!, colorSpace: colorSpace) : nil
        transparencyBlurTexture = blur != nil ? TransparencyTexture(texture: blur!, colorSpace: colorSpace) : nil
    }
}

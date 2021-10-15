//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import MetalKit

public struct Transparency {
    
    static let metalDevice: MTLDevice = {
        guard let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Transparency: Metal not supported on this device.")
        }
        return metalDevice
    }()
    
    enum TransparencyError: Error {
        case notImplemented
        case textureToImage
        case textureCGImage
        case emptyTexture
        case vertexQuadBuffer
        case shaderFunction
        case commandBuffer
        case commandEncoder
        case commandQueue
        case textureCache
        case sampler
        case image
        case blur(Int)
    }
    
    static func tryMetalRender(transparencyImage: TransparencyImage,
                               over backgroundTexture: MTLTexture) throws -> MTLTexture {
        
        let emptySize = CGSize(width: backgroundTexture.width, height: backgroundTexture.height)
        let finalTexture: MTLTexture = try Transparency.emptyTexture(size: emptySize)

        guard let commandQueue = metalDevice.makeCommandQueue() else {
            throw TransparencyError.commandQueue
        }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw TransparencyError.commandBuffer
        }

        let commandEncoder: MTLRenderCommandEncoder = try commandEncoder(texture: finalTexture, commandBuffer: commandBuffer)

        let pipeline: MTLRenderPipelineState = try pipeline()

        let sampler: MTLSamplerState = try sampler()

        let vertexBuffer: MTLBuffer = try vertexQuadBuffer()

        commandEncoder.setRenderPipelineState(pipeline)

        commandEncoder.setFragmentTexture(transparencyImage.transparencyTexture.texture, index: 0)
        commandEncoder.setFragmentTexture(backgroundTexture, index: 1)
        if let mapTexture: MTLTexture = transparencyImage.transparencyMapTexture?.texture {
            commandEncoder.setFragmentTexture(mapTexture, index: 2)
        }

        commandEncoder.setFragmentSamplerState(sampler, index: 0)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)

        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return finalTexture
    }
    
    static func tryRender(transparencyImage: TransparencyImage,
                          over transparencyBackgroundTexture: TransparencyTexture) throws -> MTLTexture {
        
        let finalBackgroundTexture: MTLTexture
        if let transparencyBlurTexture: TransparencyTexture = transparencyImage.transparencyBlurTexture {
            finalBackgroundTexture = try Self.blur(transparencyTexture: transparencyBackgroundTexture, with: transparencyBlurTexture)
        } else {
            finalBackgroundTexture = transparencyBackgroundTexture.texture
        }
        
        let finalTexture: MTLTexture = try tryMetalRender(transparencyImage: transparencyImage, over: finalBackgroundTexture)
        
        return finalTexture
        
    }
    
    static func tryRender(transparencyImage: TransparencyImage,
                          over transparencyBackgroundTexture: TransparencyTexture) throws -> Image {
        let texture: MTLTexture = try tryRender(transparencyImage: transparencyImage, over: transparencyBackgroundTexture)
        guard let image: Image = TransparencyConverter.image(texture: texture, colorSpace: transparencyImage.colorSpace.cgColorSpace) else {
            throw TransparencyError.textureToImage
        }
        return image
    }
    
    public static func tryRender(transparencyImage: TransparencyImage,
                                 over backgroundImage: Image) throws -> Image {
        let transparencyTexture = TransparencyTexture(image: backgroundImage)
        return try tryRender(transparencyImage: transparencyImage, over: transparencyTexture)
    }
    
    public static func tryRender(transparencyImage: TransparencyImage,
                                 over backgroundTexture: MTLTexture,
                                 colorSpace: TransparencyColorSpace) throws -> MTLTexture {
        let transparencyTexture = TransparencyTexture(texture: backgroundTexture, colorSpace: colorSpace)
        return try tryRender(transparencyImage: transparencyImage, over: transparencyTexture)
    }
    
    public static func render(transparencyImage: TransparencyImage,
                              over backgroundImage: Image) throws -> Image {
        do {
            let transparencyTexture = TransparencyTexture(image: backgroundImage)
            return try tryRender(transparencyImage: transparencyImage, over: transparencyTexture)
        } catch {
            print("Transparency: Render failed with error:", error)
            fatalError("Transparency: Render failed.")
        }
    }
    
    public static func render(transparencyImage: TransparencyImage,
                              over backgroundTexture: MTLTexture,
                              colorSpace: TransparencyColorSpace) throws -> MTLTexture {
        do {
            let transparencyTexture = TransparencyTexture(texture: backgroundTexture, colorSpace: colorSpace)
            return try tryRender(transparencyImage: transparencyImage, over: transparencyTexture)
        } catch {
            print("Transparency: Render failed with error:", error)
            fatalError("Transparency: Render failed.")
        }
    }
    
}

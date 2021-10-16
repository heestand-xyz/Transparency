//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import MetalKit

// MARK: - Texture

extension Transparency {
    
    static func emptyTexture(size: CGSize, metalDevice: MTLDevice = Transparency.metalDevice, bits: TransparencyBits) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: bits.pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        guard let texture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TransparencyError.emptyTexture
        }
        return texture
    }
}

// MARK: - Pipeline

extension Transparency {
    
    static func pipeline(metalDevice: MTLDevice = Transparency.metalDevice, pixelFormat: MTLPixelFormat, shaderName: String) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = try shader(name: "vertexQuad")
        pipelineStateDescriptor.fragmentFunction = try shader(name: shaderName)
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

// MARK: - Command Encoder

extension Transparency {
    
    static func commandEncoder(texture: MTLTexture, commandBuffer: MTLCommandBuffer) throws -> MTLRenderCommandEncoder {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw TransparencyError.commandEncoder
        }
        return commandEncoder
    }
}

// MARK: - Sampler

extension Transparency {
    
    static func sampler(metalDevice: MTLDevice = Transparency.metalDevice) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
        samplerInfo.sAddressMode = .clampToZero
        samplerInfo.tAddressMode = .clampToZero
        samplerInfo.compareFunction = .never
        samplerInfo.mipFilter = .linear
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw TransparencyError.sampler
        }
        return sampler
    }
}

// MARK: - Vertex Quad

extension Transparency {
    
    struct Vertex {
        let x, y: CGFloat
        let s, t: CGFloat
        var buffer: [Float] {
            [x, y, s, t].map(Float.init)
        }
    }
    
    static func vertexQuadBuffer(metalDevice: MTLDevice = Transparency.metalDevice) throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 0.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 0.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 1.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 1.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        let vertexBuffer: [Float] = vertices.flatMap(\.buffer)
        let dataSize = vertexBuffer.count * MemoryLayout.size(ofValue: vertexBuffer[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexBuffer, length: dataSize, options: []) else {
            throw TransparencyError.vertexQuadBuffer
        }
        return buffer
    }
}

// MARK: - Shader

extension Transparency {
    
    static func shader(name: String, metalDevice: MTLDevice = Transparency.metalDevice) throws -> MTLFunction {
        let metalLibrary: MTLLibrary = try metalDevice.makeDefaultLibrary(bundle: Bundle.module)
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw TransparencyError.shaderFunction
        }
        return shader
    }
}

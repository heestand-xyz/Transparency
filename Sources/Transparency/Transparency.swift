//
//  Created by Anton Heestand on 2021-10-15.
//

import Foundation
import MetalKit

class Transparency {
    
    static let metalDevice: MTLDevice = {
        guard let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Transparency: Metal not supported on this device.")
        }
        return metalDevice
    }()
    
}

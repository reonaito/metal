import MetalKit

let n = 20000000

let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = try device.makeLibrary(filepath: "atomic_add_test.metallib")
let commandBuffer = commandQueue.makeCommandBuffer()!
let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "atomic_add_test")!)
commandEncoder.setComputePipelineState(computePipelineState)

let counterBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride, options: [])!
commandEncoder.setBuffer(counterBuffer, offset: 0, index: 0)

let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numberOfThreadgroups = MTLSize(width: (n + 31) / 32, height: 1, depth: 1)
commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)

commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

print(counterBuffer.contents().load(as: UInt32.self))

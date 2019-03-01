import MetalKit

let n = 20000000

for _ in 0 ..< 3 {

  let device = MTLCreateSystemDefaultDevice()!
  let commandQueue = device.makeCommandQueue()!
  let library = try device.makeLibrary(filepath: "value_copy.metallib")
  let commandBuffer = commandQueue.makeCommandBuffer()!
  let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
  let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "value_copy")!)
  commandEncoder.setComputePipelineState(computePipelineState)

  let outputBuffer = device.makeBuffer(
    length: n * MemoryLayout<UInt32>.size,
    options: []
  )!
  commandEncoder.setBuffer(outputBuffer, offset: 0, index: 0)

  let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
  let numberOfThreadgroups = MTLSize(width: (n + 31) / 32, height: 1, depth: 1)
  commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)

  commandEncoder.endEncoding()
  commandBuffer.commit()
  commandBuffer.waitUntilCompleted()

  let outArray = Array(UnsafeBufferPointer(
    start: outputBuffer.contents().bindMemory(
      to: UInt32.self,
      capacity: n * MemoryLayout<UInt32>.size
    ),
    count: n
  ))

  print(outArray)

}

import MetalKit

var primes:[UInt32] = [2, 3, 5, 7]
var sqrt_n = 8
var n = sqrt_n * sqrt_n

let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = try device.makeLibrary(filepath: "prime.metallib")
let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "prime")!)

let cycle = 4
let max_n = (1 << 24)
for _ in 0 ..< cycle {

  let commandBuffer = commandQueue.makeCommandBuffer()!
  let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
  commandEncoder.setComputePipelineState(computePipelineState)

  let primesBuffer = device.makeBuffer(
    bytes: primes,
    length: primes.count * MemoryLayout<UInt32>.stride,
    options: []
  )!
  commandEncoder.setBuffer(primesBuffer, offset: 0, index: 0)

  let outBuffer = device.makeBuffer(
    length: n * MemoryLayout<Bool>.stride,
    options: []
  )!
  commandEncoder.setBuffer(outBuffer, offset: 0, index: 1)

  let threadPerGroup = MTLSize(width: 32, height: 32, depth: 1)
  let numberOfThreadgroups = MTLSize(
    width: (n + 31) / 32,
    height: (primes.count + 31) / 32,
    depth: 1
  )
  commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)

  commandEncoder.endEncoding()
  commandBuffer.commit()
  commandBuffer.waitUntilCompleted()

  let outArray = Array(UnsafeBufferPointer(
    start: outBuffer.contents().bindMemory(
      to: Bool.self,
      capacity: n * MemoryLayout<Bool>.stride
    ),
    count: n
  ))

  primes = primes + Array(sqrt_n ..< n).filter{ !outArray[$0] }.map { UInt32($0) }

  sqrt_n = n
  n = n * n > max_n ? max_n : n * n

}

print(primes.count, sqrt_n)

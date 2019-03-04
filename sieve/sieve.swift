import MetalKit

// values
let max_n = (1 << 28)
let prime_buf_size = 20000000
var init_primes:[UInt32] = [2, 3, 5, 7]
var init_n_primes = 4
var sqrt_n = 8
var n = sqrt_n * sqrt_n

// device
let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = try device.makeLibrary(filepath: "sieve.metallib")

// common buffers
let primesBuffer = device.makeBuffer(
  length: prime_buf_size * MemoryLayout<UInt32>.stride,
  options: []
)!
let n_primesBuffer = device.makeBuffer(
  bytes: [UInt32(init_n_primes)],
  length: MemoryLayout<UInt32>.stride,
  options: []
)!
let outBuffer = device.makeBuffer(
  length: max_n * MemoryLayout<Bool>.stride,
  options: []
)!

// init
let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "init")!)
let commandBuffer = commandQueue.makeCommandBuffer()!
let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
commandEncoder.setComputePipelineState(computePipelineState)
commandEncoder.setBytes(
  &init_primes,
  length: init_primes.count * MemoryLayout<UInt32>.stride,
  index: 0
)
commandEncoder.setBuffer(primesBuffer, offset: 0, index: 1)
let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numberOfThreadgroups = MTLSize(
  width: (init_n_primes + 31) / 32,
  height: 1,
  depth: 1
)
commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)
commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

// cycle
let cycle = 3
for _ in 0 ..< cycle {
  // sieve
  repeat {
    let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "sieve")!)
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
    commandEncoder.setComputePipelineState(computePipelineState)
    commandEncoder.setBuffer(primesBuffer, offset: 0, index: 0)
    commandEncoder.setBuffer(outBuffer, offset: 0, index: 1)
    let threadPerGroup = MTLSize(width: 32, height: 32, depth: 1)
    let n_primes = n_primesBuffer.contents().load(as: UInt32.self)
    let numberOfThreadgroups = MTLSize(
      width: (n + 31) / 32,
      height: (Int(n_primes) + 31) / 32,
      depth: 1
    )
    commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)
    commandEncoder.endEncoding()
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
  } while false

  // collect
  repeat {
    let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "collect")!)
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
    commandEncoder.setComputePipelineState(computePipelineState)
    commandEncoder.setBuffer(outBuffer, offset: 0, index: 0)
    commandEncoder.setBuffer(primesBuffer, offset: 0, index: 1)
    commandEncoder.setBuffer(n_primesBuffer, offset: 0, index: 2)
    let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
    let numberOfThreadgroups = MTLSize(
      width: (n + 31) / 32,
      height: 1,
      depth: 1
    )
    commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)
    commandEncoder.endEncoding()
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
  } while false

  // update values
  sqrt_n = n
  n = n * n > max_n ? max_n : n * n

}

// result
let n_primes = n_primesBuffer.contents().load(as: UInt32.self)
let primes = Array(UnsafeBufferPointer(
  start: outBuffer.contents().bindMemory(
    to: UInt32.self,
    capacity: Int(n_primes) * MemoryLayout<UInt32>.stride
  ),
  count: Int(n_primes)
))

print(primes.count, sqrt_n)

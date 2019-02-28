import MetalKit

let init_primes:[UInt32] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
let sqrt_n = 32
let n = sqrt_n * sqrt_n

let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = try device.makeLibrary(filepath: "prime.metallib")
let commandBuffer = commandQueue.makeCommandBuffer()!
let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "prime")!)
commandEncoder.setComputePipelineState(computePipelineState)

let primesBuffer = device.makeBuffer(
  bytes: init_primes,
  length: init_primes.count * MemoryLayout<UInt32>.size,
  options: []
)!
commandEncoder.setBuffer(primesBuffer, offset: 0, index: 0)

let n_primes:[UInt32] = [UInt32(init_primes.count)]
let n_primesBuffer = device.makeBuffer(
  bytes: n_primes,
  length: MemoryLayout<UInt32>.size,
  options: []
)!
commandEncoder.setBuffer(n_primesBuffer, offset: 0, index: 1)

let out = [Bool](repeating: false, count: n)
let outBuffer = device.makeBuffer(
  bytes:out,
  length: out.count * MemoryLayout<Bool>.size,
  options: []
)!
commandEncoder.setBuffer(outBuffer, offset: 0, index: 2)

let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numberOfThreadgroups = MTLSize(width: (n + 31) / 32, height: 1, depth: 1)
commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)

commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

let outByteLength = out.count * MemoryLayout<Bool>.size
let outData = NSData(bytesNoCopy: outBuffer.contents(), length: outByteLength, freeWhenDone: false)
var outArray = [Bool](repeating: false, count: n)
outData.getBytes(&outArray, length: outByteLength)

let primes:[UInt32] = init_primes + Array(sqrt_n ..< n).filter{ outArray[$0] }.map { UInt32($0) }

print(primes)

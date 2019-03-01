import MetalKit

var primes:[UInt32] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61]
var sqrt_n = 64
var n = sqrt_n * sqrt_n

let cycle = 3
let max_n = (1 << 24) + 100
for _ in 0 ..< cycle {

  let device = MTLCreateSystemDefaultDevice()!
  let commandQueue = device.makeCommandQueue()!
  let library = try device.makeLibrary(filepath: "prime.metallib")
  let commandBuffer = commandQueue.makeCommandBuffer()!
  let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
  let computePipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "prime")!)
  commandEncoder.setComputePipelineState(computePipelineState)

  let primesBuffer = device.makeBuffer(
    bytes: primes,
    length: primes.count * MemoryLayout<UInt32>.stride,
    options: []
  )!
  commandEncoder.setBuffer(primesBuffer, offset: 0, index: 0)
  // commandEncoder.setBytes(&primes, length: primes.count * MemoryLayout<UInt32>.stride, index: 0)
  // let primesBuffer = device.makeBuffer(
  //   bytesNoCopy: &primes,
  //   length: primes.count * MemoryLayout<UInt32>.stride,
  //   options: [],
  //   deallocator: nil
  // )
  // commandEncoder.setBuffer(primesBuffer, offset: 0, index: 0)

  var n_primes:UInt32 = UInt32(primes.count)
  commandEncoder.setBytes(&n_primes, length: MemoryLayout<UInt32>.stride, index: 1)

  let out = [Bool](repeating: false, count: n)
  let outBuffer = device.makeBuffer(
    bytes: out,
    length: out.count * MemoryLayout<Bool>.stride,
    options: []
  )!
  commandEncoder.setBuffer(outBuffer, offset: 0, index: 2)


let testBuffer = device.makeBuffer(
  length: n * MemoryLayout<UInt32>.stride,
  options: []
)!
commandEncoder.setBuffer(testBuffer, offset: 0, index: 3)



  let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
  let numberOfThreadgroups = MTLSize(width: (n + 31) / 32, height: 1, depth: 1)
  commandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadPerGroup)

  commandEncoder.endEncoding()
  commandBuffer.commit()
  commandBuffer.waitUntilCompleted()

  let testArray = Array(UnsafeBufferPointer(
    start: testBuffer.contents().bindMemory(
      to: UInt32.self,
      capacity: n * MemoryLayout<UInt32>.stride
    ),
    count: n
  ))
  print(testArray)


  let outArray = Array(UnsafeBufferPointer(
    start: outBuffer.contents().bindMemory(
      to: Bool.self,
      capacity: out.count * MemoryLayout<Bool>.stride
    ),
    count: out.count
  ))
  print(outArray.filter{$0}.count)

  primes = primes + Array(sqrt_n ..< n).filter{ outArray[$0] }.map { UInt32($0) }

  print(primes.count, n)
  print()

  sqrt_n = n
  n = n * n > max_n ? max_n : n * n

}

print(primes.count, sqrt_n)

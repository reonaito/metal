import MetalKit

let size = 100_000_000

let device       = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library      = try device.makeLibrary(filepath: "monte_carlo.metallib")
// let library = device.makeDefaultLibrary()!
let commandBuffer = commandQueue.makeCommandBuffer()!
let commandEncoder = commandBuffer.makeComputeCommandEncoder()!

guard let mcFunc = library.makeFunction(name: "monte_carlo"),
      let computePipelineState = try? device.makeComputePipelineState(function: mcFunc)
else {
    abort()
}
commandEncoder.setComputePipelineState(computePipelineState)

let outVector = [Bool](repeating: false, count: size)
let outVectorByteLength = outVector.count * MemoryLayout<Bool>.size
let outVectorBuffer = device.makeBuffer(bytes:outVector, length: outVectorByteLength, options: [])!
commandEncoder.setBuffer(outVectorBuffer, offset: 0, index: 0)

let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numberOfThredgroups = MTLSize(width: (size + 31) / 32, height: 1, depth: 1)
commandEncoder.dispatchThreadgroups(numberOfThredgroups, threadsPerThreadgroup: threadPerGroup)

commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

let outData = NSData(bytesNoCopy: outVectorBuffer.contents(), length: outVectorByteLength, freeWhenDone: false)
var outArray = [Bool](repeating: false, count: size)
outData.getBytes(&outArray, length: outVectorByteLength)

let count = outArray.reduce(0) {$1 ? $0 + 1 : $0}

print(4.0 * Double(count) / Double(outArray.count))

import MetalKit

private func prepareInputDataSet(size: Int) -> (vector: [float2], byteLength: Int) {
    var inVector: [float2] = [float2]()
    for _ in 0..<size {
        let x = Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max)
        let y = Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max)
        inVector.append(float2(x,y))
    }
    // let inVector = [float2](count: size)
    let inVectorByteLength = size * MemoryLayout<float2>.size
    return (inVector, inVectorByteLength)
}

let inputData = prepareInputDataSet(size: 10_000_000)
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

let inVectorBuffer = device.makeBuffer(bytes:inputData.vector, length: inputData.byteLength, options: [])
commandEncoder.setBuffer(inVectorBuffer, offset: 0, index: 0)

let outVector = [Bool](repeating: false, count: inputData.vector.count)
let outVectorByteLength = outVector.count * MemoryLayout<Bool>.size
let outVectorBuffer = device.makeBuffer(bytes:outVector, length: outVectorByteLength, options: [])!
commandEncoder.setBuffer(outVectorBuffer, offset: 0, index: 1)

let threadPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numberOfThredgroups = MTLSize(width: (inputData.vector.count + 31) / 32, height: 1, depth: 1)
commandEncoder.dispatchThreadgroups(numberOfThredgroups, threadsPerThreadgroup: threadPerGroup)

commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

let outData = NSData(bytesNoCopy: outVectorBuffer.contents(), length: outVectorByteLength, freeWhenDone: false)
var outArray = [Bool](repeating: false, count: inputData.vector.count)
outData.getBytes(&outArray, length: outVectorByteLength)

let count = outArray.reduce(0) {$1 ? $0 + 1 : $0}

print(4.0 * Double(count) / Double(outArray.count))

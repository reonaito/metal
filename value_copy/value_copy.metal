#include <metal_stdlib>
using namespace metal;

kernel void value_copy(device uint *output [[ buffer(0) ]],
                       uint id [[ thread_position_in_grid ]])
{
  output[id] = id;
}

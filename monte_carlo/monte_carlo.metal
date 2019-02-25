#include <metal_stdlib>
using namespace metal;

#include "Loki/loki_header.metal"

kernel void monte_carlo(device bool *outBools [[ buffer(0) ]],
                        uint id [[ thread_position_in_grid ]])
{
    const float x = Loki(id, 0, 1).rand();
    const float y = Loki(id, 1, 0).rand();
    outBools[id] = (x * x + y * y < 1.0) ? true : false;
}

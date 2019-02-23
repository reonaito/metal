#include <metal_stdlib>
using namespace metal;

/*
#include "Loki/Loki/loki_header.metal"

kernel void monte_carlo(device uint *out [[ buffer(1) ]],
                        const uint id [[ thread_position_in_grid ]])
{
    const float x = Loki(id, 0, 1).rand();
    const float y = Loki(id, 1, 0).rand();
    out[id] = (x * x + y * y < 1.0) ? true : false;
}
*/
kernel void monte_carlo(const device float2 *inPoints [[ buffer(0) ]],
                        device bool *outBools [[ buffer(1) ]],
                        uint id [[ thread_position_in_grid ]])
{
    const float2 location = inPoints[id];
    const float x = location.x;
    const float y = location.y;
    outBools[id] = (sqrt((x * x) + (y * y)) < 1.0) ? true : false;
}

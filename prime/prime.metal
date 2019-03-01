#include <metal_stdlib>
using namespace metal;

kernel void prime(device const uint *primes [[ buffer(0) ]],
                  device bool *out [[ buffer(1) ]],
                  uint2 id [[ thread_position_in_grid ]])
{
  if (id[0] % primes[id[1]] == 0) {
      out[id[0]] = true;
      return;
    }
}

#include <metal_stdlib>
using namespace metal;

kernel void prime(device const uint *primes [[ buffer(0) ]],
                  constant uint &n_primes [[ buffer(1) ]],
                  device bool *out [[ buffer(2) ]],
                  uint id [[ thread_position_in_grid ]])
{
  uint i = 0;
  for (i=0; i<n_primes; i++) {
    if (id % primes[i] == 0) {
      out[id] = false;
      return;
    }
  }
  out[id] = true;
}

#include <metal_stdlib>
using namespace metal;

kernel void init(device const uint *init_primes [[ buffer(0) ]],
                 device uint *primes [[ buffer(1) ]],
                 uint id [[ thread_position_in_grid ]])
{
  primes[id] = init_primes[id];
}

kernel void sieve(device const uint *primes [[ buffer(0) ]],
                  device bool *out [[ buffer(1) ]],
                  constant uint &n [[ buffer(2) ]],
                  uint id [[ thread_position_in_grid ]])
{
  uint p = primes[id];
  if (p == 0) { return; }
  uint k = p;
  while (k < n) {
    out[k] = true;
    k = k + p;
  }
}

kernel void collect(device const bool *out [[ buffer(0) ]],
                    device uint *primes [[ buffer(1) ]],
                    device atomic_uint &n_primes [[ buffer(2) ]],
                    constant uint &n [[ buffer(3) ]],
                    uint id [[ thread_position_in_grid ]])
{
  if (!out[id] && id > 1 && id < n) {
    uint k = atomic_fetch_add_explicit(&n_primes, 1, memory_order_relaxed);
    primes[k] = id;
  }
}

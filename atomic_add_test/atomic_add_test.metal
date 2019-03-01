#include <metal_stdlib>
using namespace metal;

kernel void atomic_add_test(device atomic_uint &counter [[ buffer(0) ]])
{
  atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
}

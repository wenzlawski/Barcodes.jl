# staticperformance.jl

# Testing static array performance from Base Vector, SVector, and Base Tuple
using BenchmarkTools
using StaticArraysBase

# Testing using Ints and enums

@enum GroupEncoding L G R

structure_enc = Base.ImmutableDict(
  0 => "LLLLLL",
  1 => "LLGLGG",
  2 => "LLGGLG",
  3 => "LLGGGL",
  4 => "LGLLGG",
  5 => "LGGLLG",
  6 => "LGGGLL",
  7 => "LGLGLG",
  8 => "LGLGGL",
  9 => "LGGLGL")

digitencoding_L = Base.ImmutableDict(
  0 => 0b0001101,
  1 => 0b0011001,
  2 => 0b0010011,
  3 => 0b0111101,
  4 => 0b0100011,
  5 => 0b0110001,
  6 => 0b0101111,
  7 => 0b0111011,
  8 => 0b0110111,
  9 => 0b0001011)

digitencoding_G = Base.ImmutableDict(
  0 => 0b0100111,
  1 => 0b0110011,
  2 => 0b0011011,
  3 => 0b0100001,
  4 => 0b0011101,
  5 => 0b0111001,
  6 => 0b0000101,
  7 => 0b0010001,
  8 => 0b0001001,
  9 => 0b0010111)

digitencoding_R = Base.ImmutableDict(
  0 => 0b1110010,
  1 => 0b1100110,
  2 => 0b1101100,
  3 => 0b1000010,
  4 => 0b1011100,
  5 => 0b1001110,
  6 => 0b1010000,
  7 => 0b1000100,
  8 => 0b1001000,
  9 => 0b1110100)

function encoding(ge::GroupEncoding, val::Int)
  if ge == L
    return digitencoding_L[val]
  elseif ge == G
    return digitencoding_G[val]
  else
    return digitencoding_R[val]
  end
end

test_v = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

static_v = @SVector [L, L, G, L, G, G]
base_v = [L, L, G, L, G, G]
base_t = (L, L, G, L, G, G)

for _ in 1:10000
  for s in statis_v
    encoding()
  end
end

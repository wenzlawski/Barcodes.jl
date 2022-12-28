include("linearbarcode.jl")
using StaticArrays
using BenchmarkTools

@enum GroupEncoding L G R

structure_enc = Base.ImmutableDict(
  0 => (L, L, L, L, L, L),
  1 => (L, L, G, L, G, G),
  2 => (L, L, G, G, L, G),
  3 => (L, L, G, G, G, L),
  4 => (L, G, L, L, G, G),
  5 => (L, G, G, L, L, G),
  6 => (L, G, G, G, L, L),
  7 => (L, G, L, G, L, G),
  8 => (L, G, L, G, G, L),
  9 => (L, G, G, L, G, L))

second_group_structure = (R, R, R, R, R, R)

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

"""
  readbitvector(io, n; ltor=true)

Read bytes from `io` into a BitArray with `n` bits, by default the MSB
of the first byte will end up as index 1 (left-to-right).  Set
`ltor=false` to get the LSB of the first byte at index 1.

credit @ethomag

Not sure if this is useful.
"""
function readbitvector(io, n; ltor=true)
  # fail if BitArray definition change
  @assert hasfield(BitArray, :chunks)
  r = BitArray(undef, n)
  # chunk type
  CT = eltype(r.chunks)
  nbytes = (n + 7) ÷ 8
  # BitArray store the first bit in LSB of chunks[1]
  rev = ltor ? bitreverse ∘ ntoh : identity
  for i in 1:nbytes÷sizeof(CT)
    r.chunks[i] = rev(read(io, CT))
  end
  # Handle any leftovers
  btail = nbytes & (sizeof(CT) - 1)
  if btail != 0
    w = reduce(|, [CT(b) << (8 * (i - 1)) for (i, b) in enumerate(read(io, btail))])
    r.chunks[end] = rev(w)
  end
  return r
end

# EAN-13
"""
    EAN_13(digits::SVector{13, Int8})

A EAN-13 barcode as specified in https://en.wikipedia.org/wiki/International_Article_Number
"""
struct EAN_13 <: LinearBarcode
  digits::SVector{13,Int8}
end

"""
    validate(bc::EAN_13)
  
Validates the barcode to be correct using the checksum
"""
function validate(bc::EAN_13)
  return ean_13_gen_checksum(bc.digits[1:end-1]) == bc.digits[end]
end

"""
    ean_13_checksum(digits)

Calculates the last digit of the barcode, as an error detection
checksum.
It is a sum of products, talking an alternating weight value of 3 or 1,
at the end calculated modulo 10.
"""
function ean_13_checksum(digits)
  return 10 - (sum(map(((i, x),) -> i % 2 == 0 ? x * 1 : x * 3, enumerate(reversed(digits)))) % 10)
end

"""
    structure_encoding(bc::EAN_13)

Retrieves the encoding index from the barcode.
The first digit of the EAN-13 barcode specifies the encoding
for the first block. Values for this can be found in structure_enc.
"""
function structure_encoding(bc::EAN_13)
  return structure_enc[bc.digits[1]]
end

"""
    encoding(ge::GroupEncoding, val)

Retrieves the encoding value for the input 'val'.
There are three encodings for EAN-13, L, G, and R.
"""
function encoding(ge::GroupEncoding, val)
  if ge == L
    return digitencoding_L[val]
  elseif ge == G
    return digitencoding_G[val]
  else
    return digitencoding_R[val]
  end
end

"""
    representation(bc::EAN_13)

Generate the bit representation of the EAN-13 barcode.

It is composed of 95 binary values, of the form
- 1-3 start marker (101)
- 4-45 first block (7 bits per integer)
- 46-50 center marker (01010)
- 51-92 second block
- 93-95 end marker (101)
"""
function representation(bc::EAN_13)
  # 95 modules
  structure = (structure_encoding(bc)..., second_group_structure...)

  rep = BitVector(undef, 95)
  rep[1:3] = [1, 0, 1]
  rep[46:50] = [0, 1, 0, 1, 0]
  rep[93:95] = [1, 0, 1]
  st = 4

  for (i, x) in enumerate(structure)
    s = digits(encoding(x, bc.digits[i+1]), base=2, pad=7)
    rep[st:st+6] = reverse(s)
    st += 7
    if i == 6
      st += 5
    end
  end

  return rep

end

en = EAN_13(@SVector [4, 0, 0, 3, 9, 9, 4, 1, 5, 5, 4, 8, 6])
@btime representation(en)

# Visualise the barcode
using Luxor

@svg begin
  tiles = Tiler(300, 100, 1, length(rep), margin=10)
  squares = first.(tiles)
  for x in eachindex(rep)
    th = tiles.tileheight - 10
    if x < 4 || 45 < x < 51 || x > length(rep) - 3
      th += 10
    end

    if rep[x]
      box(squares[x], tiles.tilewidth, th, :fill)
    end
  end
end 300 100 "/tmp/ena-13"

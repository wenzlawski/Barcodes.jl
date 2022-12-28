
using Barcodes
using Test

ent = EAN_13([4, 0, 0, 3, 9, 9, 4, 1, 5, 5, 4, 8, 6]) # valid
enf = EAN_13([4, 0, 0, 3, 9, 9, 4, 1, 5, 5, 4, 8, 5]) # invalid

@testset "ean_13_checksum" begin
  @test ean_13_val_checksum(ent)
  @test !ean_13_val_checksum(enf)
end

## General info

size determined by term "version"
version 1 is 21x21
version 40 is 177x177
each version in 4 pixels wider and taller

4 levels of error correction (data correction)
Low (~7%) 
Medium (~15%)
Quartile (~25%)
High (~30%)

## Patters

**finder patterns**: 7x7 squares places on top left, top right and bottom left corners, separated by a line of empty modules

**alignment patterns**: 5x5 squares places on the corners and intersections of an nxn grid (unless occupied by finder patterns), n ranges between 2 and 6, so there are n^2 - 3 of these, except for version 1 which has none.

**timing patterns**: horizontal and vertical line of alternating dark and light modules, connecting the finder patterns

**dark module**: just a module thats always dark, placed on the 9th column and (4 * version) + 10)-th row

**format area**: larger qr codes (7 and up) have a region reserved for that

## Encoding

using ISO-8859-1 (Latin-1) to encode, today UTF-8?

Encoding modes:
- Numeric 0001 1
- Alphanumeric 0010 2
- Byte 0100 4
- Kanji 1000 8
- ECI 0111 7

## Masking

0	`(row + column) % 2 === 0`
1	`row % 2 === 0`
2	`column % 3 === 0`
3	`(row + column) % 3 === 0`
4	`(floor(row / 2) + floor(column / 3)) % 2 === 0`
5	`row * column % 2 + row * column % 3 === 0`
6	`((row * column) % 2 + row * column % 3) % 2 === 0`
7	`((row + column) % 2 + row * column % 3) % 2 === 0`


## Step by step

- Sequencing
- Error correction
- Placing bits
- Masking
- other data encodings
- different qr sizes
- larger qr structures





### ean-13
International article number 
The 13-digit EAN-13 number consists of four components:

- GS1 prefix – 3 digits 
- Manufacturer code – variable length
- Product code – variable length
- Check digit

95 modules of equal width, from l to r
- 3 areas for start marker (101)
- 42 areas (7 per digit) to encode digits 2-7,
- 5 areas for the center marker (01010)
- 42 areas (7 per digit) to encode 8-13
- 3 areas for the end marker (101)

**Encoding**
1. Digits split into 3 groups,
   1. First digit group of 6
   2. Last digit group of 6
  
The first group is encoded using a patters where each digit has two possible encodings, one of which has even parity (G) and one odd parity (L).

The first digit is not encoded using bars and spaces but by selecting a pattern of choices between two encodings for the first group of 6 digits.

All digits in the second group are encoded using the pattern RRRRRR

Checksum computed by alternatingly multiplying each digit by 1 or 3 and at the end taking modulo 10


### UPC-E, 
Universal product code (condensed)

### EAN-8, 
EAN-13 condensed

### Code 128,
High density linear barcode

### Code 39, 
Alphanumeric barcode

### Codabar, 
Linear barcdoe

### Interleaved 2 of 5,
Continuous two-width barcode

### QR Code
Matrix barcode
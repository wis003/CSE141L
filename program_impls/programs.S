// FEC Transmitter
//
// Description: Given a series of fifteen 11-bit message blocks in data mem[0:29], generate the corresponding 16-bit encoded versions and store these in data mem[30:59].
//
// input MSW = 0 0 0 0 0 b11 b10 b9
//       LSW = b8 b7 b6 b5 b4 b3 b2 b1, where bx denotes a data bit
//
// output MSW = b11 b10 b9 b8 b7 b6 b5 p8
//        LSW = b4 b3 b2 p4 b1 p2 p1 p16, where px denotes a parity bit
//
// Algorithm:
//     p8 = ^(b11:b5)
//     p4 = ^(b11:b8,b4,b3,b2)
//     p2 = ^(b11,b10,b7,b6,b4,b3,b1)
//     p1 = ^(b11,b9,b7,b5,b4,b2,b1)
//     p16 = ^(b11:1,p8,p4,p2,p1)
//
// Example:
// Given 101_0101_0101
// mem[1] = 00000101, mem[0] = 01010101, p8 = 0, p4 = 1, p2 = 0, p1 = 1, p16 = 0
// mem[31] = 10101010 -- b11:b5, p8 = 1010101_0
// mem[30] = 01011010 -- b4:b2, p4, b1, p2:p1, p16 = 010_1_1_01_0

// initialization
set 0                           // r3 = 0
and r0 r3                       // r0 = 0
set 4                           // r3 = 4
put r3 r0                       // r4 = r0 (loop counter stored in r4)

// get MEM[2*counter] and MEM[2*counter + 1]
set 4                           // r3 = 4 (PROGRAM 1 LOOP STARTS HERE)
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
add r0 r3                       // r0 += r3
lw r1 r0                        // r1 = MEM[r0]
set 5                           // r3 = 5
put r3 r1                       // r5 = r1 (MEM[2*counter + 1] stored in r5) (input MSW)
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
lw r1 r0                        // r1 = MEM[r0]
set 6                           // r3 = 6
put r3 r1                       // r6 = r1 (MEM[2*counter] stored in r6) (input LSW)

// output MSW calculation
set 5                           // r3 = 5 (BEGIN output MSW logic)
get r0 r3                       // r0 = r5
sleft r0 r3                     // r0 = r0 << r3 (r0 = b11:b9 0 0 0 0 0)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
set 4                           // r3 = 4
sright r1 r3                    // r1 = r1 >> r3
set 1                           // r3 = 1
sleft r1 r3                     // r1 = r1 << r3 (r1 = 0 0 0 b8:b5 0)
or r0 r1                        // r0 = r0 | r1 (r0 = b11:b5 0)
xor r1 r0                       // r1 = ^(r0)
or r0 r1                        // r0 = r0 | r1 (r0 = b11:b5 p8)
set 7                           // r3 = 7
put r3 r0                       // r7 = r0 (output MSW stored in r7)

// p4 calculation
set 4                           // r3 = 4
sright r0 r3                    // r0 = r0 >> r3 (r0 = 0 0 0 0 b11:b8)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
set 1                           // r3 = 1
sright r1 r3                    // r1 = r1 >> r3 (r1 = 0 b8:b2)
set 5                           // r3 = 5
sleft r1 r3                     // r1 = r1 << r3 (r1 = b4:b2 0 0 0 0 0)
or r0 r1                        // r0 = r0 | r1 (r0 = b4:b2 0 b11:b8)
xor r1 r0                       // r1 = ^(r0)
set 9                           // r3 = 9
put r3 r1                       // r9 = r1 (p4 stored in r9)

// p2 calculation
set 12                          // r3 = 12 (mask = 0000_1100)
and r0 r3                       // r0 = r0 & r3 (r0 = 0 0 0 0 b11 b10 0 0)
set 4                           // r3 = 4
sleft r0 r3                     // r0 = r0 << r3 (r0 = b11 b10 0 0 0 0 0 0)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
set 1                           // r3 = 1
sright r1 r3                    // r1 = r1 >> r3 (r1 = 0 b8:b2)
set 54                          // r3 = 54 (mask = 0011_0110)
and r1 r3                       // r1 = r1 & r3 (r1 = 0 0 b7 b6 0 b4 b3 0)
set 6                           // r3 = 6
get r2 r3                       // r2 = r6
set 1                           // r3 = 1
and r2 r3                       // r2 = r2 & r3 (r2 = 0 0 0 0 0 0 0 b1)
or r0 r1                        // r0 = r0 | r1 (r0 = b11 b10 b7 b6 0 b4 b3 0)
or r0 r2                        // r0 = r0 | r2 (r0 = b11 b10 b7 b6 0 b4 b3 b1)
xor r1 r0                       // r1 = ^(r0)
set 10                          // r3 = 10
put r3 r1                       // r10 = r1 (p2 stored in r10)

// p1 calculation
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 5                           // r3 = 5
add r1 r3                       // r1 = r1 + r3
set 5                           // r3 = 5
sleft r1 r3                     // r1 = r1 << r3 
set 5                           // r3 = 5
add r1 r3                       // r1 = r1 + r3 (mask = 1010_0101)
and r0 r1                       // r0 = r0 & r1 (r0 = b11 0 b7 0 0 b4 0 b1)
set 5                           // r3 = 5
get r1 r3                       // r1 = r5
set 7                           // r3 = 7
sleft r1 r3                     // r1 = r1 << r3 (r1 = b9 0 0 0 0 0 0 0)
set 1                           // r3 = 1
sright r1 r3                    // r1 = r1 >> r3 (r1 = 0 b9 0 0 0 0 0 0)
set 6                           // r3 = 6
get r2 r3                       // r2 = r6
set 18                          // r3 = 18 (mask = 0001_0010)
and r2 r3                       // r2 = r2 & r3 (r2 = 0 0 0 b5 0 0 b2 0)
or r1 r2                        // r1 = r1 | r2 (r1 = 0 b9 0 b5 0 0 b2 0)
or r0 r1                        // r0 = r0 | r1 (r0 = b11 b9 b7 b5 0 b4 b2 b1)
xor r1 r0                       // r1 = ^(r0)
set 11                          // r3 = 11
put r3 r1                       // r11 = r1 (p1 stored in r11)

// p16 calculation
set 5                           // r3 = 5
get r0 r3                       // r0 = r5
xor r0 r0                       // r0 = ^(r0)
sleft r0 r3                     // r0 = r0 << r3 (r0 = 0 0 ^(b11:9) 0 0 0 0 0)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
xor r1 r1                       // r1 = ^(r1)
set 4                           // r3 = 4
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = 0 0 ^(b11:9) ^(b8:b1) 0 0 0 0)
set 7                           // r3 = 7
get r1 r3                       // r1 = r7
set 1                           // r3 = 1 (mask = 0000_0001)
and r1 r3                       // r1 = r1 & r3
set 3                           // r3 = 3
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = 0 0 ^(b11:9) ^(b8:b1) p8 0 0 0)
set 9                           // r3 = 9
get r1 r3                       // r1 = r9
set 2                           // r3 = 2
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = 0 0 ^(b11:9) ^(b8:b1) p8 p4 0 0)
set 10                          // r3 = 10
get r1 r3                       // r1 = r10
set 1                           // r3 = 1
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = 0 0 ^(b11:9) ^(b8:b1) p8 p4 p2 0)
set 11                          // r3 = 11
get r1 r3                       // r1 = r11
or r0 r1                        // r0 = r0 | r1 (r0 = 0 0 ^(b11:9) ^(b8:b1) p8 p4 p2 p1)
xor r1 r0                       // r1 = ^(r0)
set 12                          // r3 = 12
put r3 r1                       // r12 = r1 (p16 stored in r12)

// output LSW calculation
set 6                           // r3 = 6
get r0 r3                       // r0 = r6
set 1                           // r3 = 1
sright r0 r3                    // r0 = r0 >> r3
set 5                           // r3 = 5
sleft r0 r3                     // r0 = r0 << r3 (r0 = b4 b3 b2 0 0 0 0 0)
set 9                           // r3 = 9
get r1 r3                       // r1 = r9
set 4                           // r3 = 4
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = b4 b3 b2 p4 0 0 0 0)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
set 1                           // r3 = 1 (mask = 0000_0001)
and r1 r3                       // r1 = r1 | r3
set 3                           // r3 = 3
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = b4 b3 b2 p4 b1 0 0 0)
set 10                          // r3 = 10
get r1 r3                       // r1 = r10
set 2                           // r3 = 2
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = b4 b3 b2 p4 b1 p2 0 0)
set 11                          // r3 = 11
get r1 r3                       // r1 = r11
set 1                           // r3 = 1
sleft r1 r3                     // r1 = r1 << r3
or r0 r1                        // r0 = r0 | r1 (r0 = b4 b3 b2 p4 b1 p2 p1 0)
set 12                          // r3 = 12
get r1 r3                       // r1 = r12
or r0 r1                        // r0 = r0 | r1 (r0 = b4 b3 b2 p4 b1 p2 p1 p16)
set 8                           // r3 = 8
put r3 r0                       // r8 = r0 (output LSW stored in r8)

// place output (MEM[2*counter + 30] and MEM[2*counter + 31])
set 4                           // r3 = 4
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
set 31                          // r3 = 31
add r0 r3                       // r0 += r3
set 7                           // r3 = 7
get r1 r3                       // r1 = r7 (get output MSW)
sw r0 r1                        // MEM[r0] = r1 (store output MSW in MEM[2*counter + 31])
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
set 8                           // r3 = 8
get r1 r3                       // r1 = r8 (get output LSW)
sw r0 r1                        // MEM[r0] = r1 (store output LSW in MEM[2*counter + 30])

// increment logic
set 4                           // r3 = 4 (increment counter in r4)
get r0 r3                       // r0 = r4
set 1                           // r3 = 1
add r0 r3                       // r0 += r3
set 4                           // r3 = 4
put r3 r0                       // r4 = r0

// branch logic
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
and r2 r3                       // r2 = r2 & r3
set 15                          // r3 = 15
add r1 r3                       // r1 = r1 + r3
set 1                           // r3 = 1
add r2 r3                       // r2 = r2 + r3
sne r0 r1                       // r0 = (r0 != r1)
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 11                          // r3 = 11
add r1 r3                       // r1 = r1 + r3
set 4                           // r3 = 4
sleft r1 r3                     // r1 = r1 << r3 (r1 = 176)
set 8                           // r3 = 8
add r1 r3                       // r1 = r1 + r3 (r1 = 184)
b_up r0 r2 r1                   // if (r0 == r2) PC = PC - r1 (loop back to PC 4 from PC 188 if count != 15)

halt

// FEC Receiver
//
// Description: Given a series of 15 two-byte encoded data values – possibly corrupted – in data mem[64:93],
// recover the original message and write into data mem[94:123].
//
// This coding scheme can correct any single-bit error and detect any two-bit error.
//
// Implementation: Decode back into 11 bit original message, see https://en.wikipedia.org/wiki/Hamming_code#General_algorithm
// Generate parity bits --> casenum {p8, p4, p2, p1} identifies corresponding error bit or two-bit errors

// initialization
set 0                           // r3 = 0
and r0 r3                       // r0 = 0
set 4                           // r3 = 4
put r3 r0                       // r4 = r0 (loop counter stored in r4)

// get MEM[2*counter + 64] and MEM[2*counter + 65]
set 4                           // r3 = 4 (PROGRAM 2 LOOP STARTS HERE)
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
set 63
add r0 r3
set 2
add r0 r3                       // r0 = r0 + r3 (index = counter * 2 + 65)
lw r1 r0                        // r1 = MEM[r0]
set 5                           // r3 = 5
put r3 r1                       // r5 = r1 (MEM[2*counter + 65] stored in r5) (input MSW)
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
lw r1 r0                        // r1 = MEM[r0]
set 6                           // r3 = 6
put r3 r1                       // r6 = r1 (MEM[2*counter + 64] stored in r6) (input LSW)

// p8 == parity[8]
set 5
get r0 r3
set 1
not r3                          // mask = 1111_1110
and r0 r3                       // r0 = b11:b5 0
xor r0 r0                       // r0 = 0000000 parity[8]
set 5
get r1 r3
set 1                           // mask = 0000_0001
and r1 r3                       // r1 = 0000000 p8
seq r0 r1                       // r0 = (r0 == r1)
set 3
sleft r0 r3                     // r0 = 0000 (p8 == parity[8]) 000
set 9
put r3 r0                       // casenum stored in r9

// p4 == parity[4]
set 5
get r0 r3
set 15
not r3                          // mask = 1111_0000
and r0 r3                       // r0 = b11:b8 0000
set 6
get r1 r3
set 5
sright r1 r3                    // r1 = 00000 b4:b2
or r0 r1                        // r0 = b11:b8 0 b4:b2
xor r0 r0                       // r0 = 0000000 parity[4]
set 6
get r1 r3
set 4
sright r1 r3
set 1                           // mask = 0000_0001
and r1 r3                       // r1 = 0000000 p4
seq r0 r1                       // r0 = (r0 == r1)
set 2
sleft r0 r3
set 9
get r1 r3
or r0 r1                        // r0 = 0000 (p8 == parity[8]) (p4 == parity[4]) 00
put r3 r0                       // casenum stored in r9

// p2 == parity[2]
set 5
get r0 r3
set 51
not r3                          // mask = 1100_1100
and r0 r3                       // r0 = b11 b10 0 0 b7 b6 0 0
set 6
get r1 r3
set 55
not r3                          // mask = 1100_1000
and r1 r3                       // r1 = b4 b3 0 0 b1 0 0 0
set 2
sright r1 r3                    // r1 = 0 0 b4 b3 0 0 b1 0
or r0 r1                        // r0 = b11 b10 b4 b3 b7 b6 b1 0
xor r0 r0                       // r0 = 0000000 parity[2]
set 6
get r1 r3
set 2
sright r1 r3
set 1                           // mask = 0000_0001
and r1 r3                       // r1 = 0000000 p2
seq r0 r1                       // r0 = (r0 == r1)
set 1
sleft r0 r3
set 9
get r1 r3
or r0 r1                        // r0 = 0000 (p8 == parity[8]) (p4 == parity[4]) (p2 == parity[2]) 0
put r3 r0                       // casenum stored in r9

// p1 == parity[1]
set 5
get r0 r3
set 0
and r1 r3
set 10
add r1 r3
set 4
sleft r1 r3
set 10
add r1 r3                       // mask = 1010_1010
and r0 r1                       // r0 = b11 0 b9 0 b7 0 b5 0
xor r0 r0
set 2
sub r1 r3                       // mask = 1010_1000
set 6
get r2 r3
and r2 r1                       // r2 = b4 0 b2 0 b1 0 0 0
or r0 r2
xor r0 r0                       // r0 = 0000000 parity[1]
set 6
get r1 r3
set 1
sright r1 r3
set 1                           // mask = 0000_0001
and r1 r3                       // r1 = 0000000 p1
seq r0 r1                       // r0 = (r0 == r1)
set 9
get r1 r3
or r0 r1                        // r0 = 0000 (p8 == parity[8]) (p4 == parity[4]) (p2 == parity[2]) (p1 == parity[1])
put r3 r0                       // casenum stored in r9

// parity[16]
set 5
get r0 r3
xor r0 r0
set 1
sleft r0 r3
set 6
get r1 r3
set 1
not r3                          // mask = 1111_1110
and r1 r3
xor r1 r1
or r0 r1
xor r0 r0                       // parity[16]
set 6
get r1 r3
set 1
and r1 r3
seq r0 r1                       // r0 = (r0 == r1)
set 10
put r3 r0                       // (p16 == parity[16]) stored in r10

// branch to casenum logic
set 40
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO default)

// place output (MEM[2*counter + 94] and MEM[2*counter + 95])
set 4                           // r3 = 4
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
set 63
add r0 r3
set 32
add r0 r3                       // r0 = r0 + r3 (index = counter * 2 + 95)
set 7                           // r3 = 7
get r1 r3                       // r1 = r7 (get output MSW)
sw r0 r1                        // MEM[r0] = r1 (store output MSW in MEM[2*counter + 95])
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
set 8                           // r3 = 8
get r1 r3                       // r1 = r8 (get output LSW)
sw r0 r1                        // MEM[r0] = r1 (store output LSW in MEM[2*counter + 94])

// increment logic
set 4                           // r3 = 4 (increment counter in r4)
get r0 r3                       // r0 = r4
set 1                           // r3 = 1
add r0 r3                       // r0 += r3
set 4                           // r3 = 4
put r3 r0                       // r4 = r0

// branch logic
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
and r2 r3                       // r2 = r2 & r3
set 15                          // r3 = 15
add r1 r3                       // r1 = r1 + r3
set 1                           // r3 = 1
add r2 r3                       // r2 = r2 + r3
sne r0 r1                       // r0 = (r0 != r1)
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 5                           // r3 = 5
add r1 r3                       // r1 = r1 + r3
sleft r1 r3                     // r1 = r1 << r3 (r1 = 160) 
set 11                          // r3 = 11
add r1 r3                       // r1 = r1 + r3 (r1 = 171)
b_up r0 r2 r1                   // if (r0 == r2) PC = PC - r1 (loop back to PC 4 if count != 15)

halt

// default
set 5
get r0 r3
sright r0 r3                    // r0 = 00000 b11:b9
set 7
put r3 r0                       // output MSW stored in r7
set 5
get r0 r3
set 1
sright r0 r3
set 4
sleft r0 r3                     // r0 = b8:b5 0000
set 6
get r1 r3
set 5
sright r1 r3
set 1
sleft r1 r3                     // r1 = 0000 b4:b2 0
or r0 r1                        // r0 = b8:b2 0
set 6
get r1 r3
set 8                           // mask = 0000_1000
and r1 r3
set 3
sright r1 r3                    // r1 = 0000000 b1
or r0 r1                        // r0 = b8:b1
set 8
put r3 r0                       // output MSW stored in r8

// two errors
set 9
get r0 r3
set 15
slt r0 r3                       // r0 = casenum < 15
set 10
get r1 r3
and r0 r1                       // parity[16] && casenum < 15
set 1
sne r0 r3                       // r0 = ((parity[16] && casenum < 15) != 1)
set 0
and r2 r3
set 17
add r2 r3                       // jump = 17
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 0)
set 0                           // else
and r0 r3
not r0
set 7
put r3 r0                       // output MSW = 0xFF
set 8
put r3 r0                       // output LSW = 0xFF
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 3                           // r3 = 3
add r1 r3                       // r1 = r1 + r3
set 5                           // r3 = 5
sleft r1 r3                     // r1 = r1 << r3 (r1 = 96) 
set 0                           // r3 = 0
add r1 r3                       // r1 = r1 + r3 (r1 = 96)
b_up r0 r0 r1                   // if (r0 == r0) PC = PC - r1 (GOTO place output)

// casenum 0 (b11)
set 9
get r0 r3
set 0
sne r0 r3                       // r0 = (casenum != 0)
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 1)
set 7                           // else
get r0 r3
set 4                           // mask = 0000_0100
bxor r0 r3
set 7
put r3 r0                       // output MSW = 00000 !b11 b10 b9
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 1 (b10)
set 9
get r0 r3
set 1
sne r0 r3                       // r0 = (casenum != 1)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 2)
set 7                           // else
get r0 r3
set 2                           // mask = 0000_0010
bxor r0 r3
set 7
put r3 r0                       // output MSW = 00000 b11 !b10 b9
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 2 (b9)
set 9
get r0 r3
set 2
sne r0 r3                       // r0 = (casenum != 2)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 3)
set 7                           // else
get r0 r3
set 1                           // mask = 0000_0001
bxor r0 r3
set 7
put r3 r0                       // output MSW = 00000 b11 b10 !b9
set 22                          // jump = 22
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 3 (b8)
set 9
get r0 r3
set 3
sne r0 r3                       // r0 = (casenum != 3)
set 0
and r2 r3
set 14
add r2 r3                       // jump = 14
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 4)
set 8                           // else
get r0 r3
set 0
and r1 r3
set 1
add r1 r3
set 7
sleft r1 r3                     // mask = 1000_0000
bxor r0 r1
set 8
put r3 r0                       // output MSW = !b8 b7:b1
set 22                          // jump = 22
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 4 (b7)
set 9
get r0 r3
set 4
sne r0 r3                       // r0 = (casenum != 4)
set 0
and r2 r3
set 14
add r2 r3                       // jump = 14
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 5)
set 8                           // else
get r0 r3
set 0
and r1 r3
set 1
add r1 r3
set 6
sleft r1 r3                     // mask = 0100_0000
bxor r0 r1
set 8
put r3 r0                       // output MSW = b8 !b7 b6:b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 5 (b6)
set 9
get r0 r3
set 5
sne r0 r3                       // r0 = (casenum != 5)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 6)
set 8                           // else
get r0 r3
set 32                          // mask = 0010_0000
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8 b7 !b6 b5:b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 6 (b5)
set 9
get r0 r3
set 6
sne r0 r3                       // r0 = (casenum != 6)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 8)
set 8                           // else
get r0 r3
set 16                          // mask = 0001_0000
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8:b6 !b5 b4:b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 8 (b4)
set 9
get r0 r3
set 8
sne r0 r3                       // r0 = (casenum != 8)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 9)
set 8                           // else
get r0 r3
set 8                           // mask = 0000_1000
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8:b5 !b4 b3:b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 9 (b3)
set 9
get r0 r3
set 9
sne r0 r3                       // r0 = (casenum != 9)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 10)
set 8                           // else
get r0 r3
set 4                           // mask = 0000_0100
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8:b4 !b3 b2 b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 10 (b2)
set 9
get r0 r3
set 10
sne r0 r3                       // r0 = (casenum != 10)
set 0
and r2 r3
set 9
add r2 r3                       // jump = 9
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO casenum 12)
set 8                           // else
get r0 r3
set 2                           // mask = 0000_0010
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8:b3 !b2 b1
set 17                          // jump = 17
b_down r0 r0 r3                 // if (r0 == r0) PC = PC + r3 (GOTO place output)

// casenum 12 (b1)
set 9
get r0 r3
set 12
sne r0 r3                       // r0 = (casenum != 12)
set 0
and r2 r3
set 7
add r2 r3                       // jump = 7
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2 (GOTO place output)
set 8                           // else
get r0 r3
set 1                           // mask = 0000_0001
bxor r0 r3
set 8
put r3 r0                       // output MSW = b8:b2 !b1
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 3                           // r3 = 3
add r1 r3                       // r1 = r1 + r3
set 6                           // r3 = 6
sleft r1 r3                     // r1 = r1 << r3 (r1 = 192) 
set 30                          // r3 = 30
add r1 r3                       // r1 = r1 + r3 (r1 = 222)
b_up r0 r0 r1                   // if (r0 == r0) PC = PC - r1 (GOTO place output)

// Pattern Search
//
// Description: Given a continuous message string in data mem[128:159] 
// and a 5-bit pattern in bits [7:3] of data mem[160]:
// (a) Enter the total number of occurrences of the given 5-bit pattern
// in any byte into data mem[192]. Do not cross byte boundaries for this count.
// (b) Write the number of bytes within which the pattern occurs into data mem[193].
// (c) Write the total number of times it occurs anywhere in the string into data mem[194].
// For this total count, consider the 32 bytes to comprise one continuous 256-bit message,
// such that the 5-bit pattern could span adjacent portions of two consecutive bytes.

// initialization
set 0                           // r3 = 0
and r0 r3                       // r0 = 0
set 5
add r0 r3
sleft r0 r3                     // r0 = 160
lw r1 r0                        // r1 = MEM[r0]
put r3 r1                       // r5 = r1 (PATTERN stored in r5)
set 0
and r0 r3
set 4                           // r3 = 4
put r3 r0                       // r4 = r0 (loop counter stored in r4)
set 1
add r0 r3
set 7
sleft r0 r3                     // r0 = 128
lw r1 r0                        // r1 = MEM[r0]
set 6
put r3 r1                       // r6 = r1 (CURRENT_BYTE stored in r6)
set 1
add r0 r3                       // r0 = 129
lw r1 r0                        // r1 = MEM[r0]
set 7
put r3 r1                       // r7 = r1 (NEXT_BYTE stored in r7)
set 0
and r2 r3
set 8
put r3 r2                       // r8 = 0 (LOOP_TO_EIGHT stored in r8)
set 9
put r3 r2                       // r9 = 0 (COUNT_A stored in r9)
set 10
put r3 r2                       // r10 = 0 (COUNT_B stored in r10)
set 11
put r3 r2                       // r11 = 0 (COUNT_C stored in r11)
set 12
put r3 r2                       // r12 = 0 (TEMP_COUNT stored in r12)

// loop bytes 1-31
set 5                           // LOOP BACK HERE
get r0 r3
set 6
get r1 r3
set 7
not r3                          // mask = 1111_1000
and r1 r3
sne r0 r1                       // r0 = (PATTERN != CURRENT_BYTE[7:3])
set 0
and r2 r3
set 7
add r2 r3                       // jump = 7
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2
set 12
get r0 r3
set 1
add r0 r3
set 12
put r3 r0                       // increment TEMP_COUNT

// update COUNT_A, COUNT_B
set 8                           // JUMP HERE
get r0 r3
set 3
sne r0 r3                       // r0 = (LOOP_TO_EIGHT != 3)
set 0
and r2 r3
set 32
add r2 r3                       // jump = 32
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2
set 9
get r0 r3
set 12
get r1 r3
add r0 r1
set 9
put r3 r0                       // COUNT_A += TEMP_COUNT
set 0
seq r1 r3                       // r1 = (TEMP_COUNT == 0)
set 0
and r2 r3
set 7
add r2 r3                       // jump = 7
set 1
b_down r1 r3 r2                 // if (r1 == r3) PC = PC + r2
set 10
get r0 r3
set 1
add r0 r3
set 10
put r3 r0                       // increment COUNT_B

// last byte special condition
set 4                           // JUMP HERE
get r0 r3
set 31
seq r0 r3                       // r0 = (r0 == 31)
set 0
and r2 r3
set 34
add r2 r3                       // jump = 34
set 1
b_down r0 r3 r2                 // if (r0 == r3) PC = PC + r2

// shift in next bit
set 6                           // JUMP HERE
get r0 r3
set 1
sleft r0 r3
set 7
get r1 r3
sright r1 r3
or r0 r1                        // r0 = {CURRENT_BYTE[6:0], NEXT_BYTE[7]}
set 6
put r3 r0
set 7
get r1 r3
set 1
sleft r1 r3                     // r1 = {NEXT_BYTE[6:0], 0}
set 7
put r3 r1

// increment LOOP_TO_EIGHT
set 8
get r0 r3
set 1
add r0 r3
set 8
put r3 r0

// check LOOP_TO_EIGHT
sne r0 r3                       // r0 = (LOOP_TO_EIGHT != 8)
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 5                           // r3 = 5
add r1 r3                       // r1 = r1 + r3
set 4                           // r3 = 4
sleft r1 r3                     // r1 = r1 << r3 (r1 = 80) 
set 13                          // r3 = 13
add r1 r3                       // r1 = r1 + r3 (r1 = 93)
set 1
b_up r0 r3 r1                   // if (r0 == r3) PC = PC - r1

// increment logic
set 4                           // JUMP HERE
get r0 r3                       // r0 = r4
set 1                           // r3 = 1
add r0 r3                       // r0 += r3
set 4                           // r3 = 4
put r3 r0                       // r4 = r0

// update loop variables
set 0
and r1 r3
set 1
add r1 r3
set 7
sleft r1 r3                     // r1 = 128
add r1 r0
set 1
add r1 r3
lw r0 r1                        // r0 = MEM[128 + counter + 1]
set 7
put r3 r0                       // NEXT_BYTE = r0
set 11
get r0 r3
set 12
get r1 r3
add r0 r1
set 11
put r3 r0                       // COUNT_C += TEMP_COUNT
set 0
and r2 r3
set 8
put r3 r2                       // LOOP_TO_EIGHT = 0
set 12
put r3 r2                       // TEMP_COUNT = 0

// branch logic
set 4
get r0 r3                       // get counter
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
and r2 r3                       // r2 = r2 & r3
set 32                          // r3 = 32
add r1 r3                       // r1 = r1 + r3
set 1                           // r3 = 1
add r2 r3                       // r2 = r2 + r3
sne r0 r1                       // r0 = (r0 != r1)
set 0                           // r3 = 0
and r1 r3                       // r1 = r1 & r3
set 1                           // r3 = 1
add r1 r3                       // r1 = r1 + r3
set 7                           // r3 = 7
sleft r1 r3                     // r1 = r1 << r3 (r1 = 128)
set 15                          // r3 = 15
add r1 r3                       // r1 = r1 + r3 (r1 = 143)
b_up r0 r2 r1                   // if (r0 == r2) PC = PC - r1 (loop back if count != 32)

// place output
set 0
and r0 r3
set 3
add r0 r3
set 6
sleft r0 r3                     // r0 = 192
set 9
get r1 r3
sw r0 r1                        // MEM[r0] = r1 (store COUNT_A in MEM[192])
set 1
add r0 r3
set 10
get r1 r3
sw r0 r1                        // MEM[r0] = r1 (store COUNT_B in MEM[193])
set 1
add r0 r3
set 11
get r1 r3
sw r0 r1                        // MEM[r0] = r1 (store COUNT_C in MEM[194])

halt
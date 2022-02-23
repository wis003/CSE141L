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

// get MEM[index] and MEM[index + 1]
set 4                           // r3 = 4 (PROGRAM 1 LOOP STARTS HERE)
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
add r0 r3                      // r0 += r3
lw r1 r0                        // r1 = MEM[r0]
set 5                           // r3 = 5
put r3 r1                       // r5 = r1 (MEM[index] stored in r5) (input MSW)
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
lw r1 r0                        // r1 = MEM[r0]
set 6                           // r3 = 6
put r3 r1                       // r6 = r1 (MEM[index + 1] stored in r6) (input LSW)

// output MSW
set 5                           // r3 = 5 (BEGIN output MSW logic)
get r0 r3                       // r0 = r5
sleft r0 r3                     // r0 = r0 << r3 (r0 = b11 b10 b9 0 0 0 0 0)
set 6                           // r3 = 6
get r1 r3                       // r1 = r6
set 4                           // r3 = 4
sright r1 r3                    // r1 = r1 >> r3
set 1                           // r3 = 1
sleft r1 r3                     // r1 = r1 << r3 (r1 = 0 0 0 b8 b7 b6 b5 0)
or r0 r1                        // r0 = r0 | r1 (r0 = b11:b5 0)
xor r1 r0                       // r1 = ^(r0)
or r0 r1                        // r0 = r0 | r1 (r0 = b11:b5 p8)
set 7                           // r3 = 7
put r3 r0                       // r7 = r0 (output MSW stored in r7)

// output LSW
// TODO

// place output (MEM[index + 30] and MEM[index + 31])
set 4                           // r3 = 4
get r0 r3                       // r0 = r4 (get counter)
set 1                           // r3 = 1
sleft r0 r3                     // r0 = r0 << r3 (index = counter * 2)
set 31                          // r3 = 31
add r0 r3                       // r0 += r3
set 7                           // r3 = 7
get r1 r3                       // r1 = r7 (get output MSW)
sw r0 r1                        // MEM[r0] = r1 (store output MSW in MEM[index + 31])
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
set 8                           // r3 = 8
get r1 r3                       // r1 = r8 (get output LSW)
sw r0 r1                        // MEM[r0] = r1 (store output LSW in MEM[index + 30])

// increment logic
set 4                           // r3 = 4 (increment counter in r4)
get r0 r3                       // r0 = r4
set 1                           // r3 = 1
add r0 r3                       // r0 += r3
set 4                           // r3 = 4
put r3 r0                       // r4 = r0

// branch logic
set 0                           // r3 = 0
and r2 r3                       // r2 = r2 & r3
set 15                          // r3 = 15
add r2 r3                       // r2 = r2 + r3
set 4                           // r3 = 4
bne r0 r2 r3                    // if (r0 != r2) PC = r3 (loop back to PC 5 if count != 15)
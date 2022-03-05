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
add r0 r3                       // r0 += r3
lw r1 r0                        // r1 = MEM[r0]
set 5                           // r3 = 5
put r3 r1                       // r5 = r1 (MEM[index + 1] stored in r5) (input MSW)
set 1                           // r3 = 1
sub r0 r3                       // r0 -= r3
lw r1 r0                        // r1 = MEM[r0]
set 6                           // r3 = 6
put r3 r1                       // r6 = r1 (MEM[index] stored in r6) (input LSW)

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
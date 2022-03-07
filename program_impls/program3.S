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
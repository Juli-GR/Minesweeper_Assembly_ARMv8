    .equ CELLS_X,         16
    .equ CELLS_Y,         12
    .equ BOMBS,           32    // 1/6 of the total cells, as usual

    .equ RAND_NUM_A,      1812433253
    .equ RAND_NUM_B,      4644327
    .equ SEED,            4839

.globl create_cells_matrix
create_cells_matrix:
    b initialize

/*
normal cells: 1 to 8, indicates number of bombs around them
bombs: 9
*/
.globl create_bombs_matrix
create_bombs_matrix:

    sub sp, sp, 40
    str x19, [sp, 32]
    str x20, [sp, 24]
    str x21, [sp, 16]
    str x22, [sp, 8]
    str lr, [sp]

    // x2: matrix

    // x22: reg for randomNumber
    mov x22, SEED

    bl initialize

    mov x19, BOMBS
placeBomb:
    cbz x19, placeNums          // placeNums does the final ret
    bl randomNumber
    lsl x1, x1, 2
    add x10, x2, x1
    ldur w9, [x10]
    cmp x9, 9
    b.eq placeBomb
    mov x9, 9
    stur w9, [x10]
    sub x19, x19, 1
    b placeBomb

/*
if arr[current_num]==9: add one to every not-9-forward-neighbor
else: arr[current_num]++ for every 9-forward-neighbor
4 cases, depending on the possible forward-neighbors:
    1- 1st column without last cell
    2- last column without last cell
    3- middle columns without last row
    4- last row without last cell
notice that:
    the very last cell is excluded
    the algorithm works with any order of the cells
*/
placeNums:
    bl case1
    bl case2
    bl case3
    bl case4
    ldr lr, [sp]
    ldr x22, [sp, 8]
    ldr x21, [sp, 16]
    ldr x20, [sp, 24]
    ldr x19, [sp, 32]
    add sp, sp, 40
    ret

/*
x20*CELLS_X + x21: current_num
x21, x20 from 0
current_num from 0 to CELLS_X*CELLS_Y -1
x1: current_num, x7: neighbor
      cn x3
   x4 x5 x6
*/
_placeNums:
    sub sp, sp, 8
    str lr, [sp]

    mov x1, CELLS_X             // calculate current_num (* 4)
    mul x1, x20, x1
    add x1, x1, x21
    lsl x1, x1, 2

    cbz x3, reg4
    add x7, x1, 4
    bl action
reg4:
    cbz x4, reg5
    mov x10, CELLS_X
    lsl x10, x10, 2
    add x7, x1, x10
    sub x7, x7, 4
    bl action
reg5:
    cbz x5, reg6
    mov x10, CELLS_X
    lsl x10, x10, 2
    add x7, x1, x10
    bl action
reg6:
    cbz x6, endPlaceNums
    mov x10, CELLS_X
    lsl x10, x10, 2
    add x7, x1, x10
    add x7, x7, 4
    bl action
endPlaceNums:
    ldr lr, [sp]
    add sp, sp, 8
    ret

action:
    sub sp, sp, 8
    str lr, [sp]
    add x12, x2, x1
    add x13, x2, x7
    ldur w10, [x12]
    ldur w11, [x13]
    cmp x10, 9
    b.eq isBomb
    cmp x11, 9
    b.ne endAction
    add x10, x10, 1
    stur w10, [x12]
    b endAction
isBomb:
    cmp x11, 9
    b.eq endAction
    add x11, x11, 1
    stur w11, [x13]
endAction:
    ldr lr, [sp]
    add sp, sp, 8
    ret


case1:
    sub sp, sp, 8
    str lr, [sp]
    mov x3, 1
    mov x4, 0
    mov x5, 1
    mov x6, 1
    // loop through 1st col, call _placeNums
    mov x21, xzr                // 1st col
    mov x20, CELLS_Y            // iterate on y
    sub x20, x20, 1             // -1 bc last cell not included
_case1:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, _case1
    ldr lr, [sp]
    add sp, sp, 8
    ret

case2:
    sub sp, sp, 8
    str lr, [sp]
    mov x3, 0
    mov x4, 1
    mov x5, 1
    mov x6, 0
    // loop through last col, call _placeNums
    mov x21, CELLS_X            // last col
    sub x21, x21, 1             // -1 bc indexing starts at 0
    mov x20, CELLS_Y            // iterate on y
    sub x20, x20, 1             // -1 bc last cell not included
_case2:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, _case2
    ldr lr, [sp]
    add sp, sp, 8
    ret

case3:
    sub sp, sp, 8
    str lr, [sp]
    mov x3, 1
    mov x4, 1
    mov x5, 1
    mov x6, 1
    // loop through the middle, call _placeNums
    mov x21, CELLS_X            // iterate on x
    sub x21, x21, 1             // -1 bc last col not included
_case3:
    sub x21, x21, 1
    mov x20, CELLS_Y            // iterate on y
    sub x20, x20, 1             // -1 bc last row not included
__case3:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, __case3
    cmp x21, 1                  // compare with 1 bc 1st col not included
    b.ne _case3
    ldr lr, [sp]
    add sp, sp, 8
    ret

case4:
    sub sp, sp, 8
    str lr, [sp]
    mov x3, 1
    mov x4, 0
    mov x5, 0
    mov x6, 0
    // loop through last row, call _placeNums
    mov x21, CELLS_X            // iterate on x
    sub x21, x21, 1             // -1 bc last cell not included
    mov x20, CELLS_Y            // last row
    sub x20, x20, 1             // -1 bc indexing starts at 0
_case4:
    sub x21, x21, 1
    bl _placeNums
    cbnz x21, _case4
    ldr lr, [sp]
    add sp, sp, 8
    ret



// init matrix with 0s (stored in x2)
initialize:
    mov x10, CELLS_X
    mov x11, CELLS_Y
    mul x10, x10, x11
    lsl x10, x10, 2
_initialize:
    sub x10, x10, 4
    add x12, x2, x10
    stur wzr, [x12]
    cbnz x10, _initialize
    ret

/*
generate random num between 0 and CELLS_X*CELLS_Y-1
returns the value in x1
*/
randomNumber:
    ldr x9, =RAND_NUM_A
    mul x22, x22, x9
    ldr x9, =RAND_NUM_B
    add x22, x22, x9            // x22: x22*RAND_NUM_A + RAND_NUM_B

    // keep the low 32 bits
    mov x11, 1
    lsl x11, x11, 32
    sub x11, x11, 1             // x11: 0..01..1
    and x22, x22, x11

    mov x10, CELLS_X
    mov x11, CELLS_Y
    mul x10, x10, x11           // x10: CELLS_X*CELLS_Y = N
    mul x1, x22, x10            // x1: x22*N
    lsr x1, x1, 32              // keep the high 32 bits

    ret

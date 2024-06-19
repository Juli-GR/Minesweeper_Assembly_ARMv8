.equ CELLS_X,         16
.equ CELLS_Y,         12
.equ BOMBS,           32    // 1/6 of the total cells, as usual

/*
normal cells: 1 to 8, indicates number of bombs around them
bombs: 9
*/
.globl create_bombs_matrix
create_bombs_matrix:

    // x2: matrix

    // save x19, x20, x21, lr (lr todas las veces!!!!!!!!!!!!!!!!)

    bl initialize

    mov x19, BOMBS
placeBomb:
    cbz x19, placeNums      // placeNums does the final ret
    bl randomNumber
    lsl x1, x1, 2
    ldr x9, [x2, x1]
    cmp x9, 9
    b.eq placeBomb
    mov x9, 9
    str x9, [x2, x1]
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
    ret

// x20*(CELLS_X-1) + x21: current_num
// x20, x21 from 0
// current_num from 0 to CELLS_X*CELLS_Y -1
// x1: current_num, x7: neighbor
_placeNums:
    //       cn x3
    //    x4 x5 x6
    mov x1, CELLS_X      // calculate current_num * 4
    mul x1, x20, x1
    sub x1, x1, CELLS_X
    add x1, x1, x21
    lsl x1, x1, 2

    cbz x3, reg4
    add x7, x1, 4
    bl action
reg4:
    cbz x4, reg5
    add x7, x1, CELLS_X
    sub x7, x7, 4
    bl action
reg5:
    cbz x5, reg6
    add x7, x1, CELLS_X
    bl action
reg6:
    cbz x6, endPlaceNums
    add x7, x1, CELLS_X
    add x7, x7, 4
    bl action
endPlaceNums:
    ret

action:
    ldr x10, [x2, x1]
    ldr x11, [x2, x7]
    cmp x10, 9
    b.eq isBomb
    cmp x11, 9
    b.ne endAction
    add x10, x10, 1
    str x10, [x2, x1]
    b endAction
isBomb:
    cmp x11, 9
    b.eq endAction
    add x11, x11, 1
    str x11, [x2, x7]
endAction:
    ret


case1:
    mov x3, 1
    mov x4, 0
    mov x5, 1
    mov x6, 1
    // loop through 1st col, call _placeNums
    mov x21, xzr        // 1st col
    mov x20, CELLS_Y     // iterate on y
    sub x20, x20, 1     // -1 bc last cell not included
_case1:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, _case1
    ret

case2:
    mov x3, 0
    mov x4, 1
    mov x5, 1
    mov x6, 0
    // loop through last col, call _placeNums
    mov x21, CELLS_X     // last col
    sub x21, x21, 1     // -1 bc indexing starts at 0
    mov x20, CELLS_Y     // iterate on y
    sub x20, x20, 1     // -1 bc last cell not included
_case2:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, _case2
    ret

case3:
    mov x3, 1
    mov x4, 1
    mov x5, 1
    mov x6, 1
    // loop through the middle, call _placeNums
    mov x21, CELLS_X     // iterate on x
    sub x21, x21, 1     // -1 bc last col not included
_case3:
    sub x21, x21, 1
    mov x20, CELLS_Y     // iterate on y
    sub x20, x20, 1     // -1 bc last row not included
__case3:
    sub x20, x20, 1
    bl _placeNums
    cbnz x20, __case3
    cmp x21, 1          // compare with 1 bc 1st col not included
    b.ne _case3
    ret

case4:
    mov x3, 1
    mov x4, 0
    mov x5, 0
    mov x6, 0
    // loop through last row, call _placeNums
    mov x21, CELLS_X     // iterate on x
    sub x21, x21, 1     // -1 bc last cell not included
    mov x20, CELLS_Y     // last row
    sub x20, x20, 1     // -1 bc indexing starts at 0
_case4:
    sub x21, x21, 1
    bl _placeNums
    cbnz x20, _case4
    ret



// init matrix with 0s (stored in x2)
initialize:
    ret

// generate random num between 0 and CELLS_X*CELLS_Y-1
// returns the value in x1
randomNumber:
    ret

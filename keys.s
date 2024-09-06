    .equ CELLS_X,         16
    .equ CELLS_Y,         12
    .equ BOMBS,           32    // 1/6 of the total cells, as usual

.globl move_left
move_left:
    cbz x21, userInputLoop
    mov x1, x21
    mov x2, x22
    bl unmark_cell
    sub x21, x21, 1
    mov x1, x21
    mov x2, x22
    bl draw_marked_cell
    b userInputLoop

.globl move_down
move_down:
    mov x2, CELLS_Y
    sub x2, x2, 1
    cmp x22, x2
    b.eq userInputLoop
    mov x1, x21
    mov x2, x22
    bl unmark_cell
    mov x1, x21
    add x22, x22, 1
    mov x2, x22
    bl draw_marked_cell
    b userInputLoop

.globl move_right
move_right:
    mov x1, CELLS_X
    sub x1, x1, 1
    cmp x21, x1
    b.eq userInputLoop
    mov x1, x21
    mov x2, x22
    bl unmark_cell
    add x21, x21, 1
    mov x1, x21
    mov x2, x22
    bl draw_marked_cell
    b userInputLoop

.globl move_up
move_up:
    cbz x22, userInputLoop
    mov x1, x21
    mov x2, x22
    bl unmark_cell
    mov x1, x21
    sub x22, x22, 1
    mov x2, x22
    bl draw_marked_cell
    b userInputLoop

unmark_cell:
    sub sp, sp, 8
    str lr, [sp]
    mov x10, CELLS_X
    mul x10, x10, x2
    add x10, x10, x1
    lsl x10, x10, 2
    add x11, x19, x10
    add x12, x20, x10
    ldur w9, [x12]
    cmp x9, 1
    b.eq open
    b.gt flag
    bl draw_closed_cell
    b _unmark_cell
flag:
    bl draw_flag
    b _unmark_cell
open:
    ldur w3, [x11]
    bl draw_open_cell
_unmark_cell:
    ldr lr, [sp]
    add sp, sp, 8
    ret


.globl set_flag
set_flag:
    mov x10, CELLS_X
    mul x10, x10, x22
    add x10, x10, x21
    lsl x10, x10, 2
    add x11, x19, x10
    add x12, x20, x10
    ldur w9, [x12]
    cmp x9, 1
    b.eq userInputLoop          // if the cell is open
                                // jump back to userInputLoop
    mov x1, x21
    mov x2, x22
    b.gt remove_flag
    mov x9, 2
    stur w9, [x12]
    bl draw_flag
    b userInputLoop
remove_flag:
    mov x9, 0
    stur w9, [x12]
    bl draw_closed_cell
    b userInputLoop


/*
open current cell if doesn't have a flag
run the cascade algorithm if it is a 0-cell
return value in x1:
    1 --> Win
    2 --> Loss
    0 --> Otherwise
*/
.globl openCell
openCell:
    sub sp, sp, 16
    str x23, [sp, 8]
    str lr, [sp]

    mov x10, CELLS_X
    mul x10, x10, x22
    add x10, x10, x21
    lsl x10, x10, 2             // x10: ( y*CELLS_X + x ) * 4
    add x23, x19, x10           // x23: index in the bombs matrix
    add x12, x20, x10           // x12: index in the cells matrix

    // check that it doesn't have a flag
    ldur w9, [x12]
    cmp x9, 2
    b.eq _openCell

    mov x9, 1
    stur w9, [x12]              // open the cell
    add x25, x25, 1             // increase open cells counter

    mov x1, x21
    mov x2, x22
    ldur w3, [x23]
    bl draw_open_cell           // draw the open cell

    mov x1, x21
    mov x2, x22
    bl draw_marked_cell         // draw the marked cell

    // run cascade algorithm only if it is a 0-cell
    ldur w9, [x23]
    cbnz x9, skip_cascade
    mov x1, x21
    mov x2, x22
    mov x3, x19
    mov x4, x20
    bl cascade

skip_cascade:
    // set ret value in x1
    mov x1, 0
    ldur w9, [x23]
    cmp x9, 9
    b.ne not_bomb
    mov x1, 2                   // x1=2 if the cell was a bomb
    b _openCell
not_bomb:
    mov x9, CELLS_X
    mov x13, CELLS_Y
    mul x9, x9, x13
    sub x9, x9, BOMBS           // x9: CELLS_X*CELLS_Y - BOMBS
    cmp x25, x9
    b.ne _openCell
    mov x1, 1                   // x1=1 if all non-bomb cells were opened
_openCell:
    ldr lr, [sp]
    ldr x23, [sp, 8]
    add sp, sp, 16
    ret

.equ CELLS_X,         16
.equ CELLS_Y,         12

.globl move_left
move_left:
    cbz x21, userInputLoop
    mov x1, x21
    mov x2, x22
    bl draw_closed_cell     // TODO
                            // draw the cells based on the cells array
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
    bl draw_closed_cell
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
    bl draw_closed_cell
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
    bl draw_closed_cell
    mov x1, x21
    sub x22, x22, 1
    mov x2, x22
    bl draw_marked_cell
    b userInputLoop

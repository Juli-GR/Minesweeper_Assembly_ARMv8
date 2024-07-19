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
    cbnz x9, open
    bl draw_closed_cell
    b _unmark_cell
open:
    ldur w3, [x11]
    bl draw_open_cell
_unmark_cell:
    ldr lr, [sp]
    add sp, sp, 8
    ret

.globl openCell
openCell:
    sub sp, sp, 16
    str x23, [sp, 8]
    str lr, [sp]
    mov x1, x21
    mov x2, x22
    mov x10, CELLS_X
    mul x10, x10, x2
    add x10, x10, x1
    lsl x10, x10, 2
    add x23, x19, x10
    add x12, x20, x10
    mov x9, 1
    stur w9, [x12]
    ldur w3, [x23]
    bl draw_open_cell
    mov x1, x21
    mov x2, x22
    bl draw_marked_cell
    ldur w9, [x23]
    cbnz x9, no_cascade     // run cascade algorithm only if the cell is 0
    mov x1, x21
    mov x2, x22
    mov x3, x19
    mov x4, x20
    bl cascade
no_cascade:
    mov x1, 0
    ldur w3, [x23]
    cmp x3, 9
    b.ne _openCell
    mov x1, 2
    b __openCell
_openCell:
    add x25, x25, 1
    mov x9, CELLS_X
    mov x13, CELLS_Y
    mul x9, x9, x13
    sub x9, x9, BOMBS
    cmp x25, x9
    b.ne __openCell
    mov x1, 1
__openCell:
    ldr lr, [sp]
    ldr x23, [sp, 8]
    add sp, sp, 16
    ret

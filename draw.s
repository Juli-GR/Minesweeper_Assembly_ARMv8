    .equ CELLS_X,         16
    .equ CELLS_Y,         12
    .equ PIXELS_PER_CELL, 40
    .equ SHADOW_PIXELS,   4
    .equ NUMBERS_WIDTH,   3
    .equ NUMBERS_HEIGHT,  24
    .equ SPACES_WIDTH,    4

    .equ PINK,            0xff9fbf
    .equ WHITE_PINK,      0xffc8da
    .equ DARK_PINK,       0xe86c95
    .equ RED,             0xe41818
    .equ LIGHT_GRAY,      0xe4e4e4
    .equ DARK_GRAY,       0xd9d9d9
    .equ BLACK,           0x808080

// x from 0 to CELLS_X-1
// y from 0 to CELLS_Y-1

.globl draw_board
draw_board:
	sub sp, sp, 24
    str x21, [sp, 16]
    str x20, [sp, 8]
    str lr, [sp]
    mov x21, CELLS_X            // iterate on x
_draw_board:
    sub x21, x21, 1
    mov x20, CELLS_Y            // iterate on y
__draw_board:
    sub x20, x20, 1
    mov x1, x21
    mov x2, x20
    bl draw_closed_cell
    cbnz x20, __draw_board
    cbnz x21, _draw_board

    ldr lr, [sp]
    ldr x20, [sp, 8]
    ldr x21, [sp, 16]
    add sp, sp, 24
    ret


.globl draw_marked_cell
draw_marked_cell:
    // args: x1: x, x2: y
    sub sp, sp, 16
    str x22, [sp, 8]
    str lr, [sp]

    ldr x5, =RED
    mov x22, PIXELS_PER_CELL
    mul x1, x1, x22
    mul x2, x2, x22

    add x3, x1, PIXELS_PER_CELL
    add x4, x2, SHADOW_PIXELS
    bl square
    add x4, x2, PIXELS_PER_CELL
    sub x2, x4, SHADOW_PIXELS
    bl square
    add x3, x1, SHADOW_PIXELS
    sub x2, x4, PIXELS_PER_CELL
    bl square
    add x3, x1, PIXELS_PER_CELL
    sub x1, x3, SHADOW_PIXELS
    bl square

    ldr lr, [sp]
    ldr x22, [sp, 8]
    add sp, sp, 16
    ret

.globl draw_closed_cell
draw_closed_cell:
    // args: x1: x, x2: y
    sub sp, sp, 16
    str x22, [sp, 8]
    str lr, [sp]

    // x22: counter

    // calculate the start pos of the cells
    mov x22, PIXELS_PER_CELL
    mul x1, x1, x22
    mul x2, x2, x22

    // draw the center square
    ldr x5, =PINK
    mov x22, PIXELS_PER_CELL
    sub x22, x22, SHADOW_PIXELS
    add x3, x1, x22
    add x4, x2, x22
    add x1, x1, SHADOW_PIXELS
    add x2, x2, SHADOW_PIXELS
    bl square

    ldr x5, =WHITE_PINK
    sub x1, x1, SHADOW_PIXELS
    sub x2, x2, SHADOW_PIXELS

    mov x22, 0
upper_side:
    mov x3, PIXELS_PER_CELL
    add x3, x3, x1
    sub x3, x3, x22
    mov x4, x2
    add x4, x4, 1
    bl square
    add x22, x22, 1
    add x2, x2, 1               // next row
    cmp x22, SHADOW_PIXELS
    b.ne upper_side

    sub x2, x2, SHADOW_PIXELS
    mov x22, 0
left_side:
    mov x4, PIXELS_PER_CELL
    add x4, x4, x2
    sub x4, x4, x22
    mov x3, x1
    add x3, x3, 1
    bl square
    add x22, x22, 1
    add x1, x1, 1               // next col
    cmp x22, SHADOW_PIXELS
    b.ne left_side

    ldr x5, =DARK_PINK
    sub x3, x1, SHADOW_PIXELS
    add x3, x3, PIXELS_PER_CELL
    add x2, x2, PIXELS_PER_CELL
    sub x2, x2, 1

    mov x22, 0
lower_side:
    mov x1, PIXELS_PER_CELL
    sub x1, x3, x1
    add x1, x1, x22
    add x1, x1, 1
    mov x4, x2
    add x4, x4, 1
    bl square
    add x22, x22, 1
    sub x2, x2, 1               // prev row
    cmp x22, SHADOW_PIXELS
    b.ne lower_side

    sub x1, x1, SHADOW_PIXELS
    add x1, x1, PIXELS_PER_CELL
    sub x1, x1, 1
    add x4, x2, SHADOW_PIXELS
    add x4, x4, 1

    mov x22, 0
right_side:
    mov x2, PIXELS_PER_CELL
    sub x2, x4, x2
    add x2, x2, x22
    add x2, x2, 1
    mov x3, x1
    add x3, x3, 1
    bl square
    add x22, x22, 1
    sub x1, x1, 1               // prev col
    cmp x22, SHADOW_PIXELS
    b.ne right_side

    ldr lr, [sp]
    ldr x22, [sp, 8]
    add sp, sp, 16
    ret

.globl draw_open_cell
draw_open_cell:
    // x1: x, x2: y
    // x3: number
    sub sp, sp, 48
    str x21, [sp, 40]
    str x22, [sp, 32]
    str x23, [sp, 24]
    str x24, [sp, 16]
    str x25, [sp, 8]
    str lr, [sp]

	// set the interleaved background color
    ldr x5, =LIGHT_GRAY
    add x9, x1, x2
    and x9, x9, 1
    cmp x9, 1
    b.ne light_gray
    ldr x5, =DARK_GRAY
light_gray:

    mov x10, PIXELS_PER_CELL
    mul x1, x1, x10
    mul x2, x2, x10

    add x21, x1, SHADOW_PIXELS
    add x21, x21, SPACES_WIDTH
    add x22, x2, SHADOW_PIXELS
    add x22, x22, SPACES_WIDTH
    mov x23, x21
    mov x24, x22
    mov x25, x3

    add x3, x1, PIXELS_PER_CELL
    add x4, x2, PIXELS_PER_CELL
    bl square

    ldr x5, =BLACK

    // if x25==9, bomb
    cmp x25, 9
    b.ne five_to_eight
    mov x1, x21
    mov x2, x22
    add x3, x1, NUMBERS_HEIGHT
    add x4, x2, NUMBERS_HEIGHT
    bl square
    b _draw_open_cell


five_to_eight:
    cmp x25, 4
    b.le _one_to_four
    sub x25, x25, 1
    mov x1, x21
    mov x2, x22
    add x3, x1, NUMBERS_HEIGHT
    add x4, x2, NUMBERS_WIDTH
    bl square
    add x22, x22, NUMBERS_WIDTH
    add x22, x22, SPACES_WIDTH
    b five_to_eight

_one_to_four:
    mov x21, x23
    mov x22, x24
one_to_four:
    cbz x25, _draw_open_cell
    sub x25, x25, 1
    mov x1, x21
    mov x2, x22
    add x3, x1, NUMBERS_WIDTH
    add x4, x2, NUMBERS_HEIGHT
    bl square
    add x21, x21, NUMBERS_WIDTH
    add x21, x21, SPACES_WIDTH
    b one_to_four

_draw_open_cell:
    ldr lr, [sp]
    ldr x25, [sp, 8]
    ldr x24, [sp, 16]
    ldr x23, [sp, 24]
    ldr x22, [sp, 32]
    ldr x21, [sp, 40]
    add sp, sp, 48
    ret

.globl draw_flag
draw_flag:
    // args: x1: x, x2: y
    sub sp, sp, 16
    str x22, [sp, 8]
    str lr, [sp]

    ldr x5, =RED
    mov x22, PIXELS_PER_CELL
    mul x1, x1, x22
    mul x2, x2, x22

    add x3, x1, PIXELS_PER_CELL
    add x4, x2, PIXELS_PER_CELL
    bl square

    ldr lr, [sp]
    ldr x22, [sp, 8]
    add sp, sp, 16
    ret

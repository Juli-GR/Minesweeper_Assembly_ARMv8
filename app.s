.equ CELLS_X,         16
.equ CELLS_Y,         12

.equ GPIO_BASE,       0x3f200000
.equ GPIO_GPFSEL0,    0x00
.equ GPIO_GPLEV0,     0x34

/*
x0: framebuffer
x1: ret vals from functions
x2: argument for functions
x19: bombs matrix
x20: cells matrix
(x21, x22): current cell (x,y)
x23: gpio base
x24: current pressed keys
*/

.globl main
main:

    // calculate arrays size
    mov x9, CELLS_X
    mov x10, CELLS_Y
    mul x20, x9, x10
    lsl x20, x20, 2

    // create arrays
    sub sp, sp, x20
    mov x19, sp
    sub sp, sp, x20
    mov x20, sp

    // create the matrices
    mov x2, x19
    bl create_bombs_matrix
    mov x2, x20
    bl create_cells_matrix

    mov x21, 0
    mov x22, 0

    bl draw_board
    mov x1, x21
    mov x2, x22
    bl draw_marked_cell

    mov x23, GPIO_BASE
    str wzr, [x23, GPIO_GPFSEL0]    // que hace esto, lo inicializa ???


/*
wait for keys to be released
check for pressed keys in a loop:
    a move-key is pressed:
        execute the correct operation
        these calls will jump back to userInputLoop
    the space is pressed:
        call a function to open the cell
        check if the game ended
        if not, jump back to userInputLoop
*/
.globl userInputLoop
userInputLoop:

    // waits for all keys to be released
    ldr w10, [x23, GPIO_GPLEV0]
    cbnz w10, userInputLoop

_userInputLoop:

    // current pressed keys
    ldr w24, [x23, GPIO_GPLEV0]

    // A
    and w10, w24, 0b00000100
    cbnz w10, move_left

    // S
    and w10, w24, 0b00001000
    cbnz w10, move_down

    // D
    and w10, w24, 0b00010000
    cbnz w10, move_right

    // W
    and w10, w24, 0b00000010
    cbnz w10, move_up

    // space
    and w10, w24, 0b00100000
    cbz w10, _userInputLoop
    bl openCell
    cmp x1, 1
    b.eq Win
    b.gt Loss

    b _userInputLoop

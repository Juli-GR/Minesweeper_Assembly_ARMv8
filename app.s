#include "constants.inc"

/*
x0: framebuffer
x1: ret vals from functions
x2: argument for functions
x19: bombs matrix
x20: boxes matrix
x21: gpio base
x22: current pressed keys
*/

.globl main
main:

    // should i save x19..x28 and lr ???

    // calculate array size
    mov x9, SIZE_X
    mov x10, SIZE_Y
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
    bl create_boxes_matrix

    bl draw_board

    mov x21, GPIO_BASE
    str wzr, [x21, GPIO_GPFSEL0]    // que hace esto, lo inicializa ???


/*
wait for keys to be released
check for pressed keys in a loop:
    a move-key is pressed:
        execute the correct operation
        these calls will jump back to userInputLoop
    the space is pressed:
        call a function to open the box
        check if the game ended
        if not, jump back to userInputLoop
*/
.globl userInputLoop
userInputLoop:

    // waits for all keys to be released
    ldr w10, [x21, GPIO_GPLEV0]
    cbnz w10, userInputLoop

_userInputLoop:

    // current pressed keys
    ldr w22, [x21, GPIO_GPLEV0]

    // A
    and w10, w22, 0b00000100
    cbnz w10, move_left

    // S
    and w10, w22, 0b00001000
    cbnz w10, move_down

    // D
    and w10, w22, 0b00010000
    cbnz w10, move_right

    // W
    and w10, w22, 0b00000010
    cbnz w10, move_up

    // space
    and w10, w22, 0b00100000
    cbz w10, _userInputLoop
    bl openBox
    cmp x1, 1
    b.eq Win
    cmp x1, 2
    b.eq Loss

    b userInputLoop


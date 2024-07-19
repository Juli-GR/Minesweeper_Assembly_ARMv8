    .equ SCREEN_WIDTH,    640
    .equ SCREEN_HEIGH,    480
    .equ BITS_PER_PIXEL,  32

.globl square
square:
    sub sp, sp, 40
    str x20, [sp, 32]
    str x21, [sp, 24]
    str x22, [sp, 16]
    str x23, [sp, 8]
    str lr, [sp]

    // x5 color
    // start pos: (x1,x2), end pos: (x3,x4)

    // x20: direction of frame buffer + offset
    mov x20, 640
    mul x20, x2, x20
    add x20, x20, x1
    lsl x20, x20, 2             // colors occupy 4 bytes
    add x20, x20, x0

    mov x21, x4                 // x21: y counter
loop1:
    mov x22, x3                 // x22: x counter
loop0:
    stur w5, [x20]              // paint the pixel

	add x20,x20,4               // next pixel
	sub x22,x22,1               // x22--
    cmp x22, x1
    b.gt loop0                  // if this is not the last col, jump back
    mov x22, SCREEN_WIDTH       // use x22 as auxiliar before resetting the counter
    add x22, x22, x1
    sub x22, x22, x3
    lsl x22, x22, 2
    add x20, x20, x22           // set x20 to the next pixel
	sub x21,x21,1               // x21--
    cmp x21, x2
    b.gt loop1                  // if this is not the last row, jump back

    ldr lr, [sp]
    ldr x23, [sp, 8]
    ldr x22, [sp, 16]
    ldr x21, [sp, 24]
    ldr x20, [sp, 32]
    add sp, sp, 40

    ret

    .equ CELLS_X,         16
    .equ CELLS_Y,         12

/*
Add the first cell to a queue (pre: its a 0-cell)
Take an element of the queue
    open all its neighbors
    add all its 0-neighbors to the queue
(Actually, there are two queues, one for each coordinate)
*/
.globl cascade
cascade:
    // (x1, x2): (x,y)
    // x3: bombs matrix
    // x4: cells matrix

    sub sp, sp, 72
    str x19, [sp, 64]
    str x20, [sp, 56]
    str x21, [sp, 48]
    str x22, [sp, 40]
    str x23, [sp, 32]
    str x24, [sp, 24]
    str x26, [sp, 16]
    str x27, [sp, 8]
    str lr, [sp]

    // x23, x24: queues for x and y
    // x20, x21: left and right indices (multiplied by 4)
    //           inv: indices never reach the end
    // x26: bombs matrix
    // x27: cells matrix

    // set the registers

    mov x26, x3
    mov x27, x4

    mov x10, CELLS_X
    mov x11, CELLS_Y
    mul x10, x10, x11
    lsl x10, x10, 2             // CELLS_X*CELLS_Y*4
    sub sp, sp, x10
    mov x23, sp                 // x23: x queue
    sub sp, sp, x10
    mov x24, sp                 // x24: y queue
    mov x20, 0                  // x20: left index (*4)
    mov x21, 4                  // x21: right index (*4)

    // add first cell to the queue, since it is a 0-cell
    stur w1, [x23]              // x
    stur w2, [x24]              // y

_cascade:

    // (x19, x22): (x,y)

    // take the top elem and dequeue
    add x10, x23, x20           // x queue + left index
    add x11, x24, x20           // y queue + left index
    ldur w19, [x10]
    ldur w22, [x11]
    add x20, x20, 4             // increase left index

    // check its 8 neighbors

    sub x5, x19, 1
    sub x6, x22, 1
    bl checkNeighbor
    mov x5, x19
    sub x6, x22, 1
    bl checkNeighbor
    add x5, x19, 1
    sub x6, x22, 1
    bl checkNeighbor
    sub x5, x19, 1
    mov x6, x22
    bl checkNeighbor
    add x5, x19, 1
    mov x6, x22
    bl checkNeighbor
    sub x5, x19, 1
    add x6, x22, 1
    bl checkNeighbor
    mov x5, x19
    add x6, x22, 1
    bl checkNeighbor
    add x5, x19, 1
    add x6, x22, 1
    bl checkNeighbor

    cmp x20, x21
    b.ne _cascade

    ldr lr, [sp]
    ldr x27, [sp, 8]
    ldr x26, [sp, 16]
    ldr x24, [sp, 24]
    ldr x23, [sp, 32]
    ldr x22, [sp, 40]
    ldr x21, [sp, 48]
    ldr x20, [sp, 56]
    ldr x19, [sp, 64]
    add sp, sp, 72
    ret

/*
if the cell is closed:
    open it
    if it is a 0-cell, add it to the queue
*/
checkNeighbor:
    // (x5, x6): (x,y)

	sub sp, sp, 32
    str x19, [sp, 24]
    str x20, [sp, 16]
    str x22, [sp, 8]
    str lr, [sp]

    // check that 0<=x5<CELLS_X && 0<=x6<CELLS_Y
    cmp x5, 0
    b.lt _checkNeighbor
    cmp x5, CELLS_X
    b.ge _checkNeighbor
    cmp x6, 0
    b.lt _checkNeighbor
    cmp x6, CELLS_Y
    b.ge _checkNeighbor

    // (x19, x20): (x,y)
    // x22: ( y*CELLS_X + x ) * 4

    mov x19, x5
    mov x20, x6
    mov x22, CELLS_X
    mul x22, x22, x20
    add x22, x22, x19
    lsl x22, x22, 2
    add x10, x26, x22           // x10: index in the bombs matrix
    add x11, x27, x22           // x11: index in the cells matrix
    ldur w9, [x11]
    cbnz x9, _checkNeighbor     // if open, return
    mov x9, 1
    stur w9, [x11]              // open the cell
    add x25, x25, 1             // increase open cells counter
    ldur w3, [x10]
    mov x1, x19
    mov x2, x20
    bl draw_open_cell           // draw the open cell
    add x10, x26, x22           // recalculate the index in the bombs matrix
    ldur w9, [x10]
    cbnz x9, _checkNeighbor     // if it has bombs around, return
                                // else (its a 0-cell): add it to the queue
    add x9, x23, x21
    stur w19, [x9]
    add x9, x24, x21
    stur w20, [x9]
    add x21, x21, 4             // increase right index
_checkNeighbor:
    ldr lr, [sp]
    ldr x22, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 32
    ret

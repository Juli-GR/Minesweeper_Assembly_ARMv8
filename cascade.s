    .equ CELLS_X,         16
    .equ CELLS_Y,         12

.globl cascade
cascade:
    // x1: x, x2: y
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

    mov x26, x3
    mov x27, x4

    mov x10, CELLS_X
    mov x11, CELLS_Y
    mul x19, x10, x11
    lsl x19, x19, 2     // x19: CELLS_X*CELLS_Y*4
    sub sp, sp, x19
    mov x23, sp         // x23: queue for x
    sub sp, sp, x19
    mov x24, sp         // x24: queue for y
    mov x20, 0         // x20: left index (*4)
    mov x21, 4         // x21: right index (*4)
    // indices never reach the end

    // add first cell to open, since it is 0
    stur x1, [x23]      // x
    stur x2, [x24]      // y

_cascade:
    
    add x10, x23, x20   // next elem x
    add x11, x24, x20   // next elem y
    ldur w19, [x10]
    ldur w22, [x11]
    add x20, x20, 4

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

checkNeighbor:
    // x5: x, x6: y
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

    mov x19, x5
    mov x20, x6
    mov x22, CELLS_X
    mul x22, x22, x20
    add x22, x22, x19
    lsl x22, x22, 2
    add x14, x26, x22
    add x12, x27, x22
    ldur w9, [x12]
    cbnz x9, _checkNeighbor    // if open, return
    mov x9, 1
    stur w9, [x12]              // open the cell
    add x25, x25, 1             // increase open cells counter
    ldur w3, [x14]
    mov x1, x19
    mov x2, x20
    bl draw_open_cell
    add x14, x26, x22
    ldur w9, [x14]
    cbnz x9, _checkNeighbor    // if it has bombs around, return
    add x13, x23, x21
    stur w19, [x13]
    add x13, x24, x21
    stur w20, [x13]
    add x21, x21, 4             // x21 += 4
_checkNeighbor:
    ldr lr, [sp]
    ldr x22, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 32
    ret


// funciona hacer ldur w1, [x1] ???
//      cuando ande todo ver si funciona
// los registros en checkNeighbor son cualquier cosa

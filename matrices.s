#include "constants.inc"

/*
normal cells: 1 to 8, indicates number of bombs around them
bombs: 9
*/
.globl create_bombs_matrix
create_bombs_matrix:

	// x2: matrix
	
	// save x19, lr

	bl initialize
	
	mov x19, BOMBS
placeBomb:
	cbz x19, placeNums
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
if current_num==9: add one to every not-9-forward-neighbor
else: current_num++ for every 9-forward-neighbor
4 cases:
	1st column without last box
	last column without last box
	middle columns without last box
	last row without last box
notice that:
	the very last box is excluded
	the algorithm works with any order of the boxes
*/
placeNums:
	bl case1
	bl case2
	bl case3
	bl case4
	ret

// x1: current_num
_placeNums:
	//	   cn x3
	//	x4 x5 x6
	cbz x3, reg4
	mov x7, x3
	bl action
reg4:
	cbz x4, reg5
	mov x7, x4
	bl action
reg5:
	cbz x5, reg6
	mov x7, x5
	bl action
reg6:
	cbz x6, endPlaceNums
	mov x7, x6
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
	mov x4, 1
	mov x5, 1
	mov x6, 1
	// loop through appropriate sections and call _placeNums
	ret

case2:
	mov x3, 1
	mov x4, 0
	mov x5, 1
	mov x6, 1
	// loop through appropriate sections and call _placeNums
	ret
	
case3:
	mov x3, 0
	mov x4, 1
	mov x5, 1
	mov x6, 0
	// loop through appropriate sections and call _placeNums
	ret
	
case4:
	mov x3, 1
	mov x4, 0
	mov x5, 0
	mov x6, 0
	// loop through appropriate sections and call _placeNums
	ret



// init matrix with 0s (stored in x2)
initialize:
	ret

// generate random num between 0 and SIZE_X*SIZE_Y-1
// returns the value in x1
randomNumber:
	ret

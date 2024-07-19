.equ SCREEN_WIDTH,    640
.equ SCREEN_HEIGH,    480
.equ BITS_PER_PIXEL,  32

.equ GPIO_BASE,       0x3f200000
.equ GPIO_GPFSEL0,    0x00
.equ GPIO_GPLEV0,     0x34

.equ CELLS_X,         16
.equ CELLS_Y,         12
.equ BOMBS,           32    // 1/6 of the total cells, as usual

.equ PIXELS_PER_CELL, 40
.equ SHADOW_PIXELS,   4
.equ NUMBERS_WIDTH,   3
.equ NUMBERS_HEIGHT,  24
.equ SPACES_WIDTH,    4

.equ PINK,            0xff9fbf
.equ WHITE_PINK,      0xffc8da
.equ DARK_PINK,       0xe86c95
.equ RED,             0xe41818
.equ GRAY,            0xe4e4e4
.equ WHITE,           0xffffff
.equ BLACK,           0x000000

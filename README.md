# Minesweeper in Assembly ARMv8 with QEMU

This minesweeper was programmed using the base provided by
the Computer Organization course at FAMAF in 2023
(start.s, gpiom and Makefile files)  

![minesweeper](https://github.com/user-attachments/assets/82d52b2a-19e7-4389-a3f7-aa5362039be3)  

## How to install qemu
```
sudo apt update
# set up AARCH64 toolchain
sudo apt install gcc-aarch64-linux-gnu
# set up QEMU ARM
sudo apt install qemu-system-arm
```
## How to play
To play the game, go to the Makefile folder and run the following
lines in different terminals
```
make runQEMU
make runGPIOM
```
In the second terminal, by typing "w", "a", "s" and "d" you can move the selected cell and then open it with the space key.  
At the moment, there is no way to place flags, but you can win by opening all the non-bomb cells.  
When you win or lose the screen turns white or black respectively.  
To change the position of the bombs you can change the SEED constant in the matrices.s file to any number.

## Notes
- The constants.s file is a list of all the constants of the project, but it is not used. (I didn't find a way to avoid putting the constants in each file)

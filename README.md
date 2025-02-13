# Minesweeper in Assembly ARMv8 with QEMU

This minesweeper was programmed using the base provided by
the Computer Organization course at FAMAF in 2023
(start.s, gpiom and Makefile files) but as a personal project separate from the course.  

![minesweeper-demo](media/minesweeper-demo.gif?raw=true)

## How to install QEMU
```bash
sudo apt update
# set up AARCH64 toolchain
sudo apt install gcc-aarch64-linux-gnu
# set up QEMU ARM
sudo apt install qemu-system-arm
```
## How to play
To play the game, go to the Makefile folder and run the following
lines in different terminals
```bash
make runQEMU
make runGPIOM
```
In the second terminal, by typing "w", "a", "s" and "d" you can move the selected cell and then open it with the space key. To place flags use "f".  
You can win by opening all the non-bomb cells.  
When you win or lose the screen turns white or black respectively.  
To change the position of the bombs you can change the SEED constant in the matrices.s file to any number.

## Note
The constants.s file is a list of all the constants of the project, but it is not used. (I haven't find a way to avoid putting the constants in each file)

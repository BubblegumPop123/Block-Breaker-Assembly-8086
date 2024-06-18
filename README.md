# Block-Breaker-Assembly-8086
### Project Description and Guide

This project implements a Brick Breaker game in assembly language. It includes various procedures for handling game mechanics, user input, and graphics rendering. Below is a detailed description of the project file, along with instructions on how to assemble and run the code.

### File Description

1. **i200795_i210583.asm**
   - This assembly file contains the complete implementation of the Brick Breaker game. It includes segments for data, code, and procedures for different aspects of the game, such as drawing the paddle, ball, bricks, handling user input, detecting collisions, and managing game states like pause and game over.

### Compilation and Execution Guide

#### Prerequisites

- An assembler like TASM (Turbo Assembler) or MASM (Microsoft Macro Assembler).
- A DOSBox or similar DOS emulator to run the compiled executable.

#### Steps to Assemble and Run

1. **Assembling the Code**

   To assemble the `.asm` file, use the following commands:

   For TASM:
   ```sh
   tasm i200795_i210583.asm
   tlink i200795_i210583.obj
   ```

   For MASM:
   ```sh
   masm i200795_i210583.asm;
   link i200795_i210583.obj;
   ```

2. **Running the Program**

   After successfully assembling and linking the code, run the executable using a DOSBox or similar DOS emulator:

   ```sh
   dosbox
   mount c: /path/to/your/executable
   c:
   i200795_i210583.exe
   ```

3. **Gameplay Instructions**

   - The game starts by prompting the user to enter their name.
   - The main menu offers options to play the game, view instructions, or exit.
   - Use the arrow keys to move the paddle left and right.
   - The objective is to hit the ball with the paddle to break all the bricks and progress through the levels.
   - The game ends when all lives are lost or all levels are completed.

### Example Gameplay Output

```
WELCOME TO BRICK BREAKER
PLEASE ENTER YOUR NAME: [User enters name]

Menu:
1. Play Game
2. Instructions
3. Exit

[User selects an option]

INSTRUCTIONS:
- Use the arrow keys to move the paddle.
- Hit the blocks using the paddle.
- Destroy all bricks to enter the next level.

Game starts...

[Game displays paddle, ball, and bricks]
[User plays the game]

Game Over!
THANK YOU FOR PLAYING
PRESS ENTER TO EXIT
```

This guide should help understand, assemble, run, and play the Brick Breaker game effectively. For any issues or further details, please refer to the comments and documentation within the assembly code.

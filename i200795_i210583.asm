;;; i200795 and i210583 coal project;;;;;;;;;;;;



;;;;;;;;;;;;;;BLOCK BREAKERRRRRRRRR;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100h


.data   ;;;;;;;;;;;;;;data segment;;;;;;;;;;;;;;;
	str1 db "WELCOME TO BRICK BREAKER $"
	str2 db "PLEASE ENTER YOUR NAME $"
	username1 db 50 dup ("$")
    scorer db 3 dup (" ")
	str3 db "Welcome $"
	str4 db "   PLEASE PRESS ENTER TO CONTINUE $"
	string1 db "     Brick breaker$"
	string1mid db "Player Name: $"
	string2 db " 1      Play Game$"
	string3 db " 2     Instructions$"
	string4 db " 3         Exit$"
	str5 db "INSTRUCTIONS: $"
	str6 db "Hit the blocks using the paddle $"
	str61 db " $"
	str7 db "Destroy all bricks to enter next level$"
	str71 db "$"
	str8 db "Use arrow keys to move paddle $"


	str12 db "THANK YOU FOR PLAYING $"
	str13 db " PRESS ENTER TO EXIT $"
	str14 db "     PRESS R TO RESTART THE GAME $"
	string5 db "     Game Paused$"
	string6 db "Press Enter to Continue$"
	file1 db 'gamedata.txt',0
	temp dw ?
	buffer db 5000 dup ("$")
    startline db 13,0
    newline db 10,0
    


    choice1 db 0
    choice2 db 0
    choice3 db 0






    score db 'Score: $'                 ;the string score
    scoreCount dw 0                     ;to count the score of levels
    lives db '              Lives: $'
    lives_Count dw 3                    ;to count the lives , 0 is game over condition

    inner dw 0
    exter dw 3

    startx dw ?                         ;starting x index for the draw proc
    starty dw ?                         ;starting y index for the draw proc
    endx dw ?                           ;ending x index for the draw proc
    endy dw ?                           ;ending y index for the draw proc
    color db ?                          ; color for the draw proc


;;;;;;;;;;;;;;;;;bricks x and y coordinates of 12 bricks;;;;;;;;;;;;;;;;;
brick_height dw 10
brick_width dw 40

brick1x dw 15
brick1y dw 25
brick_collision_1 db 1

brick2x dw 65
brick2y dw 25
brick_collision_2 db 1


brick3x dw 115
brick3y dw 25
brick_collision_3 db 1

brick4x dw 165
brick4y dw 25
brick_collision_4 db 1

brick5x dw 215
brick5y dw 25
brick_collision_5 db 1

brick6x dw 265
brick6y dw 25
brick_collision_6 db 1


brick7x dw 15
brick7y dw 45
brick_collision_7 db 1

brick8x dw 65
brick8y dw 45
brick_collision_8 db 1

brick9x dw 115
brick9y dw 45
brick_collision_9 db 1

brick10x dw 165
brick10y dw 45
brick_collision_10 db 1

brick11x dw 215
brick11y dw 45
brick_collision_11 db 1

brick12x dw 265
brick12y dw 45
brick_collision_12 db 1



        window_bounds dw 6              ;the detect collisions earlier
        window_width    dw  140h        ;width of the screen, x axis 320 pixels    
        window_height   dw  0c8h        ;height of the screen, y axis 200 pixels

        Time_aux db 0                   ;variable to store the previous system time, for fps

        paddle_x dw 80                  ; the initial position of paddle along x axis
        paddle_y dw 190                  ; the intiial position of paddle along y axis
        paddle_width dw 35              ;width of paddle
        paddle_height dw 04             ;height of paddle
        paddle_speed dw 07h             ;speed of paddle

        ball_original_x dw 130          ;110 pixels horizontal
        ball_original_y dw 80          ;100 pixels vertical
        ball_x dw 100                   ;x position, column of ball
        ball_y dw 80                   ;y position, row of ball or line of ball
        ball_size dw 04h                ;size of the ball, the number of pixels of ball in width and height
        ball_speed_x dw 03h             ;ball speed along x axis, horizontal
        ball_speed_y dw 04h             ;ball speed along y axis, vertical


.code   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;code segment;;;;;;;;;;;;;;;;;;;;;;;;;;

redrawStriker macro newcolor                ;viscolor has the color of the paddle
    mov color, newcolor                        ;moving paddle color to the color variable
    call draw_paddle                            ;calling the draw the striker function
endm

redrawBall macro newcolor                   ;having the color of ball as argument
    mov color, newcolor                     ;moving viscolor in color variable
    call draw_ball                           ;calling drawball function
endm


BuildBrick macro  A, B , C                 ;a macro to make a brick A having x axis and B having y axis
local nothing
local color1
local color2
local color3

cmp C,0                     ;compares bricks colllision, if it goes to 0, doesnt draw

JE nothing

cmp C,1
JE color1

cmp C,2
JE color2

cmp C,3
je color3

color1:
    mov color,8
    push ax
    push bx

    mov ax, A
    mov bx, B
    call AddBrick

    pop bx
    pop ax
    jmp nothing
color2:
    mov color,7
    push ax
    push bx

    mov ax, A
    mov bx, B
    call AddBrick

    pop bx
    pop ax
    jmp nothing

color3:
    mov color,6
    push ax
    push bx

    mov ax, A
    mov bx, B
    call AddBrick

    pop bx
    pop ax
    jmp nothing


nothing:

endm

DestroyBrick macro  A, B , C                ; A has the x position of brick and B has the y position of brick
local noth
    dec C
    cmp C,0
    JNE noth

    mov ax, A               ;moving the x position in ax
    mov bx, B               ;moving the y position in bx
    call RemoveBrick        
    ;call beep     
    inc scoreCount
    ;call DrawLivesScores
noth:
endm

BrickCollision MACRO X, Y , Z                   ;x has the x axis of a brick and y has the y axis of the brick

local repeater
cmp Z,0
JE repeater

    mov ax, ball_x                       ;ax has the ball x coord
    mov bx, ball_x                       ;bx has the ball y coord
    mov cx, X                           ;cx has the x of the brick
    mov dx, Y                           ;dx has the y of the brick
    
    cmp dx, ball_y                       
    jl repeater                 ;no collision
    sub dx, brick_height                   ;brick height
    
    cmp ball_y, dx              
    jl repeater                 
    
    
    mov dx, X 
    
    cmp ball_x, dx
    jl repeater
    add dx, brick_width                  ;brick length
    cmp dx, ball_x
    jl repeater
    
    call beep     
    neg ball_speed_y                          ;inverse direction
    DestroyBrick X, Y, Z                      ;resetting the y and x so that they change position

    cmp scoreCount, 12                          ;condition for 12 bricks, go to next level if all are broken
    jne repeater


    repeater:                     
    
endm





     main proc               
	mov sp,bp
        mov ax,@data
        mov ds,ax
        mov ax,0

    call userenter
    call menu


    outofmenu:    

    CALL LEVEL_1
    call reset_ball_position
    call LEVEL_2
    call reset_ball_position
    call level_3
    
    RET

    main endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc to check the collisions of bricks;;;;;;;;;;;;;;;;;;;;;;;;;;

check_brick_collision proc

    BrickCollision Brick1x, Brick1y, brick_collision_1
    BrickCollision Brick2x, Brick2y, brick_collision_2
    BrickCollision Brick3x, Brick3y, brick_collision_3
    BrickCollision Brick4x, Brick4y, brick_collision_4
    BrickCollision Brick5x, Brick5y, brick_collision_5
    BrickCollision Brick6x, Brick6y , brick_collision_6
    BrickCollision Brick7x, Brick7y , brick_collision_7
    BrickCollision Brick8x, Brick8y , brick_collision_8
    BrickCollision Brick9x, Brick9y , brick_collision_9
    BrickCollision Brick10x, Brick10y , brick_collision_10
    BrickCollision Brick11x, Brick11y , brick_collision_11
    BrickCollision Brick12x, Brick12y , brick_collision_12

ret
check_brick_collision endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that enters the user's name;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
userenter proc

mov ah,0
mov al,00
int 10h

mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h


mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str1
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str2
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h


mov si,offset username1
loop1:
mov ah,01
int 21h
mov [si],al
inc si
cmp al,13
JNE loop1


mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str3
int 21h



mov ah,09
mov dx,offset username1
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h


mov ah,09
mov dx,offset str4
int 21h


mov ah,0bh
mov bh,00
mov bl,08
int 10h





L1:
mov ah,01
int 21h
CMP al,13
JNE L1
ret
userenter endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that displays the menu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu proc

mov ah,0
mov al,00
int 10h

display1:
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset string1
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h


mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset string1mid
int 21h

mov ah,09
mov dx,offset username1
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset string2
int 21h


mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h


mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset string3
int 21h


mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset string4
int 21h
JMP inputter2

instructcaller:
call instruct
JMP inputter2

exitter1:
mov ah,4ch
int 21h


inputter2:
mov ah,01h
int 21h
mov choice1,al

sub choice1,48


mov bl,2
cmp choice1,bl
jz instructcaller

mov bl,3
cmp choice1,bl
jz exitter1


mov bl,1
cmp choice1,bl
jz exitingmenu

call menu

exitingmenu:
ret
menu endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that displays the instructions if required;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instruct proc


display2:
mov ah,0
mov al,00
int 10h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str5
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,09
mov dx,offset str6
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,09
mov dx,offset str61
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,09
mov dx,offset str7
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,09
mov dx,offset str71
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,09
mov dx,offset str8
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,09
mov dx,offset str4
int 21h


L5:
mov ah,01
int 21h
CMP al,13
JNE L5
call menu

ret
instruct endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that pauses the game;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pauser proc
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h


mov ah,09
mov dx,offset string5
int 21h

mov ah,02
mov dx,0
mov dl,10
int 21h

mov ah,09
mov dx,offset string6


L4:
mov ah,01
int 21h
CMP al,13
JNE L4

ret
pauser endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that displays the game over screen;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


endering proc

mov ah,0
mov al,00
int 10h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str12
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
mov dx,0
mov dl,09
int 21h
mov ah,09
mov dx,offset str13
int 21h
mov ah,02
mov dx,0
mov dl,10
int 21h
JMP L6


exitter2:
mov ah,4ch
int 21h

L6:
mov ah,01
int 21h
CMP al,13
JE exitter2
JMP L6

ret
endering endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc that reads files;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

filer proc
mov ax,0
mov bx,0
mov cx,0
mov dx,0
mov si,0
mov di,0

mov dx,offset file1
mov al,2
mov ah,3dh
int 21h

mov bx,ax
mov cx,0
mov ah,42h
mov al,02h
int 21h


mov cx,lengthof startline
dec cx
mov dx,offset startline
mov ah,40h
int 21h


mov cx,2
mov dx,offset scorer
mov ah,40h
int 21h

mov cx,7
mov dx,offset username1
mov ah,40h
int 21h

mov cx,lengthof newline
dec cx
mov dx,offset newline
mov ah,40h
int 21h


mov ah,3eh
int 21h

ret
filer endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc to move the ball on screen. having all its conditions;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    move_ball proc
        redrawBall 0
        mov ax,ball_speed_x         ;increment the ball with ball speed
        add ball_x,ax               ;movement of x axis, horizontal
        

        mov ax,window_bounds        ;left edge of window   
        cmp ball_x,ax               ;ball_x < window boundary  then left collision
        JL NEG_VEL_X                ;label to negate x velocity           
        
        mov ax,window_width 
        sub ax,ball_size            ;so ball doesnt exit the window
        sub ax,window_bounds        ;earlier collision
        cmp ball_x, ax              ;ball_x > window width, then right collision            
        JG NEG_VEL_X                ; a label to negate the velocity val

       
        mov ax,ball_speed_y
        add ball_y,ax               ;movement of y axis, vertical
        redrawBall 3
  

        mov ax,window_bounds        ;check collisio earlier
                           ;to avoid hitting the score and lives
        cmp ball_y,ax               ;ball_y < windowbounds, collision with top boundary
        JL NEG_vel_Y                ;negate speed for opposite movement in y axis

      

        mov ax,window_height         ;ball_y > windowheight collision with bottom boundary
        sub ax,ball_size             ;so ball wont go inside screen
        sub ax,window_bounds         ;earlier collision detection
        cmp ball_y,ax
        JG reset_position               ;opposite vertical movement

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;conditions for collision with paddle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




    ;ball_x + ball_size  > paddle_x  and ball_x < paddle_x + paddle_width and ball_y + ball_size > paddle_y and ball_y < paddle_y + paddle_height                            
    mov ax,ball_x
    add ax,ball_size
    cmp ax,paddle_x         ;comparing x coordinate of ball with x of paddle
    JNG no_collision        ;if no collision then do nothing

    mov ax,paddle_x         
    add ax,paddle_width
    cmp ball_x,ax           ;comparing x coodinate of paddle with x of ball
    JNL no_collision

    mov ax,ball_y
    add ax,ball_size
    cmp ax,paddle_y         ;comparing y axis
    JNG no_collision

    mov ax,paddle_y
    add ax,paddle_height
    cmp ball_y,ax           ;comparing y axis
    JNL no_collision
    



;if it reaches this point, it is colliding with paddle   
    call beep
    Neg ball_speed_y              ;reverse ball vertical velocity
    
    no_collision:                   ;in case no collisions occur, just return

    ret

    NEG_VEL_X:
        NEG ball_speed_x            ;negative command changes sign
        ret

    NEG_vel_Y:
        NEG ball_speed_y            ;negating speed along y axis
        ret

    reset_position:
        

        dec lives_Count
        call draw_lives
        .if(lives_count==0)                 ;game over screen if lives= 0






        call filer               ;calling file handling for score storage
        call endering              ;calling the ending screen

        mov ah,4ch
        int 21h                      ;ending code

        .endif
         redrawBall 0
        call reset_ball_position        ;proc that resets ball position back to middle of screen

        ret

    move_ball endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;proc to move the paddle/ key detection;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    move_paddle proc
        redrawStriker 0
        ;checking if key is pressed
        mov ah,01h
        int 16h
        JZ check_movement       ;if key is pressed, we will move the paddle

        ;check which key is pressed, left right
        mov ah,00h                
        int 16h

        ;if left key go left
        cmp ah,4bh					;left key
	    JE move_left

        ;if right key, go right
        cmp ah,4dh					;right key
	    JE move_right

        ;if pause pressed, calling pause
        cmp ah,70h                  ;pause key
        JE pausering


        pausering:                 ;to call pause function
        call pauser

        move_left:                  ;functionality for left movement
            
            mov ax,paddle_speed     ;moving paddle speed to ax
            sub paddle_x,ax         ;left movement decrements the x of paddle

            mov ax,window_bounds
            cmp paddle_x,ax         ;left edge of screen is window bounds
            JLE fix_position

            jmp check_movement

            fix_position:
            mov ax,window_bounds        ;refresh ax with window bounds 
            mov paddle_x,ax             ;stopping the paddle at its position
            jmp check_movement


        move_right:                 ;functionality for right movement

            mov ax,paddle_speed     ;paddle speed in ax
            add paddle_x,ax         ;adding in case of right movement

            mov ax,window_width     ;moving width of window in ax
            sub ax,window_bounds    ;subtracting bounds
            sub ax,paddle_width     ;subtracting paddle width

            cmp paddle_x,ax        ;comparing the x of paddle with window width
            JGE fix_position1

            jmp check_movement

            fix_position1:
                ;mov ax,window_width
                mov paddle_x,ax
                jmp check_movement

        check_movement:
        redrawStriker 5

    ret
    move_paddle endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a procedure that resets the balls position when collided with bottom screen;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    reset_ball_position proc

            mov ax,ball_original_x          
            mov ball_x,ax               ;ball x becomes back original
            mov ax,ball_original_y
            mov ball_y,ax               ;ball y becomes back original

    ret
    reset_ball_position endp



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;A proc to make a ball on the screen, cx has column and dx has row;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    draw_ball proc        
        mov cx,ball_x               ;initial position the column
        mov dx,ball_y               ;initial position of the row

        drawball:

            mov ah,0ch              ;setting config to write a pixel
            mov al,color              ;writing in white color
            mov bh,00h              ;setting the page number
            int 10h                 ;implement  

            inc cx                  ;adding to the clumn

            mov ax,cx
            sub ax,ball_x
            cmp ax,ball_size

        JNG drawball
        mov cx,ball_x                   ;setting cx back to initial
        inc dx                          ;moving 1 row down

        mov ax,dx                       ;condition for horizontal 
        sub ax,ball_y                
        cmp ax,ball_size

       jNG drawball

    ret
    draw_ball endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a function to make the paddle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    draw_paddle proc

        mov cx, paddle_x        ;initital position along x axis
        mov dx, paddle_y        ;initial position along y axis

        draw1:
            mov ah,0ch              ;setting config to write a pixel
            mov al,color              ;writing in white color
            mov bh,00h              ;setting the page number
            int 10h                 ;implement 

             inc cx                  ;adding to the clumn

            mov ax,cx
            sub ax,paddle_x
            cmp ax,paddle_width

        JNG draw1

        mov cx,paddle_x                   ;setting cx back to initial
        inc dx                          ;moving 1 row down

        mov ax,dx                       ;condition for horizontal 
        sub ax,paddle_y               
        cmp ax,paddle_height

       jNG draw1
        

    ret
    draw_paddle endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a function that clears/ refreshes the screen;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    clear_screen proc

        mov ah,00h              ;entering video mode
        mov al,13h
        int 10h

        mov ah,0bh
        mov bh,00h
        mov bl,00h              ;choosing black has background color
        int 10h

    ret
    clear_screen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a procedure that produces a beep sound;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beep proc               

        mov     al, 182         ; Prepare the speaker for the
        out     43h, al         ;  note.
        mov     ax, 400        ; Frequency number (in decimal)
                                ;  for middle C.
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 00000011b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 2          ; Pause for duration of note.
pause1:
        mov     cx, 65535
pause2:
        dec     cx
        jne     pause2
        dec     bx
        jne     pause1
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al, 11111100b   ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.


ret
beep endp


drawBoundary proc                   ;procedure to draw the boundary
    mov color,6    
    ;TOP
    mov startx,0            ;starting from 0 on axis
    mov endx,320            ; to 320 on x axis
    mov starty,1            ;starting from 1 on y axis
    mov endy,4              ;ending on 4 on y axis
    call draw               ;calling draw function to draw 1 side
    ;RIGHT
    mov startx,316
    mov endx,319
    mov starty,1
    mov endy,200
    call draw
    ;LEFT
    mov startx,1
    mov endx,4
    mov starty,0
    mov endy,200
    call draw
   
    ret
    drawBoundary endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a function to draw everything;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw proc                           ;draw function that has start x as starting horizontal, start y as starting vertical and endx and endy as ending

    mov dx,starty                   ;moving start y to horizontal position of pixel
    mov cx,startx
    mov ah,0ch
    mov al,color                    ;al has the color of pixel
    c1:
    inc cx                          ;increment the x position
    int 10h
    cmp cx,endx                     ;cmp with ending
    jne c1

    mov cx,startx
    inc dx                          ;increment the y position
    cmp dx,endy                     ;cmp with ending
    jne c1 
    
    ret
draw endp

AddBrick proc
    
    mov startx, ax
    ;mov color, 8  
    mov ax, bx
    mov bx, startx
    
    add bx, brick_width              ;30 wdith of brick
    
    mov endx,bx
    
    mov starty, ax 
    
    mov bx,starty
                    
    add bx,brick_height                ;7 height of brick
    mov endy,bx
     
    call draw               ;startx and start y and end x and end y having all the cooridnates of brick

    ret
    AddBrick endp

RemoveBrick proc                        ;function that destroys a brick with ax having x coord and bx having y coord
    
    mov startx, ax
    mov color, 0                        ;putting black in color
    mov ax, bx
    mov bx, startx
    
    add bx, brick_width
    
    mov endx,bx
    
    mov starty, ax 
    
    mov bx,starty
    
    add bx,brick_height
    mov endy,bx
     
    call draw                           ;drawing a black brick on the same coordinates after collison endx endy startx starty

    ret
RemoveBrick endp





DrawLivesScores proc uses ax bx cx dx                   ;score
 

    mov ah, 2                           ;cursor position
    mov dh, 1                            ;row
    mov dl, 2                           ;col

    int 10h
    
    mov ah, 09h
    mov dx, offset score                ;printing the score keyword on top

    int 21h
    
    call printScore                     ;calling the print score that shows the score on top of screen
    

    ret
    DrawLivesScores endp


printScore proc                                                     ;print score
    push ax
    push bx
    push cx
    push dx
    
    mov cx,0
    
    mov ax,scoreCount                   ;ax has the score
    ll:
    mov bx,10                           ;for taking mod of ax with 10
    mov dx,0
    div bx
    push dx
    inc cx
    cmp ax,0
    jne ll
    mov si,0
    l2:
    pop dx
    
    mov ah,2
    add dl,'0'                      ;printing it digit by digit
    mov [scorer+si],dl
    int 21h
    inc si
    loop l2
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    printScore endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;function to draw lives;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_lives proc
    mov ah, 2                           ;cursor position
    mov dh, 1                            ;row
    mov dl, 13                           ;col

    int 10h
    
    mov ah, 09h
    mov dx, offset lives                ;printing the score keyword on top

    int 21h
    call draw_hearts

    ret
draw_lives endp  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a function that draws hearts;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_hearts proc
    call draw_box
    mov ah, 2
    mov dh, 1     ;row
    mov dl, 34     ;column
    int 10h

    mov al,3    ;ASCII code of Character 
    mov bx,0
    mov bl,12           ;red color
    mov cx,lives_count       ;repetition count
    mov ah,09h
    int 10h

ret
draw_hearts endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;a proc to remove the extra heart, refreshing only lives area;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_box proc
    mov dx,5                   ;moving start y to horizontal position of pixel
    mov cx,270
    mov ah,0ch
    mov al,0                    ;al has the color of pixel
    c2:
    inc cx                          ;increment the x position
    int 10h
    cmp cx,300                     ;cmp with ending
    jne c2

    mov cx,270
    inc dx                          ;increment the y position
    cmp dx,20                     ;cmp with ending
    jne c2 
    
    ret

draw_box endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;procedure for level 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEVEL_1 PROC

    call clear_screen

        check_time1:                     ;label to iterate screen

            mov ah,2ch                  ;getting system time 
            int 21h                     ;ch=hour, cl= minute, dh= second, dl = 1/100 seconds
            cmp dl,time_aux             ;is prev time equal to current time?, time aux= prev time

        JE check_time1                  ; if its the same. check again
        mov time_aux,dl                 ;update time

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if its different then come to this part;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;call clear_screen               ;clearing screen every iteration

        BuildBrick brick1x,brick1y,brick_collision_1
        BuildBrick brick2x,brick2y,brick_collision_2
        BuildBrick brick3x,brick3y,brick_collision_3
        BuildBrick brick4x,brick4y,brick_collision_4
        BuildBrick brick5x,brick5y,brick_collision_5
        BuildBrick brick6x,brick6y,brick_collision_6
        BuildBrick brick7x ,brick7y,brick_collision_7
        BuildBrick brick8x ,brick8y,brick_collision_8
        BuildBrick brick9x ,brick9y,brick_collision_9
        BuildBrick brick10x ,brick10y,brick_collision_10
        BuildBrick brick11x ,brick11y,brick_collision_11
        BuildBrick brick12x ,brick12y,brick_collision_12
        
        call drawBoundary
       
        call move_ball                  ;proc that moves the ball
        call draw_ball                  ;drawing ball after every refresh
        call DrawLivesScores
        call draw_lives
        cmp scoreCount,12
		je goback
        
        call move_paddle                ;proc that maoves the paddle
        call draw_paddle                ;proc to draw the paddle

        call check_brick_collision

        jmp check_time1                  ;after everything checks time again

goback:
    RET 
LEVEL_1 ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;procedure for level 2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEVEL_2 PROC
    inc ball_speed_x
    mov ax,3
    inc paddle_speed

    sub paddle_width,ax

    mov lives_Count,3
    mov scoreCount,0
    
    mov paddle_x,80
    mov paddle_y,190

   
    mov brick_collision_1,2
    mov brick_collision_2,2
    mov brick_collision_3,2
    mov brick_collision_4,2
    mov brick_collision_5,2
    mov brick_collision_6,2
    mov brick_collision_7,2
    mov brick_collision_8,2
    mov brick_collision_9,2 
    mov brick_collision_10,2
    mov brick_collision_11,2
    mov brick_collision_12,2

    call clear_screen

        check_time:                     ;label to iterate screen

            mov ah,2ch                  ;getting system time 
            int 21h                     ;ch=hour, cl= minute, dh= second, dl = 1/100 seconds
            cmp dl,time_aux             ;is prev time equal to current time?, time aux= prev time

        JE check_time                   ; if its the same. check again
        mov time_aux,dl                 ;update time

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if its different then come to this part;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;call clear_screen               ;clearing screen every iteration

        BuildBrick brick1x,brick1y,brick_collision_1 
        BuildBrick brick2x,brick2y,brick_collision_2
        BuildBrick brick3x,brick3y,brick_collision_3  
        BuildBrick brick4x,brick4y,brick_collision_4  
        BuildBrick brick5x,brick5y,brick_collision_5  
        BuildBrick brick6x,brick6y,brick_collision_6  
        BuildBrick brick7x ,brick7y,brick_collision_7 
        BuildBrick brick8x ,brick8y,brick_collision_8 
        BuildBrick brick9x ,brick9y,brick_collision_9 
        BuildBrick brick10x ,brick10y,brick_collision_10  
        BuildBrick brick11x ,brick11y,brick_collision_11 
        BuildBrick brick12x ,brick12y,brick_collision_12 
        
        call drawBoundary
       
        call move_ball                  ;proc that moves the ball
        call draw_ball                  ;drawing ball after every refresh
        call DrawLivesScores
        call draw_lives
        cmp scoreCount,12
        je goingback
        
        call move_paddle                ;proc that maoves the paddle
        call draw_paddle                ;proc to draw the paddle

        call check_brick_collision

        jmp check_time                  ;after everything checks time again


    goingback:
    RET
LEVEL_2 ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;procedure for level 3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEVEL_3 PROC
    inc ball_speed_x
    mov ax,10
    inc ball_speed_y
    inc paddle_speed

    sub paddle_width,ax

    mov lives_Count,3
    mov scoreCount,0
    
    mov paddle_x,80
    mov paddle_y,190

   
    mov brick_collision_1,3
    mov brick_collision_2,3
    mov brick_collision_3,3
    mov brick_collision_4,3
    mov brick_collision_5,3
    mov brick_collision_6,3
    mov brick_collision_7,3
    mov brick_collision_8,3
    mov brick_collision_9,3 
    mov brick_collision_10,3
    mov brick_collision_11,3
    mov brick_collision_12,3

    call clear_screen

        check_time2:                     ;label to iterate screen

            mov ah,2ch                  ;getting system time 
            int 21h                     ;ch=hour, cl= minute, dh= second, dl = 1/100 seconds
            cmp dl,time_aux             ;is prev time equal to current time?, time aux= prev time

        JE check_time2                   ; if its the same. check again
        mov time_aux,dl                 ;update time

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if its different then come to this part;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;call clear_screen               ;clearing screen every iteration

        BuildBrick brick1x,brick1y,brick_collision_1 
        BuildBrick brick2x,brick2y,brick_collision_2
        BuildBrick brick3x,brick3y,brick_collision_3  
        BuildBrick brick4x,brick4y,brick_collision_4 
        BuildBrick brick5x,brick5y,brick_collision_5 
        BuildBrick brick6x,brick6y,brick_collision_6 
        BuildBrick brick7x ,brick7y,brick_collision_7 
        BuildBrick brick8x ,brick8y,brick_collision_8 
        BuildBrick brick9x ,brick9y,brick_collision_9 
        BuildBrick brick10x ,brick10y,brick_collision_10 
        BuildBrick brick11x ,brick11y,brick_collision_11
        BuildBrick brick12x ,brick12y,brick_collision_12 
        
        call drawBoundary
       
        call move_ball                  ;proc that moves the ball
        call draw_ball                  ;drawing ball after every refresh
        call DrawLivesScores
        call draw_lives
        cmp scoreCount,12
        je goiback
        
        call move_paddle                ;proc that maoves the paddle
        call draw_paddle                ;proc to draw the paddle

        call check_brick_collision

        jmp check_time2                  ;after everything checks time again


    goiback:
    RET
LEVEL_3 ENDP



mov ah,4ch
int 21h
end
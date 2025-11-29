; ============================================================
; ui.asm — Generic 2D UI / Drawing Utilities for VGA Mode 13h
; Safe for 16-bit real mode, include-only module for .COM builds
; ============================================================
;
; FUNCTION INDEX:
; ---------------
; drawPixel          - Draws a single pixel at specified coordinates
; drawText           - Renders text string as colored rectangles
; drawNumber         - Displays a numeric value using digit sprites
; drawDigit          - Renders a single digit (0-9) using font data
; clearScreen        - Fills entire screen with specified color
; drawHorizontalLine - Draws a horizontal line of specified length
; drawVerticalLine   - Draws a vertical line of specified length
; drawRoundedRect    - Draws a filled rectangle with rounded corners
; drawFilledRect     - Draws a solid filled rectangle
; drawRectOutline    - Draws hollow rectangle (border only)
; drawCircleOutline  - Draws unfilled circle using Bresenham algorithm
; drawCircleFilled   - Draws solid filled circle with horizontal spans
; drawChar           - Renders single ASCII character using 8x8 font
; drawString         - Renders null-terminated string using 8x8 font
;
; ============================================================

%define SCREEN_WIDTH    320
%define SCREEN_HEIGHT   200
%define VGA_SEGMENT     0xA000
%define GAMEOVER_DARK_GRAY 8

; ------------------------------------------------------------
; printChar — draw 9x16 bitmap character
; ------------------------------------------------------------
; INPUT:
;   BX = X coordinate (top-left)
;   DX = Y coordinate (top-left)
;   [char_color] = pixel color (byte)
;   AH = ASCII code
; ------------------------------------------------------------
printChar:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp        ; NOW we can use [bp+offset]
    
    ; Stack layout:
    ; [bp+0] = saved BP
    ; [bp+2] = saved DI
    ; [bp+4] = saved SI
    ; [bp+6] = saved DX (original Y)
    ; [bp+8] = saved CX
    ; [bp+10] = saved BX (original X)
    ; [bp+12] = saved AX

    ; Determine char code robustly:
    mov si, word [bp+12]  ; get original AX
    and si, 0FFh
    cmp si, 0
    jne .have_char_in_AL
    mov si, word [bp+12]
    shr si, 8
.have_char_in_AL:
    and si, 0FFh
    shl si, 5         ; multiply by 32
    add si, font9x16

    mov cx, 16        ; 16 rows per character
    mov di, 0         ; row counter

.row_loop:
    lodsw             ; Load one word (row of 9 bits)
    
    push ax           ; save the bitmap
    push cx           ; save row counter
    
    mov bx, [bp+10]   ; Get original X
    mov dx, [bp+6]    ; Get original Y
    add dx, di        ; Add row offset
    
    mov cx, 9         ; 9 bits per font row

.bit_loop:
    test word [bp-2], 0x8000   ; Test leftmost bit of saved bitmap
    jz .skip_bit
    
    push bx
    push cx
    push dx
    
    ; Draw pixel at (bx, dx)
    mov ax, dx
    mov cx, 320
    mul cx
    add ax, bx
    mov bx, ax
    mov ax, 0xA000
    mov es, ax
    mov al, [char_color]
    mov [es:bx], al
    
    pop dx
    pop cx
    pop bx

.skip_bit:
    inc bx            ; Move to next X position
    shl word [bp-2], 1  ; Shift to next bit
    dec cx
    jnz .bit_loop

    pop cx            ; restore row counter
    pop ax            ; restore (but we don't need it)
    inc di            ; next row offset
    dec cx
    jnz .row_loop

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawPixel
; ------------------------------------------------------------
; INPUT:
;   AX = X coordinate (0-319)
;   BX = Y coordinate (0-199)
;   SI = Color value (0-255)
; OUTPUT:
;   Single pixel drawn at (X,Y) in VGA memory
; EFFECT:
;   Sets pixel at calculated offset (Y*320 + X) to specified color
;   Performs bounds checking; skips if out of range
; ------------------------------------------------------------
; ======================================================================
; drawPixel (VGA 320x200)
; AX=x, BX=y, si=color
; ======================================================================
drawPixel:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    
    ; Bounds check
    cmp ax, 320
    jae .done
    cmp bx, 200
    jae .done
    
    mov dx, ax
    ; Calculate offset: DX * 320 + CX
    mov ax, bx
    mov bx, 320
    mul bx
    add ax, dx
    mov di, ax
    
    ; Write pixel
    mov ax, 0xA000
    mov es, ax
    mov ax, si
    mov [es:di], al

.done:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawNumber
; ------------------------------------------------------------
; INPUT:
;   AX = Starting X coordinate
;   BX = Starting Y coordinate
;   CL = Color value
;   DX = Number to display (0-65535)
; OUTPUT:
;   Number rendered as series of digit sprites
; EFFECT:
;   Converts number to decimal digits
;   Calls drawDigit for each digit from left to right
;   Advances X by 8 pixels per digit
; ------------------------------------------------------------
drawNumber:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 12
    
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cl
    mov si, bp
    sub si, 12
    
    mov ax, dx
    mov bx, 10
    mov di, si
    
.convert:
    xor dx, dx
    div bx
    add dl, '0'
    dec di
    mov [di], dl
    test ax, ax
    jnz .convert
    
    mov cx, si
    sub cx, di
    
    mov ax, [bp-2]
    mov bx, [bp-4]
    mov dl, byte [bp-6]

.print_loop:
    push cx
    push ax
    push bx
    push dx
    push di
    
    mov al, byte [di]
    sub al, '0'
    call drawDigit
    
    pop di
    pop dx
    pop bx
    pop ax
    add ax, 8
    inc di
    pop cx
    loop .print_loop
    
    add sp, 12
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawDigit
; ------------------------------------------------------------
; INPUT:
;   AL = Digit value (0-9)
;   [bp-2] = X coordinate (from caller's stack frame)
;   [bp-4] = Y coordinate (from caller's stack frame)
;   [bp-6] = Color value (from caller's stack frame)
; OUTPUT:
;   Single digit rendered as 7x8 pixel sprite
; EFFECT:
;   Looks up digit bitmap from font_table
;   Draws each pixel bit by bit, row by row
;   Uses bit shifting to test each pixel in bitmap
; ------------------------------------------------------------
drawDigit:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push bp

    mov bp, sp
    sub sp, 6
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], dl
    
    xor ah, ah
    cmp al, 9
    ja .done
    shl ax, 1
    mov si, ax
    mov si, [font5x8 + si] ; heere chanced
    
    mov ax, 0xA000
    mov es, ax
    
    mov cx, 8
    mov bx, [bp-4]
    
.row_loop:
    push cx
    mov al, byte [si]
    mov cx, 7
    mov ax, [bp-2]
    
.bit_loop:
    push cx
    push ax
    
    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    add di, ax
    
    mov al, byte [si]
    mov cl, 7
    push bp
    mov bp, sp
    sub cl, byte [bp+2]
    pop bp
    shl al, cl
    test al, 0x80
    jz .skip_bit
    
    mov al, byte [bp-6]
    mov byte [es:di], al
    
.skip_bit:
    pop ax
    inc ax
    pop cx
    loop .bit_loop
    
    inc si
    inc bx
    pop cx
    loop .row_loop
    
.done:
    add sp, 6
    pop bp
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; clearScreen
; ------------------------------------------------------------
; INPUT:
;   AL = Color value to fill screen (0-255)
; OUTPUT:
;   Entire screen filled with specified color
; EFFECT:
;   Uses REP STOSB to efficiently write 64000 bytes
;   Sets all VGA memory (0xA000:0000) to same color
; ------------------------------------------------------------
clearScreen:
    push ax
    push cx
    push di
    push es

    mov ax, VGA_SEGMENT
    mov es, ax
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT   ; 64000
    rep stosb

    pop es
    pop di
    pop cx
    pop ax
    ret

; ------------------------------------------------------------
; drawHorizontalLine
; ------------------------------------------------------------
; INPUT:
;   AX = Starting X coordinate
;   BX = Y coordinate
;   CX = Length in pixels
;   SI = Color value
; OUTPUT:
;   Horizontal line drawn from (X,Y) extending CX pixels right
; EFFECT:
;   Calculates starting offset (Y*320 + X)
;   Writes color value CX times sequentially
;   Performs basic bounds checking
; ------------------------------------------------------------
drawHorizontalLine:
    push ax
    push bx
    push cx
    push di
    push es
    push dx

    cmp bx, 200
    jae .done
    cmp ax, 320
    jae .done

    mov di, 0xA000
    mov es, di

    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    add di, ax

.draw_loop:
    cmp di, 64000
    jae .done
    mov [es:di], si
    inc di
    loop .draw_loop

.done:
    pop dx
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawVerticalLine
; ------------------------------------------------------------
; INPUT:
;   AX = X coordinate
;   BX = Starting Y coordinate
;   DX = Length in pixels (height)
;   SI = Color value
; OUTPUT:
;   Vertical line drawn from (X,Y) extending DX pixels down
; EFFECT:
;   Recalculates offset for each row (Y*320 + X)
;   Writes one pixel per row, incrementing Y
;   Loops DX times downward
; ------------------------------------------------------------
drawVerticalLine:
    push ax
    push bx
    push dx
    push di
    push es

    cmp ax, 320
    jae .done
    cmp bx, 200
    jae .done

    mov di, 0xA000
    mov es, di

.draw_loop:
    push dx
    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    pop dx
    add di, ax
    
    mov [es:di], si
    inc bx
    dec dx
    jnz .draw_loop

.done:
    pop es
    pop di
    pop dx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawRoundedRect
; ------------------------------------------------------------
; INPUT:
;   AX = X coordinate (top-left)
;   BX = Y coordinate (top-left)
;   CX = Width in pixels
;   DX = Height in pixels
;   SI = Fill color
;   DI = Border color
; OUTPUT:
;   Rounded rectangle with 2-pixel corner radius
; EFFECT:
;   Draws main body as filled rect (offset by 2 pixels)
;   Draws top/bottom strips for rounded edges
;   Draws border outline using drawRectOutline
;   Creates visual effect of rounded corners by omitting corner pixels
; ------------------------------------------------------------
drawRoundedRect:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 10
    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov word [bp-8], dx
    mov word [bp-10], si

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 2
    mov cx, [bp-6]
    mov dx, [bp-8]
    sub dx, 4
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    mov cx, [bp-6]
    sub cx, 4
    mov dx, 2
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    add bx, [bp-8]
    sub bx, 2
    mov cx, [bp-6]
    sub cx, 4
    mov dx, 2
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov cx, [bp-6]
    mov dx, [bp-8]
    mov si, di
    call drawRectOutline

    add sp, 10
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawFilledRect
; ------------------------------------------------------------
; INPUT:
;   AX = X coordinate (top-left)
;   BX = Y coordinate (top-left)
;   CX = Width in pixels
;   DX = Height in pixels
;   SI = Color value
; OUTPUT:
;   Solid filled rectangle
; EFFECT:
;   Draws DX rows, each CX pixels wide
;   Calculates offset for each row: (Y*320 + X)
;   Fills each row left to right with specified color
; ------------------------------------------------------------
drawFilledRect:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    push bp

    cmp ax, 320
    jae .done
    cmp bx, 200
    jae .done

    mov bp, 0xA000
    mov es, bp

    mov bp, dx

.row_loop:
    push cx
    push ax
    
    mov di, bx
    push dx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    pop dx
    add di, ax

.col_loop:
    mov [es:di], si
    inc di
    loop .col_loop
    
    pop ax
    pop cx
    inc bx
    dec bp
    jnz .row_loop

.done:
    pop bp
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawRectOutline
; ------------------------------------------------------------
; INPUT:
;   AX = X coordinate (top-left)
;   BX = Y coordinate (top-left)
;   CX = Width in pixels
;   DX = Height in pixels
;   SI = Color value for border
; OUTPUT:
;   Hollow rectangle (4 border lines only)
; EFFECT:
;   Draws top horizontal line at (X, Y)
;   Draws bottom horizontal line at (X, Y+Height-1)
;   Draws left vertical line at (X, Y)
;   Draws right vertical line at (X+Width-1, Y)
;   Interior remains unchanged
; ------------------------------------------------------------
drawRectOutline:
    push ax
    push bx
    push cx
    push dx
    push di
    push bp

    mov bp, sp
    sub sp, 8
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cx
    mov [bp-8], dx

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov cx, [bp-6]
    call drawHorizontalLine

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, [bp-8]
    dec bx
    mov cx, [bp-6]
    call drawHorizontalLine

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov dx, [bp-8]
    call drawVerticalLine

    mov ax, [bp-2]
    add ax, [bp-6]
    dec ax
    mov bx, [bp-4]
    mov dx, [bp-8]
    call drawVerticalLine

    add sp, 8
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;x
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               NEW ADDED FUNCTIONS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT: AL = darkness level (0=none, 1=light, 2=medium, 3=dark)
; EFFECT: Darkens entire screen by shifting pixels toward black
drawDarkenOverlay:
    push ax
    push cx
    push di
    push es

    mov di, 0xA000
    mov es, di
    xor di, di
    mov cx, 64000

.darken_loop:
    mov ah, [es:di]
    cmp al, 1
    je .light_darken
    cmp al, 2
    je .medium_darken
    cmp al, 3
    je .dark_darken
    jmp .skip_pixel

.light_darken:
    shr ah, 1
    jmp .apply_darken

.medium_darken:
    shr ah, 2
    jmp .apply_darken

.dark_darken:
    shr ah, 3

.apply_darken:
    mov [es:di], ah

.skip_pixel:
    inc di
    loop .darken_loop

    pop es
    pop di
    pop cx
    pop ax
    ret

; INPUT: AX=x, BX=y, DS:SI -> string, AL=color, DL=selected_flag
; EFFECT: Draws menu text, adds highlight box if selected

; ============================================================
; drawExplosionParticle
; ============================================================
; INPUT:
;   AX = X coordinate
;   BX = Y coordinate
;   CL = Size of particle square (width & height)
;   DL = Color value
; EFFECT:
;   Draws a small filled square (particle)
; DEPENDENCY:
;   Calls drawFilledRect (AX,BX,CX,DX,SI)
; ============================================================
drawExplosionParticle:
    push ax
    push bx
    push cx
    push dx
    push si

    ; -- Set parameters for drawFilledRect --
    movzx cx, cl        ; width = size
    mov dx, cx          ; height = size
    movzx si, dl        ; color

    call drawFilledRect

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; INPUT: AX=x, BX=y, CX=max_width, DX=value, SI=max_value, DI=color
; EFFECT: Draws horizontal progress/stat bar
drawStatBar:
    push ax
    push bx
    push cx
    push dx
    push si
    push bp

    ; Calculate filled width: (value * max_width) / max_value
    push ax
    mov ax, dx
    mul cx
    div si
    mov bp, ax      ; Filled width in BP
    pop ax

    ; Draw background (gray)
    push cx
    push di
    mov dx, 4
    mov si, GAMEOVER_DARK_GRAY
    call drawFilledRect
    pop di
    pop cx

    ; Draw filled portion
    mov cx, bp
    or cx, cx
    jz .done
    mov dx, 4
    mov si, di
    call drawFilledRect

.done:
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; INPUT: BX=y, AL=blink_state
; EFFECT: Draws centered blinking text

; ------------------------------------------------------------
; Data
; ------------------------------------------------------------
char_color db 0              ; Temporary storage for text color
;font8x8:                     ; 8x8 bitmap font data (2048 bytes: 256 chars * 8 bytes)
;    incbin "font8x8.bin"

font5x8 : 
    db 0b01111100,0b10000010,0b11111110,0b10000010,0b10000010 ;A
    db 0b11111100,0b10000010,0b11111100,0b10000010,0b11111100 ;B
    db 0b01111110,0b10000000,0b10000000,0b10000000,0b01111110 ;C
    db 0b11111000,0b10000100,0b10000010,0b10000100,0b11111000 ;D
    db 0b11111110,0b10000000,0b11111100,0b10000000,0b11111110 ;E
    db 0b11111110,0b10000000,0b11111100,0b10000000,0b10000000 ;F
    db 0b01111110,0b10000000,0b10011110,0b10000010,0b01111110 ;G
    db 0b10000010,0b10000010,0b11111110,0b10000010,0b10000010 ;H
    db 0b11111110,0b00011000,0b00011000,0b00011000,0b11111110 ;I
    db 0b00111110,0b00001000,0b00001000,0b10001000,0b01110000 ;J
    db 0b10000100,0b10001000,0b11110000,0b10001000,0b10000100 ;K
    db 0b10000000,0b10000000,0b10000000,0b10000000,0b11111110 ;L
    db 0b10000010,0b11000110,0b10101010,0b10010010,0b10000010 ;M
    db 0b10000010,0b11000010,0b10100010,0b10011010,0b10000110 ;N
    db 0b01111100,0b10000010,0b10000010,0b10000010,0b01111100 ;O
    db 0b11111100,0b10000010,0b11111100,0b10000000,0b10000000 ;P
    db 0b01111100,0b10000010,0b10000010,0b10000110,0b01111110 ;Q
    db 0b11111100,0b10000010,0b11111100,0b10001000,0b10000100 ;R
    db 0b01111110,0b10000000,0b01111100,0b00000010,0b11111100 ;S
    db 0b11111110,0b00011000,0b00011000,0b00011000,0b00011000 ;T
    db 0b10000010,0b10000010,0b10000010,0b10000010,0b01111100 ;U
    db 0b10000010,0b10000010,0b10000010,0b01000100,0b00101000 ;V
    db 0b10000010,0b10010010,0b10101010,0b11000110,0b10000010 ;W
    db 0b10000010,0b01000100,0b00101000,0b01000100,0b10000010 ;X
    db 0b10000010,0b01000100,0b00101000,0b00010000,0b00010000 ;Y
    db 0b11111110,0b00000100,0b00011000,0b01100000,0b11111110 ;Z

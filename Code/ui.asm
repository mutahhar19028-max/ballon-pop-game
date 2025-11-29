%define SCREEN_WIDTH    320
%define SCREEN_HEIGHT   200
%define VGA_SEGMENT     0xA000

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

    mov bp, VGA_SEGMENT
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
; clearScreen
; ------------------------------------------------------------
; INPUT:
;   [char_color] = Color value to fill screen (0-255)
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
    xor ah, ah
    mov al, [char_color]
    rep stosb

    pop es
    pop di
    pop cx
    pop ax
    ret

; ------------------------------------------------------------
; display_palette_wide
; ------------------------------------------------------------
; EFFECT:
;   Prints 256 colors as wide strips (160 pixels each)
; ------------------------------------------------------------
display_palette_wide:
    push ax
    push bx             ; Preserve BX for inner loop counter
    push cx
    push di
    push es
    
    ; 1. Setup ES:DI to point to the start of VGA memory (A000:0000)
    mov ax, 0A000h      ; VGA_SEGMENT
    mov es, ax
    xor di, di          ; DI = 0 (start of video memory)

    ; 2. Setup Outer Loop (256 Colors)
    mov cx, 256          ; CX = Outer loop counter (256 colors)
    mov al, 0         ; AL = Color Index (starts at 0)

outer_color_loop:
    ; 3. Setup Inner Loop (160 Pixels)
    mov bx, 320*200         ; BX = Inner loop counter (160 pixels wide)

inner_pixel_loop:
    stosb               ; Write AL (current color) to [ES:DI], then DI = DI + 1
    dec bx              ; BX = BX - 1
    jnz inner_pixel_loop; Continue inner loop until 160 pixels are written

    push ax
    mov ax, 0
    int 16h
    pop ax

    ; 4. Increment Color Index
    inc al              ; AL = AL + 1 (move to the next color)

    ; 5. Continue Outer Loop
    loop outer_color_loop ; Decrement CX, jump to outer_color_loop if CX != 0

    ; Restore registers
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret


; ======================================================================
; drawText  (CX=x, DX=y, SI=ptr, BL=color, BH=scale)
; ======================================================================
drawText:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov [dt_x_pos], cx
    mov [dt_y_pos], dx
    mov [dt_color], bl
    mov [dt_scale], bh

.next:
    lodsb
    or al, al
    jz .done
    cmp al, ' '
    je .space

    push si
    call drawChar
    pop si

.space:
    ; Move cursor: advance by (9 * scale) pixels (9 width for 9x16)
    mov al, [dt_scale]
    xor ah, ah
    mov cl, 9
    mul cl
    add [dt_x_pos], ax
    mov cx, [dt_x_pos]
    mov dx, [dt_y_pos]
    jmp .next

.done:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ======================================================================
; drawChar — draws scaled character using BIOS 8x8 font
; Input: AL = ASCII character
; Uses [dt_x_pos], [dt_y_pos], [dt_color], [dt_scale]
; ======================================================================
drawChar:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    ; --- Compute glyph offset: 8 bytes per character ---
    mov ah, 0
    mov bl, 8
    mul bl                  ; AX = ASCII * 8 (each glyph = 8 bytes)
    mov si, FONT_OFF
    add si, ax
    mov ax, FONT_SEG
    mov es, ax              ; ES:SI -> glyph start

    ; --- Save start X/Y ---
    mov ax, [dt_x_pos]
    mov [.start_x], ax
    mov ax, [dt_y_pos]
    mov [.start_y], ax

    mov bp, 8               ; 8 rows per glyph

.row_loop:
    mov al, [es:si]         ; read next row (8 bits)
    inc si

    mov cx, [.start_x]      ; reset X
    mov dx, [dt_y_pos]      ; current Y

    mov di, 8               ; 8 bits per row

.bit_loop:
    mov dx, [dt_y_pos]
    test al, 0x80
    jz .skip_bit

    push ax
    push di

    xor bh, bh
    mov bl, [dt_scale]
    mov [.scale_y_count], bx

.scale_y_loop:
    push cx
    push dx
    xor bh, bh
    mov bl, [dt_scale]
    mov [.scale_x_count], bx

.scale_x_loop:
    call putPixel
    inc cx
    dec word [.scale_x_count]
    jnz .scale_x_loop

    pop dx
    pop cx
    inc dx
    dec word [.scale_y_count]
    jnz .scale_y_loop

    pop di
    pop ax

.skip_bit:
    xor bh, bh
    mov bl, [dt_scale]
    add cx, bx
    shl al, 1
    dec di
    jnz .bit_loop

    ; Advance Y
    mov ax, [dt_y_pos]
    mov bx, [dt_scale]
    add ax, bx
    mov [dt_y_pos], ax

    dec bp
    jnz .row_loop

    ; Restore Y
    mov ax, [.start_y]
    mov [dt_y_pos], ax

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

.start_x        dw 0
.start_y        dw 0
.scale_x_count  dw 0
.scale_y_count  dw 0

; ======================================================================
; putPixel (VGA 320x200)
; CX=x, DX=y, color in [dt_color]
; ======================================================================
putPixel:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; bounds check (safe for 320x200)
    cmp cx, 320
    jae .done_put
    cmp dx, 200
    jae .done_put

    ; offset = y*320 + x
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov di, ax

    mov ax, 0xA000
    mov es, ax
    mov al, [dt_color]
    mov [es:di], al

.done_put:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ======================================================================
; drawSelectionArrow
; ======================================================================
drawSelectionArrow:
    push ax
    push bx
    push cx
    push dx

    mov [dt_color], bl
    mov byte [dt_scale], 1
    mov [dt_x_pos], cx
    mov [dt_y_pos], dx
    mov al, '>'
    call drawChar

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; screenDelay
; Small delay for smooth animation (adjust for desired FPS)
; ------------------------------------------------------------
screenDelay:
    push cx
    mov cx, 0x1000
.delay_loop:
    nop
    loop .delay_loop
    pop cx
    ret

; ------------------------------------------------------------
; drawCircleOutline - FIXED VERSION (8088 Compatible)
; ------------------------------------------------------------
drawCircleOutline:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16

    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    ; **FIX: Set dt_color once at the start**
    mov [dt_color], dl

    mov word [bp-10], 0
    mov ax, [bp-6]
    mov word [bp-12], ax

    mov ax, 1
    sub ax, [bp-6]
    mov word [bp-14], ax

.circle_outline_loop:
    mov ax, [bp-10]
    mov bx, [bp-12]

    ; 1: (cx + x, cy + y)
    mov cx, [bp-2]
    add cx, [bp-10]
    mov dx, [bp-4]
    add dx, [bp-12]
    call putPixel

    ; 2: (cx - x, cy + y)
    mov cx, [bp-2]
    sub cx, [bp-10]
    mov dx, [bp-4]
    add dx, [bp-12]
    call putPixel

    ; 3: (cx + x, cy - y)
    mov cx, [bp-2]
    add cx, [bp-10]
    mov dx, [bp-4]
    sub dx, [bp-12]
    call putPixel

    ; 4: (cx - x, cy - y)
    mov cx, [bp-2]
    sub cx, [bp-10]
    mov dx, [bp-4]
    sub dx, [bp-12]
    call putPixel

    ; 5: (cx + y, cy + x)
    mov cx, [bp-2]
    add cx, [bp-12]
    mov dx, [bp-4]
    add dx, [bp-10]
    call putPixel

    ; 6: (cx - y, cy + x)
    mov cx, [bp-2]
    sub cx, [bp-12]
    mov dx, [bp-4]
    add dx, [bp-10]
    call putPixel

    ; 7: (cx + y, cy - x)
    mov cx, [bp-2]
    add cx, [bp-12]
    mov dx, [bp-4]
    sub dx, [bp-10]
    call putPixel

    ; 8: (cx - y, cy - x)
    mov cx, [bp-2]
    sub cx, [bp-12]
    mov dx, [bp-4]
    sub dx, [bp-10]
    call putPixel

    mov ax, [bp-14]
    cmp ax, 0
    jl .d_less_zero
    
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    mov si, [bp-12]
    shl si, 1
    sub dx, si
    add ax, dx
    add ax, 5
    mov [bp-14], ax
    dec word [bp-12]
    jmp .d_done

.d_less_zero:
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    add ax, dx
    add ax, 3
    mov [bp-14], ax

.d_done:
    inc word [bp-10]
    mov ax, [bp-10]
    cmp ax, [bp-12]
    jle .circle_outline_loop

    add sp, 16
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawCircleFilled - FIXED VERSION (8088 Compatible)
; ------------------------------------------------------------
drawCircleFilled:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16
    
    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    mov word [bp-10], 0
    mov ax, [bp-6]
    mov word [bp-12], ax

    mov ax, 1
    sub ax, [bp-6]
    mov word [bp-14], ax

.fill_loop:
    ; Length1 = 2*x + 1
    mov ax, [bp-10]
    shl ax, 1
    add ax, 1
    mov cx, ax

    ; StartX = center_x - x
    mov ax, [bp-2]
    sub ax, [bp-10]
    mov dx, ax

    ; Y = center_y - y
    mov bx, [bp-4]
    sub bx, [bp-12]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]  ; Load color (byte stored in word position)
    and si, 0x00FF       ; Mask to get only low byte
    call drawHorizontalLine

    ; Y = center_y + y
    mov bx, [bp-4]
    add bx, [bp-12]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    ; Length2 = 2*y + 1
    mov ax, [bp-12]
    shl ax, 1
    add ax, 1
    mov cx, ax

    ; StartX2 = center_x - y
    mov ax, [bp-2]
    sub ax, [bp-12]
    mov dx, ax

    ; Y = center_y - x
    mov bx, [bp-4]
    sub bx, [bp-10]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    ; Y = center_y + x
    mov bx, [bp-4]
    add bx, [bp-10]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    mov ax, [bp-14]
    cmp ax, 0
    jl .f_d_less_zero
    
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    mov si, [bp-12]
    shl si, 1
    sub dx, si
    add ax, dx
    add ax, 5
    mov [bp-14], ax
    dec word [bp-12]
    jmp .f_d_done

.f_d_less_zero:
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    add ax, dx
    add ax, 3
    mov [bp-14], ax

.f_d_done:
    inc word [bp-10]
    mov ax, [bp-10]
    cmp ax, [bp-12]
    jle .fill_loop

    add sp, 16
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; clearScreen320x200
; Clears entire 320x200 VGA screen to specified color
; INPUT: AL = Color value (0-255)
; Uses BIOS interrupt for compatibility
; ------------------------------------------------------------
clearScreen320x200:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; Method 1: Direct VGA memory write (faster)
    mov bx, VGA_SEGMENT
    mov es, bx
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT   ; 64000
    mov ah, al              ; Duplicate color in AH
    rep stosb

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; clearScreenBIOS
; Alternative: Uses BIOS scroll to clear screen (slower but safer)
; INPUT: AL = Color value
; ------------------------------------------------------------
clearScreenBIOS:
    push ax
    push bx
    push cx
    push dx

    ; BIOS: Scroll window (clear screen)
    mov ah, 0x06        ; Scroll up function
    mov al, 0           ; Clear entire window
    mov bh, 0           ; Attribute (ignored in mode 13h)
    mov cx, 0           ; Upper left (0,0)
    mov dx, 0xC813      ; Lower right (200, 320 in rows/cols)
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; setVideoMode13h
; Sets VGA mode 320x200x256 using BIOS interrupt
; ------------------------------------------------------------
setVideoMode13h:
    push ax
    mov ax, 0x0013
    int 0x10
    pop ax
    ret

; ------------------------------------------------------------
; setTextMode
; Returns to text mode 80x25
; ------------------------------------------------------------
setTextMode:
    push ax
    mov ax, 0x0003
    int 0x10
    pop ax
    ret
; ============================================================================
; drawBalloon - ADJUSTED FOR 24x21 pixels
; ============================================================================
; INPUT: AX=x, BX=y, CL=color, DL=letter
; Draws a wider balloon perfect for 8x8 character at scale 1
; ============================================================================
drawBalloon:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 8
    mov [bp-2], ax          ; Save X
    mov [bp-4], bx          ; Save Y
    mov [bp-6], cl          ; Save color
    mov [bp-8], dl          ; Save letter

    ; Draw balloon body (oval shape using filled circle)
    mov ax, [bp-2]
    add ax, 12              ; Center X (24/2 = 12)
    mov bx, [bp-4]
    add bx, 8               ; Center Y (16/2 = 8, for body height)
    mov cx, 7               ; Radius for oval
    mov dl, byte [bp-6]
    call drawCircleFilled

    ; Draw wider horizontal lines to make it oval (not perfectly round)
    ; Middle horizontal line (widest part)
    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    add bx, 8               ; Middle Y
    mov cx, 20              ; Width of oval
    xor si, si
    mov si, [bp-6]
    and si, 0x00FF
    call drawHorizontalLine

    ; Upper-middle horizontal line
    mov ax, [bp-2]
    add ax, 3
    mov bx, [bp-4]
    add bx, 6
    mov cx, 18
    xor si, si
    mov si, [bp-6]
    and si, 0x00FF
    call drawHorizontalLine

    ; Lower-middle horizontal line
    mov ax, [bp-2]
    add ax, 3
    mov bx, [bp-4]
    add bx, 10
    mov cx, 18
    xor si, si
    mov si, [bp-6]
    and si, 0x00FF
    call drawHorizontalLine

    ; Draw balloon outline (darker shade for definition)
    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 8
    mov cx, 7
    mov dl, [dark_brown]    ; Dark outline
    call drawCircleOutline

    ; Draw knot (small rectangle at bottom of balloon)
    mov ax, [bp-2]
    add ax, 10              ; Center knot (24/2 - 2 = 10)
    mov bx, [bp-4]
    add bx, 16              ; Below balloon body
    mov cx, 4               ; Width
    mov dx, 2               ; Height
    xor si, si
    mov si, [bp-6]
    and si, 0x00FF
    call drawFilledRect

    ; Draw string (vertical line)
    mov ax, [bp-2]
    add ax, 12              ; Center string (24/2 = 12)
    mov bx, [bp-4]
    add bx, 18              ; Below knot
    mov dx, 3               ; String length
    xor si, si
    mov si, [dark_brown]    ; Dark string
    and si, 0x00FF
    call drawVerticalLine

    ; Draw letter on balloon (8x8 at scale 1)
    mov cx, [bp-2]
    add cx, 8               ; Center letter X (24/2 - 8/2 = 8)
    mov dx, [bp-4]
    add dx, 4               ; Center letter Y
    mov bh, 1               ; Scale 1 (8x8 pixels)
    mov bl, [dark_brown]    ; Dark letter color for contrast
    
    ; Create single-char string
    sub sp, 2
    mov di, sp
    mov al, [bp-8]          ; Get letter
    mov [di], al
    mov byte [di+1], 0      ; Null terminator
    mov si, di
    call drawText
    add sp, 2

    add sp, 8
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
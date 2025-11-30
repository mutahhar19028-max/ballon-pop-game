; ============================================================================
; drawBalloon - Fixed color usage with provided palette
; ============================================================================
; INPUT: AX=x, BX=y, CL=color_index, DL=letter
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
    sub sp, 10              ; Increased space for circle_color
    mov [bp-2], ax          ; Save X
    mov [bp-4], bx          ; Save Y
    mov [bp-6], cl          ; Save color index (0-7)
    mov [bp-8], dl          ; Save letter

    ; Get actual color for balloon body from balloon_colors table
    mov cl, [bp-6]
    and cl, 0x07
    mov si, balloon_colors
    add si, cx
    mov cl, [si]            ; CL = balloon color
    mov [bp-10], cl         ; Save balloon body color

    ; Get random color for filled circle
    call getRandomNumber
    mov bx, 6               ; 6 colors in balloon_colors
    xor dx, dx
    div bx                  ; DX = random index (0-5)
    mov si, balloon_colors
    add si, dx
    mov dl, [si]            ; DL = random circle color

    ; Draw balloon body (oval) with RANDOM color
    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 8
    mov cx, 7
    ; DL already contains random color
    call drawCircleFilled

    ; Draw wider horizontal lines for oval shape (use body color)
    mov cl, [bp-10]         ; Restore body color
    
    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    add bx, 8
    mov cx, 20
    mov si, cx
    call drawHorizontalLine

    mov ax, [bp-2]
    add ax, 3
    mov bx, [bp-4]
    add bx, 6
    mov cx, 18
    mov si, cx
    call drawHorizontalLine

    mov ax, [bp-2]
    add ax, 3
    mov bx, [bp-4]
    add bx, 10
    mov cx, 18
    mov si, cx
    call drawHorizontalLine

    ; Draw balloon outline in dark brown
    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 8
    mov cx, 7
    mov dl, [dark_brown]
    call drawCircleOutline

    ; Draw knot rectangle in light orange
    mov ax, [bp-2]
    add ax, 10
    mov bx, [bp-4]
    add bx, 16
    mov cx, 4
    mov dx, 2
    mov si, [light_orange]
    call drawFilledRect

    ; Draw string in dark brown
    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 18
    mov dx, 3
    mov si, [dark_brown]
    call drawVerticalLine

    ; Draw letter on balloon (8x8 at scale 1) in white
    mov cx, [bp-2]
    add cx, 9
    mov dx, [bp-4]
    add dx, 3
    mov bh, 1          ; Scale
    mov bl, [dark_brown]    ; Letter color

    sub sp, 2
    mov di, sp
    mov al, [bp-8]
    mov [di], al
    mov byte [di+1], 0
    mov si, di
    call drawText
    add sp, 2

    add sp, 10              ; Match increased space
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
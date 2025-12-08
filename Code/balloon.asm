drawBalloon:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 10
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cl
    mov [bp-8], dl

    mov cl, [bp-6]
    and cl, 0x07
    mov si, balloon_colors
    add si, cx
    mov cl, [si]
    mov [bp-10], cl

    call getRandomNumber
    mov bx, 6
    xor dx, dx
    div bx
    mov si, balloon_colors
    add si, dx
    mov dl, [si]

    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 8
    mov cx, 7
    call drawCircleFilled

    mov cl, [bp-10]
    
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

    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 8
    mov cx, 7
    mov dl, [dark_brown]
    call drawCircleOutline

    mov ax, [bp-2]
    add ax, 10
    mov bx, [bp-4]
    add bx, 16
    mov cx, 4
    mov dx, 2
    mov si, [light_orange]
    call drawFilledRect

    mov ax, [bp-2]
    add ax, 12
    mov bx, [bp-4]
    add bx, 18
    mov dx, 3
    mov si, [dark_brown]
    call drawVerticalLine

    mov cx, [bp-2]
    add cx, 9
    mov dx, [bp-4]
    add dx, 5
    mov bh, 1
    mov bl, [dark_brown]

    sub sp, 2
    mov di, sp
    mov al, [bp-8]
    mov [di], al
    mov byte [di+1], 0
    mov si, di
    call drawText
    add sp, 2

    add sp, 10
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
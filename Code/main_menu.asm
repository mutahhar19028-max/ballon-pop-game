drawMainMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov word[DIT], 0

    mov ax, 40
    mov bx, 20
    mov cx, 235
    mov dx, 35
    mov si, [dark_orange]
    mov di, [light_orange]
    call drawRoundedRect

    mov cx, [star_x]
    mov dx, [star_y]
    call saveStarBG

    mov cx, [star_x]
    mov dx, [star_y]
    mov al, '*'
    mov bl, [bright_yellow]
    mov bh, 1
    call drawSingleChar

    mov cx, 50
    mov dx, 30
    mov si, title_text
    mov bl, [nature_dark_green]
    mov bh, 2
    call drawText

    mov ax, MENU_BUTTON_X - 7
    mov bx, MENU_BUTTON_Y - 2
    mov cx, MENU_BUTTON_WIDTH + 15
    mov dx, MENU_BUTTON_HEIGHT + 4
    mov si, [dark_orange]
    mov di, [dark_brown]
    call drawRoundedRect

    mov ax, MENU_BUTTON_X
    add ax, MENU_BUTTON_WIDTH / 8
    mov cx, ax

    mov ax, MENU_BUTTON_Y
    add ax, MENU_BUTTON_HEIGHT / 4
    mov dx, ax

    mov si, menu_play
    mov bl, [dark_brown]
    mov bh, 2
    call drawText

    call updatePadding

    mov ax, MENU_BUTTON_X - 7
    mov bx, MENU_BUTTON_Y - 2
    add bx, [DIT]
    mov cx, MENU_BUTTON_WIDTH + 15
    mov dx, MENU_BUTTON_HEIGHT + 4
    mov si, [dark_orange]
    mov di, [dark_brown]
    call drawRoundedRect

    mov ax, MENU_BUTTON_X
    add ax, MENU_BUTTON_WIDTH / 8
    mov cx, ax

    mov ax, MENU_BUTTON_Y
    add ax, MENU_BUTTON_HEIGHT / 4
    add ax, [DIT]
    mov dx, ax

    mov si, menu_help
    mov bl, [dark_brown]
    mov bh, 2
    call drawText

    call updatePadding

    mov ax, MENU_BUTTON_X - 7
    mov bx, MENU_BUTTON_Y - 2
    add bx, [DIT]
    mov cx, MENU_BUTTON_WIDTH + 15
    mov dx, MENU_BUTTON_HEIGHT + 4
    mov si, [dark_orange]
    mov di, [dark_brown]
    call drawRoundedRect

    mov ax, MENU_BUTTON_X
    add ax, MENU_BUTTON_WIDTH / 8
    mov cx, ax

    mov ax, MENU_BUTTON_Y
    add ax, MENU_BUTTON_HEIGHT / 4
    add ax, [DIT]
    mov dx, ax

    mov si, menu_exit
    mov bl, [dark_brown]
    mov bh, 2
    call drawText

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

updatePadding:
    mov ax, [DIT]
    add ax, MENU_BUTTON_HEIGHT
    add ax, MENU_BUTTON_HEIGHT / 2
    mov [DIT], ax
    ret

animateTitleStar:
    push ax
    push bx
    push cx
    push dx
    push si

    inc byte [star_delay]
    cmp byte [star_delay], 2
    jl .skip_move
    mov byte [star_delay], 0

    mov cx, [star_x]
    mov dx, [star_y]
    call restoreStarBG

    cmp byte [star_dir], 0
    je .move_right
    cmp byte [star_dir], 1
    je .move_down
    cmp byte [star_dir], 2
    je .move_left
    jmp .move_up

.move_right:
    add word [star_x], 4
    mov ax, [star_x]
    cmp ax, 267
    jle .draw_new
    mov word [star_x], 267
    mov byte [star_dir], 1
    jmp .draw_new

.move_down:
    add word [star_y], 4
    mov ax, [star_y]
    cmp ax, 47
    jle .draw_new
    mov word [star_y], 47
    mov byte [star_dir], 2
    jmp .draw_new

.move_left:
    sub word [star_x], 4
    mov ax, [star_x]
    cmp ax, 40
    jge .draw_new
    mov word [star_x], 40
    mov byte [star_dir], 3
    jmp .draw_new

.move_up:
    sub word [star_y], 4
    mov ax, [star_y]
    cmp ax, 20
    jge .draw_new
    mov word [star_y], 20
    mov byte [star_dir], 0

.draw_new:
    mov cx, [star_x]
    mov dx, [star_y]
    call saveStarBG

    mov cx, [star_x]
    mov dx, [star_y]
    mov al, '*'
    mov bl, [bright_yellow]
    mov bh, 1
    call drawSingleChar

.skip_move:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

saveStarBG:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov si, ax

    mov ax, 0xA000
    mov ds, ax
    push cs
    pop es
    mov di, star_bg_buffer

    mov cx, 8
.save_loop:
    push cx
    mov cx, 8
    rep movsb
    add si, 312
    pop cx
    loop .save_loop

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

restoreStarBG:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov di, ax

    mov ax, 0xA000
    mov es, ax
    push cs
    pop ds
    mov si, star_bg_buffer

    mov cx, 8
.restore_loop:
    push cx
    mov cx, 8
    rep movsb
    add di, 312
    pop cx
    loop .restore_loop

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawSingleChar:
    push ax
    push si
    push di
    push bp
    
    sub sp, 2
    mov di, sp
    mov [di], al
    mov byte [di+1], 0
    mov si, di
    call drawText
    add sp, 2

    pop bp
    pop di
    pop si
    pop ax
    ret

DIT: dw 0
star_x: dw 40
star_y: dw 20
star_dir: db 0
star_delay: db 0
star_bg_buffer: times 64 db 0
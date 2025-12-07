musical_Score: 
    dw 262, 294, 330, 349, 392, 440, 494, 523
    dw 587, 659, 698, 784, 262, 294, 330, 349
    dw 392, 440, 494, 523, 587, 659, 698, 784

melody_index: dw 0

playMelody:
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, 0

.play_loop:
    mov bx, [musical_Score + si]
    call playTone
    add si, 2
    cmp si, 48
    jb .play_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

playPopSound:
    push ax
    push bx
    push cx
    push dx

    mov bx, 800
    call playShortTone

    mov bx, 600
    call playShortTone

    pop dx
    pop cx
    pop bx
    pop ax
    ret

playErrorSound:
    push ax
    push bx
    push cx
    push dx

    mov bx, 200
    call playTone

    pop dx
    pop cx
    pop bx
    pop ax
    ret

playSuccessSound:
    push ax
    push bx
    push cx
    push dx

    mov bx, 523
    call playShortTone
    mov bx, 659
    call playShortTone
    mov bx, 784
    call playShortTone

    pop dx
    pop cx
    pop bx
    pop ax
    ret

playTone:
    push ax
    push bx
    push dx

    in al, 61h
    push ax

    or al, 3h
    out 61h, al

    mov al, 0xB6
    out 43h, al

    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al

    call soundDelay

    pop ax
    and al, 0xFC
    out 61h, al

    call soundDelayShort

    pop dx
    pop bx
    pop ax
    ret

playShortTone:
    push ax
    push bx
    push dx

    in al, 61h
    push ax
    or al, 3h
    out 61h, al

    mov al, 0xB6
    out 43h, al

    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al

    call soundDelayShort

    pop ax
    and al, 0xFC
    out 61h, al

    pop dx
    pop bx
    pop ax
    ret

soundDelay:
    push cx
    push dx

    mov dx, 10

.outer:
    mov cx, 0xFFFF
.inner:
    loop .inner
    dec dx
    jnz .outer

    pop dx
    pop cx
    ret

soundDelayShort:
    push cx
    push dx

    mov dx, 3

.outer:
    mov cx, 0xFFFF
.inner:
    loop .inner
    dec dx
    jnz .outer

    pop dx
    pop cx
    ret
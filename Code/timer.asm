%define PIT_CHANNEL0    0x40
%define PIT_COMMAND     0x43
%define PIC_COMMAND     0x20
%define PIC_DATA        0x21

%define TICKS_PER_SEC   18
%define GAME_TIME_SEC   120
ticks       dw 0

timer_seconds       dw GAME_TIME_SEC
timer_minutes       db 2
timer_display_sec   db 0
timer_ticks         db 0
old_timer_vector    dd 0
timer_active        db 0

installTimerISR:
    push ax
    push bx
    push cx
    push dx
    push es

    mov ax, 0x3508
    int 0x21
    mov word [old_timer_vector], bx
    mov word [old_timer_vector+2], es

    push ds
    mov ax, cs
    mov ds, ax
    mov dx, timerISR
    mov ax, 0x2508
    int 0x21
    pop ds

    mov word [timer_seconds], GAME_TIME_SEC
    mov byte [timer_minutes], 2
    mov byte [timer_display_sec], 0
    mov byte [timer_ticks], 0
    mov byte [timer_active], 1

    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

restoreTimerISR:
    push ax
    push dx
    push ds

    lds dx, [old_timer_vector]
    mov ax, 0x2508
    int 0x21

    pop ds
    pop dx
    pop ax
    ret

timerISR:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, cs
    mov ds, ax

    cmp byte [timer_active], 1
    jne .chain_to_old

    inc byte [timer_ticks]
    cmp byte [timer_ticks], TICKS_PER_SEC
    jb .chain_to_old

    mov byte [timer_ticks], 0

    cmp word [timer_seconds], 0
    je .timer_expired

    dec word [timer_seconds]
    inc word [ticks]

    call updateTimerDisplay

.chain_to_old:
    mov al, 0x20
    out PIC_COMMAND, al

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret

.timer_expired:
    mov byte [timer_active], 0
    jmp .chain_to_old

updateTimerDisplay:
    push ax
    push bx
    push dx

    mov ax, [timer_seconds]

    xor dx, dx
    mov bx, 60
    div bx

    mov [timer_minutes], al
    mov [timer_display_sec], dl

    pop dx
    pop bx
    pop ax
    ret

resetTimer:
    push ax

    mov word [timer_seconds], GAME_TIME_SEC
    mov byte [timer_minutes], 2
    mov byte [timer_display_sec], 0
    mov byte [timer_ticks], 0
    mov byte [timer_active], 1

    pop ax
    ret

pauseTimer:
    mov byte [timer_active], 0
    ret

resumeTimer:
    mov byte [timer_active], 1
    ret

isTimerExpired:
    push bx
    
    mov al, 0
    cmp word [timer_seconds], 0
    jne .not_expired
    mov al, 1

.not_expired:
    pop bx
    ret

getTimerString:
    push ax
    push bx
    push cx
    push dx
    push di

    mov di, si

    xor ah, ah
    mov al, [timer_minutes]
    mov bl, 10
    div bl
    add al, '0'
    mov [di], al
    inc di
    mov al, ah
    add al, '0'
    mov [di], al
    inc di

    mov byte [di], ':'
    inc di

    xor ah, ah
    mov al, [timer_display_sec]
    mov bl, 10
    div bl
    add al, '0'
    mov [di], al
    inc di
    mov al, ah
    add al, '0'
    mov [di], al
    inc di

    mov byte [di], 0

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
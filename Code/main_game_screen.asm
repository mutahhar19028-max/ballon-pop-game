showMainGameScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    call drawScorePanel
    call drawTimerPanel

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawScorePanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, SCORE_PANEL_X
    mov bx, SCORE_PANEL_Y
    mov cx, SCORE_PANEL_WIDTH + 10
    mov dx, SCORE_PANEL_HEIGHT
    mov si, SCORE_PANEL_COLOR
    mov di, SCORE_BORDER_COLOR
    call drawRoundedRect

    mov cx, SCORE_TEXT_X
    mov dx, SCORE_TEXT_Y
    mov si, score_label
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    call drawScoreValue

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawScoreValue:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    sub sp, 5
    mov bp, sp

    mov ax, [current_score]

    mov cx, 1000
    xor dx, dx
    div cx
    add al, '0'
    mov [bp], al

    mov ax, dx
    mov cx, 100
    xor dx, dx
    div cx
    add al, '0'
    mov [bp+1], al

    mov ax, dx
    mov cx, 10
    xor dx, dx
    div cx
    add al, '0'
    mov [bp+2], al

    mov al, dl
    add al, '0'
    mov [bp+3], al

    mov byte [bp+4], 0

    mov cx, SCORE_VALUE_X - 14
    mov dx, SCORE_VALUE_Y - 2
    mov si, bp
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    add sp, 5
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawTimerPanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, TIMER_PANEL_X
    mov bx, TIMER_PANEL_Y
    mov cx, TIMER_PANEL_WIDTH
    mov dx, TIMER_PANEL_HEIGHT
    mov si, TIMER_PANEL_COLOR
    mov di, TIMER_BORDER_COLOR
    call drawRoundedRect

    mov cx, TIMER_TEXT_X
    mov dx, TIMER_TEXT_Y
    mov si, timer_label_text
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    call drawTimerValue

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

timer_label_text    db "TIME: ", 0

drawTimerValue:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    sub sp, 6
    mov bp, sp

    xor ah, ah
    mov al, [timer_minutes]
    mov bl, 10
    div bl
    add al, '0'
    mov [bp], al
    
    mov al, ah
    add al, '0'
    mov [bp+1], al

    mov byte [bp+2], ':'

    xor ah, ah
    mov al, [timer_display_sec]
    mov bl, 10
    div bl
    add al, '0'
    mov [bp+3], al

    mov al, ah
    add al, '0'
    mov [bp+4], al

    mov byte [bp+5], 0

    mov cx, TIMER_VALUE_X
    mov dx, TIMER_VALUE_Y
    mov si, bp
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    add sp, 6

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawSoundButton:
    push ax
    push bx
    push cx
    push dx

    mov ax, SOUND_BTN_X
    mov bx, SOUND_BTN_Y
    mov cx, SOUND_BTN_RADIUS
    mov dl, SOUND_BTN_COLOR
    call drawCircleFilled

    mov ax, SOUND_BTN_X
    mov bx, SOUND_BTN_Y
    add ax, 2
    call drawSpeakerIcon

    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawPauseButton:
    push ax
    push bx
    push cx
    push dx

    mov ax, PAUSE_BTN_X
    mov bx, PAUSE_BTN_Y
    mov cx, PAUSE_BTN_RADIUS
    mov dl, PAUSE_BTN_COLOR
    call drawCircleFilled

    mov ax, PAUSE_BTN_X
    mov bx, PAUSE_BTN_Y
    add ax, 2
    call drawPauseIcon

    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawSpeakerIcon:
    push ax
    push bx
    push cx
    push dx
    push si

    sub ax, 6
    sub bx, 4
    mov cx, 5
    mov dx, 8
    mov si, PAUSE_BTN_BORDER
    call drawFilledRect
    
    add ax, 8
    add bx, 2
    mov cx, 2
    mov dx, 4
    mov si, PAUSE_BTN_BORDER
    call drawFilledRect

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawPauseIcon:
    push ax
    push bx
    push cx
    push dx
    push si

    sub ax, 6
    sub bx, 6
    mov cx, 3
    mov dx, 12
    mov si, PAUSE_BTN_BORDER
    call drawFilledRect
    
    add ax, 6
    mov cx, 3
    mov dx, 12
    mov si, PAUSE_BTN_BORDER
    call drawFilledRect

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
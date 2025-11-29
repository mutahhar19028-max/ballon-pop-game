; ------------------------------------------------------------
; PUBLIC: drawGameUI
; ------------------------------------------------------------
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
    call drawSoundButton
    call drawPauseButton
    call drawSampleBalloons

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawScorePanel
; ------------------------------------------------------------
drawScorePanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, SCORE_PANEL_X
    mov bx, SCORE_PANEL_Y
    mov cx, SCORE_PANEL_WIDTH
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

    ;mov ax, SCORE_VALUE_X
    ;mov bx, SCORE_VALUE_Y
    ;mov dx, [current_score]
    ;mov cl, [bold_leaves_green]
    ;call drawNumber

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawTimerPanel
; ------------------------------------------------------------
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
    mov si, timer_label
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    ;mov ax, TIMER_VALUE_X
    ;mov bx, TIMER_VALUE_Y
    ;call drawTimerValue

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSoundButton
; ------------------------------------------------------------
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


; ------------------------------------------------------------
; drawPauseButton
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawTimerValue
; ------------------------------------------------------------
drawTimerValue:
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, ax
    
    mov al, [current_minutes]
    xor ah, ah
    mov dl, [bold_leaves_green]
    ;call drawDigit
    
    add si, 8
    mov ax, si
    mov al, [current_minutes]
    xor ah, ah
    mov cl, 10
    xor ah, ah
    div cl
    mov al, ah
    mov dl, [bold_leaves_green]
    ;call drawDigit
    
    add si, 8
    mov ax, si
    add ax, 2
    add bx, 2
    mov cx, 2
    mov dx, 2
    push si
    mov si, [bold_leaves_green]
    call drawFilledRect
    pop si
    add bx, 3
    mov ax, si
    add ax, 2
    mov cx, 2
    mov dx, 2
    push si
    mov si, [bold_leaves_green]
    call drawFilledRect
    pop si
    sub bx, 5
    
    add si, 10
    mov ax, si
    mov al, [current_seconds]
    xor ah, ah
    mov cl, 10
    div cl
    mov dl, [bold_leaves_green]
    ;call drawDigit
    
    add si, 8
    mov ax, si
    mov al, [current_seconds]
    xor ah, ah
    mov cl, 10
    div cl
    mov al, ah
    mov dl, [white]
    ;call drawDigit

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSpeakerIcon
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawPauseIcon
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawBalloon
; ------------------------------------------------------------
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
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cl
    mov [bp-8], dl

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 15
    mov cx, 15
    mov dl, byte [bp-6]
    call drawCircleFilled

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 15
    mov cx, 15
    mov dl, [bold_leaves_green]
    call drawCircleOutline

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 30
    mov cx, 3
    mov dx, 2
    mov si, [bp-6]
    call drawFilledRect

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 32
    mov dx, BALLOON_STRING_LEN
    mov si, [bold_leaves_green]
    call drawVerticalLine

    mov ax, [bp-2]
    sub ax, 4
    mov bx, [bp-4]
    add bx, 12
    mov al, byte [bp-8]
    cmp al, '0'
    jb .draw_as_char
    cmp al, '9'
    ja .draw_as_char
    
    sub al, '0'
    mov dl, [bold_leaves_green]
    ;call drawDigit
    jmp .done

.draw_as_char:
    mov cx, [bp-2]
    mov dx, [bp-4]
    mov bh, 1
    mov bl, [bp-6]
    mov si, [bp-8]
    call drawText

.done:
    add sp, 8
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSampleBalloons
; ------------------------------------------------------------
drawSampleBalloons:
    push ax
    push bx
    push cx
    push dx

    mov ax, 80
    mov bx, 100
    mov cl, [white]
    mov dl, '1'
    call drawBalloon

    mov ax, 130
    mov bx, 140
    mov cl, [light_blue]
    mov dl, '2'
    call drawBalloon

    mov ax, 200
    mov bx, 70
    mov cl, [bright_cyan]
    mov dl, '3'
    call drawBalloon

    mov ax, 260
    mov bx, 110
    mov cl, [bright_yellow]
    mov dl, '4'
    call drawBalloon

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================================
; END OF main_game_screen.asm
; ============================================================
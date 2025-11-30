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
    ; NOTE: Balloons now drawn by balloon system, not here

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
    mov cx, SCORE_PANEL_WIDTH + 8
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

; ------------------------------------------------------------
; PUBLIC: drawScoreValue
; Draws the current score at defined position
; Called by drawScorePanel
; ------------------------------------------------------------
drawScoreValue:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    ; Allocate 5 bytes for "0000\0"
    sub sp, 5
    mov bp, sp          ; BP points to buffer

    mov ax, [current_score]  ; AX = current score

    ; --- Thousands digit ---
    mov cx, 1000
    xor dx, dx
    div cx                  ; AX / 1000 -> AX = quotient in AL, DX = remainder
    add al, '0'
    mov [bp], al            ; store thousands digit

    ; --- Hundreds digit ---
    mov ax, dx               ; remainder from thousands division
    mov cx, 100
    xor dx, dx
    div cx                   ; AX / 100 -> AL = hundreds, DX = remainder
    add al, '0'
    mov [bp+1], al

    ; --- Tens digit ---
    mov ax, dx               ; remainder from hundreds
    mov cx, 10
    xor dx, dx
    div cx                   ; AX / 10 -> AL = tens, DX = ones
    add al, '0'
    mov [bp+2], al

    ; --- Ones digit ---
    mov al, dl               ; remainder from tens division
    add al, '0'
    mov [bp+3], al

    ; --- Null terminator ---
    mov byte [bp+4], 0

    ; Draw score string
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

;; ------------------------------------------------------------
; drawTimerPanel
; Draws timer panel with dynamic time display
; ------------------------------------------------------------
drawTimerPanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Draw panel background
    mov ax, TIMER_PANEL_X
    mov bx, TIMER_PANEL_Y
    mov cx, TIMER_PANEL_WIDTH
    mov dx, TIMER_PANEL_HEIGHT
    mov si, TIMER_PANEL_COLOR
    mov di, TIMER_BORDER_COLOR
    call drawRoundedRect

    ; Draw "TIME:" label
    mov cx, TIMER_TEXT_X
    mov dx, TIMER_TEXT_Y
    mov si, timer_label_text
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    ; Draw dynamic timer value (MM:SS)
    call drawTimerValue

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Timer label text (just "TIME:")
timer_label_text    db "TIME:", 0

; ------------------------------------------------------------
; drawTimerValue
; Draws the current timer value in MM:SS format
; Called every frame by drawTimerPanel
; Reads current values from timer_minutes and timer_display_sec
; These variables are updated by the timer ISR (once per second)
; ------------------------------------------------------------
drawTimerValue:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    ; Allocate 6 bytes on stack for timer string "MM:SS\0"
    sub sp, 6
    mov bp, sp              ; BP points to buffer

    ; Build "MM:SS" string from current timer values
    ; --- Minutes tens digit ---
    xor ah, ah
    mov al, [timer_minutes]
    mov bl, 10
    div bl                  ; AL = tens, AH = ones
    add al, '0'             ; Convert to ASCII
    mov [bp], al            ; Store tens digit
    
    ; --- Minutes ones digit ---
    mov al, ah              ; Get ones from AH
    add al, '0'
    mov [bp+1], al

    ; --- Colon separator ---
    mov byte [bp+2], ':'

    ; --- Seconds tens digit ---
    xor ah, ah
    mov al, [timer_display_sec]
    mov bl, 10
    div bl                  ; AL = tens, AH = ones
    add al, '0'
    mov [bp+3], al

    ; --- Seconds ones digit ---
    mov al, ah
    add al, '0'
    mov [bp+4], al

    ; --- Null terminator ---
    mov byte [bp+5], 0

    ; Draw the timer string at defined position
    mov cx, TIMER_VALUE_X
    mov dx, TIMER_VALUE_Y
    mov si, bp              ; SI points to our string buffer
    mov bl, [dark_brown]    ; Text color
    mov bh, 1              ; Scale (2 = medium size)
    call drawText

    ; Clean up stack
    add sp, 6

    pop bp
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

; ============================================================
; END OF main_game_screen.asm
; ============================================================
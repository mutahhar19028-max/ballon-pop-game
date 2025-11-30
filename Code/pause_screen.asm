; ============================================================
; pause_screen.asm — All pause screen logic, drawing & input
; ============================================================
; PUBLIC: showPauseScreen
; Draws pause overlay and handles input
showPauseScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    ; DS = CS for data access
    push cs
    pop ds

    mov word [DIST], 0

.pause_input_loop:
    ; Draw complete pause screen
    call drawPausePanel
    call drawPauseTitle
    call drawPauseMenu

    ; Clear keyboard buffer
.clear_buffer:
    mov ah, 0x01
    int 0x16
    jz .buffer_clear
    mov ah, 0x00
    int 0x16
    jmp .clear_buffer
.buffer_clear:

    ; Wait for key
    mov ah, 0x00
    int 0x16              ; AL = ASCII, AH = scan

    ; Check ASCII codes
    cmp al, 27            ; ESC
    je .action_resume
    cmp al, 'r'            
    je .action_retry
    cmp al, 'R'            
    je .action_retry
    cmp al, 'q'            
    je .action_mainmenu
    cmp al, 'Q'
    je .action_mainmenu

    jmp .pause_input_loop

.action_resume:
    call resumeTimer
    mov byte [game_state], STATE_GAME
    call showBackground320x200
    jmp game_loop

.action_retry:
    call resetTimer
    mov byte [timer_active], 1
    mov word [current_score], 0
    call initBalloonSystem
    mov byte [game_state], STATE_GAME
    call showBackground320x200
    jmp game_loop

.action_mainmenu:
    call restoreTimerISR
    mov byte [timer_active], 0
    mov byte [game_state], STATE_MENU   
    call showBackground320x200
    jmp game_loop

; ============================================================
; EXISTING DRAW ROUTINES (UNCHANGED)
; ============================================================

drawPausePanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, PAUSE_PANEL_X
    mov bx, PAUSE_PANEL_Y
    mov cx, PAUSE_PANEL_WIDTH
    mov dx, PAUSE_PANEL_HEIGHT
    mov si, PAUSE_PANEL_COLOR
    call drawRoundedRect

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawPauseTitle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov cx, 110
    mov dx, 50
    mov si, pause_title
    mov bl, PAUSE_TITLE_COLOR
    mov bh, 2
    call drawText

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawPauseMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, PAUSE_MENU_BUTTON_X
    mov bx, PAUSE_MENU_BUTTON_Y
    add bx, [DIST]
    mov cx, PAUSE_MENU_BUTTON_WIDTH
    mov dx, PAUSE_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect

    ; --- RESUME TEXT ---
    mov ax, PAUSE_MENU_BUTTON_X
    add ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, PAUSE_MENU_BUTTON_Y + 1
    add ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add ax, [DIST]
    mov dx, ax
    mov si, menu_resume
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText

    call updatePadd

    ; --- RESTART BUTTON ---
    mov ax, PAUSE_MENU_BUTTON_X
    mov bx, PAUSE_MENU_BUTTON_Y
    add bx, [DIST]
    mov cx, PAUSE_MENU_BUTTON_WIDTH
    mov dx, PAUSE_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect
    mov ax, PAUSE_MENU_BUTTON_X + 1
    add ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, PAUSE_MENU_BUTTON_Y + 1
    add ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add ax, [DIST]
    mov dx, ax
    mov si, menu_restart
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText

    call updatePadd

    ; --- QUIT BUTTON ---
    mov ax, PAUSE_MENU_BUTTON_X
    mov bx, PAUSE_MENU_BUTTON_Y
    add bx, [DIST]
    mov cx, PAUSE_MENU_BUTTON_WIDTH
    mov dx, PAUSE_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect
    mov ax, PAUSE_MENU_BUTTON_X
    add ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, PAUSE_MENU_BUTTON_Y + 1
    add ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add ax, [DIST]
    mov dx, ax
    mov si, menu_quit
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

updatePadd:
    mov ax, [DIST]
    add ax, PAUSE_MENU_BUTTON_HEIGHT
    add ax, PAUSE_MENU_BUTTON_HEIGHT / 2
    mov [DIST], ax
    ret

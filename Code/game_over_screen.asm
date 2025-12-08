showGameOverScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    push cs
    pop ds

    mov word [DIS], 0
    mov byte [go_selection], 0

    call drawGameOverPanel
    call drawGameOverTitle
    call drawGameOverStats
    call drawGameOverMenu

.input_loop:
    call drawGameOverArrow

    mov ah, 0x00
    int 0x16

    cmp ah, 0x48
    je .move_up
    cmp ah, 0x50
    je .move_down
    cmp ah, 0x1C
    je .confirm_selection

    cmp al, 'r'
    je .trigger_retry
    cmp al, 'R'
    je .trigger_retry
    cmp al, 'q'
    je .trigger_quit
    cmp al, 'Q'
    je .trigger_quit

    jmp .input_loop

.move_up:
    call clearGameOverArrow
    mov byte [go_selection], 0
    jmp .input_loop

.move_down:
    call clearGameOverArrow
    mov byte [go_selection], 1
    jmp .input_loop

.confirm_selection:
    cmp byte [go_selection], 0
    je .trigger_retry
    jmp .trigger_quit

.trigger_retry:
    call showBackground320x200
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1
    mov word [current_score], 0
    call initBalloonSystem
    
    mov byte [game_state], STATE_GAME
    
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp game_loop

.trigger_quit:
    call showBackground320x200
    call restoreTimerISR
    mov byte [timer_active], 0
    
    mov byte [game_state], STATE_MENU
    
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp game_loop

drawGameOverPanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov ax, GAMEOVER_PANEL_X
    mov bx, GAMEOVER_PANEL_Y
    mov cx, GAMEOVER_PANEL_WIDTH
    mov dx, GAMEOVER_PANEL_HEIGHT
    mov si, GAMEOVER_PANEL_COLOR
    call drawRoundedRect

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawGameOverTitle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov cx, 97
    mov dx, 32
    mov si, gameover_title
    mov bl, GAMEOVER_TITLE_COLOR
    mov bh, 2
    call drawText

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawGameOverStats:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, GAMEOVER_MENU_BUTTON_X
    mov bx, GAMEOVER_MENU_BUTTON_Y
    add bx, [DIS]
    mov cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect

    mov ax, GAMEOVER_MENU_BUTTON_X - 1
    add ax, GAMEOVER_MENU_BUTTON_WIDTH / 8 + 2
    mov cx, ax
    mov ax, GAMEOVER_PANEL_Y
    add ax, GAMEOVER_PANEL_HEIGHT / 3
    add ax, [DIS]
    mov dx, ax

    push cx
    push dx
    mov si, stats_score_label
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText
    pop dx
    pop cx

    call updatePad

    mov ax, GAMEOVER_MENU_BUTTON_X
    mov bx, GAMEOVER_MENU_BUTTON_Y
    add bx, [DIS]
    mov cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect

    mov ax, GAMEOVER_MENU_BUTTON_X + 1
    add ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, GAMEOVER_PANEL_Y
    add ax, GAMEOVER_PANEL_HEIGHT / 3
    add ax, [DIS]
    mov dx, ax

    push cx
    push dx
    mov si, stats_time_label
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText
    pop dx
    pop cx

    add cx, 60
    call drawFinalTime

    call updatePad

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawGameOverMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, GAMEOVER_MENU_BUTTON_X
    mov bx, GAMEOVER_MENU_BUTTON_Y
    add bx, [DIS]
    mov cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect

    mov ax, GAMEOVER_MENU_BUTTON_X + 3
    add ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, GAMEOVER_MENU_BUTTON_Y + 1
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT / 4
    add ax, [DIS]
    mov dx, ax

    mov si, menu_retry
    mov bl, [bright_yellow]
    mov bh, 1
    call drawText

    call updatePad

    mov ax, GAMEOVER_MENU_BUTTON_X
    mov bx, GAMEOVER_MENU_BUTTON_Y
    add bx, [DIS]
    mov cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov si, [dark_brown]
    call drawRoundedRect

    mov ax, GAMEOVER_MENU_BUTTON_X
    add ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov cx, ax
    mov ax, GAMEOVER_MENU_BUTTON_Y + 1
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT / 4
    add ax, [DIS]
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

updatePad:
    mov ax, [DIS]
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT / 2
    mov [DIS], ax
    ret

drawGameOverArrow:
    push ax
    push bx
    push cx
    push dx

    mov dx, GAMEOVER_MENU_BUTTON_Y
    add dx, 8

    mov ax, GAMEOVER_MENU_BUTTON_HEIGHT
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT / 2
    
    add dx, ax
    add dx, ax 

    cmp byte [go_selection], 0
    je .draw_it
    
    add dx, ax

.draw_it:
    mov cx, GAMEOVER_MENU_BUTTON_X - 15
    mov bl, [dark_brown]
    call drawSelectionArrow

    pop dx
    pop cx
    pop bx
    pop ax
    ret

clearGameOverArrow:
    push ax
    push bx
    push cx
    push dx

    mov dx, GAMEOVER_MENU_BUTTON_Y
    add dx, 8
    
    mov ax, GAMEOVER_MENU_BUTTON_HEIGHT
    add ax, GAMEOVER_MENU_BUTTON_HEIGHT / 2
    
    add dx, ax
    add dx, ax 

    cmp byte [go_selection], 0
    je .erase_it
    add dx, ax

.erase_it:
    mov cx, GAMEOVER_MENU_BUTTON_X - 15
    mov bl, [light_orange]
    call drawSelectionArrow

    pop dx
    pop cx
    pop bx
    pop ax
    ret

drawFinalScore:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    sub sp, 6
    mov bp, sp
    mov si, bp

    mov ax, [final_score]
    
    mov cx, 1000
    xor dx, dx
    div cx
    add al, '0'
    mov [si], al
    inc si
    mov ax, dx

    mov cx, 100
    xor dx, dx
    div cx
    add al, '0'
    mov [si], al
    inc si
    mov ax, dx

    mov cx, 10
    xor dx, dx
    div cx
    add al, '0'
    mov [si], al
    inc si

    add dl, '0'
    mov [si], dl
    inc si
    mov byte [si], 0

    mov si, bp
    mov bl, [bright_yellow]
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

drawFinalTime:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    sub sp, 6
    mov bp, sp
    mov si, bp

    xor ah, ah
    mov al, [final_minutes]
    mov bl, 10
    div bl
    add al, '0'
    mov [si], al
    inc si
    add ah, '0'
    mov [si], ah
    inc si

    mov byte [si], ':'
    inc si

    xor ah, ah
    mov al, [final_seconds]
    mov bl, 10
    div bl
    add al, '0'
    mov [si], al
    inc si
    add ah, '0'
    mov [si], ah
    inc si

    mov byte [si], 0

    mov si, bp
    mov bl, [bright_yellow]
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

go_selection: db 0
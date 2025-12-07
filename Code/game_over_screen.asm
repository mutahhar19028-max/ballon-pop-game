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

.pause_loop:
    call drawGameOverPanel
    call drawGameOverStats
    call drawGameOverTitle
    call drawGameOverMenu

    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

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

    mov  cx, 90
    mov  dx, 32
    mov  si, gameover_title
    mov  bl, GAMEOVER_TITLE_COLOR
    mov  bh, 2
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

    mov  ax, GAMEOVER_MENU_BUTTON_X
    mov  bx, GAMEOVER_MENU_BUTTON_Y
    add  bx, [DIS]
    mov  cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov  dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    mov  ax, GAMEOVER_MENU_BUTTON_X - 1
    add  ax, GAMEOVER_MENU_BUTTON_WIDTH / 8 + 2
    mov  cx, ax

    mov  ax, GAMEOVER_PANEL_Y
    add  ax, GAMEOVER_PANEL_HEIGHT / 3
    add  ax, [DIS]
    mov  dx, ax

    mov  si, stats_score_label
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

    call updatePad

    mov  ax, GAMEOVER_MENU_BUTTON_X
    mov  bx, GAMEOVER_MENU_BUTTON_Y
    add  bx, [DIS]
    mov  cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov  dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    mov  ax, GAMEOVER_MENU_BUTTON_X + 1
    add  ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, GAMEOVER_PANEL_Y
    add  ax, GAMEOVER_PANEL_HEIGHT / 3
    add  ax, [DIS]
    mov  dx, ax

    mov  si, stats_time_label
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

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

    mov  ax, GAMEOVER_MENU_BUTTON_X
    mov  bx, GAMEOVER_MENU_BUTTON_Y
    add  bx, [DIS]
    mov  cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov  dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    mov  ax, GAMEOVER_MENU_BUTTON_X + 3
    add  ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, GAMEOVER_MENU_BUTTON_Y + 1
    add  ax, GAMEOVER_MENU_BUTTON_HEIGHT / 4
    add  ax, [DIS]
    mov  dx, ax

    mov  si, menu_retry
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

    call updatePad

    mov  ax, GAMEOVER_MENU_BUTTON_X
    mov  bx, GAMEOVER_MENU_BUTTON_Y
    add  bx, [DIS]
    mov  cx, GAMEOVER_MENU_BUTTON_WIDTH
    mov  dx, GAMEOVER_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    mov  ax, GAMEOVER_MENU_BUTTON_X
    add  ax, GAMEOVER_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, GAMEOVER_MENU_BUTTON_Y + 1
    add  ax, GAMEOVER_MENU_BUTTON_HEIGHT / 4
    add  ax, [DIS]
    mov  dx, ax

    mov  si, menu_quit
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

updatePad:
    mov  ax, [DIS]
    add  ax, GAMEOVER_MENU_BUTTON_HEIGHT
    add  ax, GAMEOVER_MENU_BUTTON_HEIGHT / 2
    mov  [DIS], ax
    ret
drawMainMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov word[DIT], 0

    mov  cx, 50
    mov  dx, 30
    mov  si, title_text
    mov  bl, [nature_dark_green]
    mov  bh, 2
    call drawText

    mov  ax, MENU_BUTTON_X - 7
    mov  bx, MENU_BUTTON_Y - 2
    mov  cx, MENU_BUTTON_WIDTH + 15
    mov  dx, MENU_BUTTON_HEIGHT + 4
    mov  si, [dark_orange]
    mov  di, [dark_brown]
    call drawRoundedRect

    mov  ax, MENU_BUTTON_X
    add  ax, MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, MENU_BUTTON_Y
    add  ax, MENU_BUTTON_HEIGHT / 4
    mov  dx, ax

    mov  si, menu_play
    mov  bl, [dark_brown]
    mov  bh, 2
    call drawText

    call updatePadding

    mov  ax, MENU_BUTTON_X - 7
    mov  bx, MENU_BUTTON_Y - 2
    add  bx, [DIT]
    mov  cx, MENU_BUTTON_WIDTH + 15
    mov  dx, MENU_BUTTON_HEIGHT + 4
    mov  si, [dark_orange]
    mov  di, [dark_brown]
    call drawRoundedRect

    mov  ax, MENU_BUTTON_X
    add  ax, MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, MENU_BUTTON_Y
    add  ax, MENU_BUTTON_HEIGHT / 4
    add  ax, [DIT]
    mov  dx, ax

    mov  si, menu_help
    mov  bl, [dark_brown]
    mov  bh, 2
    call drawText

    call updatePadding

    mov  ax, MENU_BUTTON_X - 7
    mov  bx, MENU_BUTTON_Y - 2
    add  bx, [DIT]
    mov  cx, MENU_BUTTON_WIDTH + 15
    mov  dx, MENU_BUTTON_HEIGHT + 4
    mov  si, [dark_orange]
    mov  di, [dark_brown]
    call drawRoundedRect

    mov  ax, MENU_BUTTON_X
    add  ax, MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, MENU_BUTTON_Y
    add  ax, MENU_BUTTON_HEIGHT / 4
    add  ax, [DIT]
    mov  dx, ax

    mov  si, menu_exit
    mov  bl, [dark_brown]
    mov  bh, 2
    call drawText

    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

updatePadding:
    mov  ax, [DIT]
    add  ax, MENU_BUTTON_HEIGHT
    add  ax, MENU_BUTTON_HEIGHT / 2
    mov  [DIT], ax
    ret

DIT : dw 0
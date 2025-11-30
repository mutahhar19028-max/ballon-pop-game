; ------------------------------------------------------------
; PUBLIC: showPauseScreen
; Main entry point - displays pause overlay and handles input
; ------------------------------------------------------------
showPauseScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    ; Ensure DS = CS for data access
    push cs
    pop ds

.pause_loop:
    ; Draw complete pause screen
    call drawPausePanel
    call drawPauseTitle
    call drawPauseMenu

    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawPausePanel
; Draws main pause panel with rounded corners
; USES: drawRoundedRect from ui.asm
; ------------------------------------------------------------
drawPausePanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Main panel body
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

; ------------------------------------------------------------
; drawPauseTitle
; Draws pulsing "GAME PAUSED" title
; CALLS: drawTextCentered
; ------------------------------------------------------------
drawPauseTitle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov  cx, 110
    mov  dx, 50
    mov  si, pause_title              ; DS:SI -> title string
    mov  bl, PAUSE_TITLE_COLOR     ; color
    mov  bh, 2
    call drawText

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================================
; END OF pause_screen.asm
; ============================================================

drawPauseMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov  ax, PAUSE_MENU_BUTTON_X
    mov  bx, PAUSE_MENU_BUTTON_Y
    add  bx, [DIST]
    mov  cx, PAUSE_MENU_BUTTON_WIDTH
    mov  dx, PAUSE_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    ; --- RESUME TEXT ---
    mov  ax, PAUSE_MENU_BUTTON_X
    add  ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, PAUSE_MENU_BUTTON_Y + 1
    add  ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add  ax, [DIST]
    mov  dx, ax

    mov  si, menu_resume
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

    call updatePadd

    ; ------------------------------------------------------------
    ; RESTART BUTTON
    ; ------------------------------------------------------------
    mov  ax, PAUSE_MENU_BUTTON_X
    mov  bx, PAUSE_MENU_BUTTON_Y
    add  bx, [DIST]
    mov  cx, PAUSE_MENU_BUTTON_WIDTH
    mov  dx, PAUSE_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    ; --- RESTART TEXT ---
    mov  ax, PAUSE_MENU_BUTTON_X + 1
    add  ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, PAUSE_MENU_BUTTON_Y + 1
    add  ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add  ax, [DIST]
    mov  dx, ax

    mov  si, menu_restart
    mov  bl, [bright_yellow]
    mov  bh, 1
    call drawText

    call updatePadd

    ; ------------------------------------------------------------
    ; QUIT BUTTON
    ; ------------------------------------------------------------
    mov  ax, PAUSE_MENU_BUTTON_X
    mov  bx, PAUSE_MENU_BUTTON_Y
    add  bx, [DIST]
    mov  cx, PAUSE_MENU_BUTTON_WIDTH
    mov  dx, PAUSE_MENU_BUTTON_HEIGHT
    mov  si, [dark_brown]
    call drawRoundedRect

    ; --- QUIT TEXT ---
    mov  ax, PAUSE_MENU_BUTTON_X
    add  ax, PAUSE_MENU_BUTTON_WIDTH / 8
    mov  cx, ax

    mov  ax, PAUSE_MENU_BUTTON_Y + 1
    add  ax, PAUSE_MENU_BUTTON_HEIGHT / 4
    add  ax, [DIST]
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

; ------------------------------------------------------------
; UPDATE PADDING
; ------------------------------------------------------------
updatePadd:
    mov  ax, [DIST]
    add  ax, PAUSE_MENU_BUTTON_HEIGHT
    add  ax, PAUSE_MENU_BUTTON_HEIGHT / 2
    mov  [DIST], ax
    ret
; ============================================================
; navigation.asm — Menu Navigation System with Arrow Keys
; ============================================================

; ------------------------------------------------------------
; handleMainMenuInput
; Handles arrow key navigation and Enter selection
; RETURNS: AL = selected option (0=Play, 1=Help, 2=Exit, 0xFF=ESC)
; ------------------------------------------------------------
handleMainMenuInput:
    push bx
    push cx
    push dx

    ; Initialize selection to first option
    mov byte [current_selection], MENU_OPTION_PLAY

.input_loop:
    ; Draw arrow at current selection
    call drawMenuArrow

    ; Wait for keypress
    mov ah, 0x00
    int 0x16                ; AH=scan code, AL=ASCII

    cmp ah, KEY_UP
    je .move_up
    cmp ah, KEY_DOWN
    je .move_down
    cmp ah, KEY_ENTER
    je .select_option
    cmp ah, KEY_ESC
    je .exit_pressed
    jmp .input_loop         ; Ignore other keys

.move_up:
    ; Clear current arrow
    call clearMenuArrow
    
    ; Move selection up (with wrap-around)
    mov al, [current_selection]
    cmp al, 0
    je .wrap_to_bottom
    dec byte [current_selection]
    jmp .input_loop

.wrap_to_bottom:
    mov byte [current_selection], TOTAL_MENU_OPTIONS - 1
    jmp .input_loop

.move_down:
    ; Clear current arrow
    call clearMenuArrow
    
    ; Move selection down (with wrap-around)
    mov al, [current_selection]
    cmp al, TOTAL_MENU_OPTIONS - 1
    je .wrap_to_top
    inc byte [current_selection]
    jmp .input_loop

.wrap_to_top:
    mov byte [current_selection], 0
    jmp .input_loop

.select_option:
    call clearMenuArrow
    mov al, [current_selection]
    pop dx
    pop cx
    pop bx
    ret

.exit_pressed:
    mov al, 0xFF            ; Return special value for ESC
    pop dx
    pop cx
    pop bx
    ret

; ------------------------------------------------------------
; drawMenuArrow
; Draws '>' arrow at current selection position
; ------------------------------------------------------------
drawMenuArrow:
    push ax
    push bx
    push cx
    push dx

    ; Calculate Y position based on selection
    xor ax, ax
    mov al, [current_selection]
    mov bx, MENU_BUTTON_HEIGHT
    add bx, MENU_BUTTON_HEIGHT / 2  ; Spacing between buttons
    mul bx
    add ax, ARROW_FIRST_Y
    mov dx, ax

    ; Draw arrow
    mov cx, ARROW_X_OFFSET
    mov bl, [dark_brown]     ; Arrow color
    call drawSelectionArrow

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; clearMenuArrow
; Erases arrow at current selection (draws space in bg color)
; ------------------------------------------------------------
clearMenuArrow:
    push ax
    push bx
    push cx
    push dx

    ; Calculate Y position
    xor ax, ax
    mov al, [current_selection]
    mov bx, MENU_BUTTON_HEIGHT
    add bx, MENU_BUTTON_HEIGHT / 2
    mul bx
    add ax, ARROW_FIRST_Y
    mov dx, ax

    ; Draw space (or redraw background color)
    mov cx, ARROW_X_OFFSET
    mov bl, [char_color]     ; Background color
    call drawSelectionArrow  ; Draws space in bg color

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; executeMenuChoice
; Executes the selected menu option
; INPUT: AL = selected option (0-2)
; ------------------------------------------------------------
executeMenuChoice:
    push ax
    push bx

    cmp al, MENU_OPTION_PLAY
    je .start_game
    cmp al, MENU_OPTION_HELP
    je .show_help
    cmp al, MENU_OPTION_EXIT
    je .exit_game
    jmp .done

.start_game:
    mov byte [game_state], STATE_GAME
    call showMainGameScreen
    jmp .done

.show_help:
    ; TODO: Implement help screen
    ; For now, just show a message and return to menu
    call showHelpScreen
    mov byte [game_state], STATE_MENU
    jmp .done

.exit_game:
    mov byte [game_state], STATE_EXIT
    jmp .done

.done:
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; showHelpScreen (Placeholder)
; Shows instructions, press any key to return
; ------------------------------------------------------------
showHelpScreen:
    push ax
    push bx
    push cx
    push dx
    push si

    ; Clear screen to background
    call clearScreen

    ; Display help text
    mov cx, 40
    mov dx, 60
    mov si, help_title
    mov bl, [dark_brown]
    mov bh, 2
    call drawText

    mov cx, 30
    mov dx, 90
    mov si, help_line1
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    mov cx, 30
    mov dx, 105
    mov si, help_line2
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    mov cx, 30
    mov dx, 120
    mov si, help_line3
    mov bl, [dark_brown]
    mov bh, 1
    call drawText

    mov cx, 50
    mov dx, 150
    mov si, help_exit
    mov bl, [nature_dark_green]
    mov bh, 1
    call drawText

    ; Wait for keypress
    mov ah, 0x00
    int 0x16

    ; Redraw background and menu
    call showBackground320x200
    call drawMainMenu

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Help screen text
help_title:     db "HOW TO PLAY", 0
help_line1:     db "Type letters on balloons", 0
help_line2:     db "Pop balloons for points", 0
help_line3:     db "2 minutes to play!", 0
help_exit:      db "Press any key...", 0
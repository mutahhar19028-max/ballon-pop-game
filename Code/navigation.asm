; ============================================================
; navigation.asm — Menu Navigation System with Arrow Keys
; ============================================================
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
handleMainMenuInput:
    push bx
    push cx
    push dx

    mov byte [current_selection], MENU_OPTION_PLAY

.input_loop:
    call drawMenuArrow

    mov ah, 0x00
    int 0x16            ; wait key

    cmp ah, KEY_UP
    je .move_up
    cmp ah, KEY_DOWN
    je .move_down
    cmp ah, KEY_ENTER
    je .select_option
    cmp ah, KEY_ESC
    je .exit_pressed
    jmp .input_loop

.move_up:
    call clearMenuArrow
    mov al, [current_selection]
    cmp al, 0
    je .wrap_bottom
    dec byte [current_selection]
    jmp .input_loop

.wrap_bottom:
    mov byte [current_selection], TOTAL_MENU_OPTIONS - 1
    jmp .input_loop

.move_down:
    call clearMenuArrow
    mov al, [current_selection]
    cmp al, TOTAL_MENU_OPTIONS - 1
    je .wrap_top
    inc byte [current_selection]
    jmp .input_loop

.wrap_top:
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
    mov al, 0xFF
    pop dx
    pop cx
    pop bx
    ret


; ------------------------------------------------------------
; executeMenuChoice — ONLY CHANGES STATE
; ------------------------------------------------------------
executeMenuChoice:
    cmp al, MENU_OPTION_PLAY
    je .start

    cmp al, MENU_OPTION_HELP
    je .help

    cmp al, MENU_OPTION_EXIT
    je .exit

    ret

.start:
    mov byte [game_state], STATE_GAME
    ret

.help:
    mov byte [game_state], STATE_HELP
    ret

.exit:
    mov byte [game_state], STATE_EXIT
    ret


; ------------------------------------------------------------
; showHelpScreen — Show instructions, wait for key
; DOES NOT DRAW BG, DOES NOT RETURN TO MENU - ONLY CHANGES STATE
; ------------------------------------------------------------
showHelpScreen:

    ; Draw help text normally
    call clearScreen
    
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

    

    mov ah, 0x00
    int 0x16        ; Wait for key

    mov byte [game_state], STATE_MENU ; only change state
    ret

; Help screen text
help_title:     db "HOW TO PLAY", 0
help_line1:     db "Type letters on balloons", 0
help_line2:     db "Pop balloons for points", 0
help_line3:     db "2 minutes to play!", 0
help_exit:      db "Press any key...", 0
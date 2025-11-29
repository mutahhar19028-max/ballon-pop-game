; mainRunner.asm — Entrypoint for VGA 320x200 mode
[BITS 16]
[ORG 0x100]

jmp start

%include "Code\font.asm"
%include "Code\colors.asm"
%include "Code\ui.asm"
%include "Code\constants.asm"
%include "Code\timer.asm"           ; Timer system
%include "Code\sound.asm"
%include "Code\show_bg.asm"
%include "Code\navigation.asm"
%include "Code\main_menu.asm"
%include "Code\main_game_screen.asm"
%include "Code\pause_screen.asm"
%include "Code\game_over_screen.asm"

; --------------------------------------------------------------------------
; PROGRAM ENTRY
; --------------------------------------------------------------------------
start:
    ; Set VGA 320x200x256 mode
    mov ax, 0x0013
    int 0x10

    ; Ensure palette/background first-call behavior:
    ; If your show_bg.asm uses a palette flag, the first call will load palette.
    mov byte [game_state], STATE_MENU

;; --------------------------------------------------------------------------
; MAIN GAME LOOP (single unified frame pipeline)
;; --------------------------------------------------------------------------
game_loop:

    ; 1) Always clear / draw background at top of frame
    call showBackground320x200

    ; 2) Decide state
    mov al, [game_state]

    cmp al, STATE_MENU
    je .state_menu

    cmp al, STATE_GAME
    je .state_game

    cmp al, STATE_PAUSE
    je .state_pause

    cmp al, STATE_GAMEOVER
    je .state_gameover

    cmp al, STATE_HELP
    je .state_help

    cmp al, STATE_EXIT
    je .exit_program

    jmp game_loop


; ---------------------- MENU -------------------------
.state_menu:
    ; draw menu UI (background already drawn)
    call drawMainMenu

    ; this function blocks waiting for menu input and returns AL
    call handleMainMenuInput

    cmp al, 0xFF         ; ESC pressed
    je .exit_program

    ; only change state (and possibly set up) inside executeMenuChoice
    call executeMenuChoice

    ; Return to main loop so next frame draws the appropriate state.
    jmp game_loop


; ---------------------- GAME -------------------------
.state_game:
    ; install timer ISR IF NOT already active
    mov al, [timer_active]
    cmp al, 1
    je .enter_game_draw
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

.enter_game_draw:
    ; Each frame: check timer expiry first
    call isTimerExpired
    cmp al, 1
    je .game_time_up

    ; Draw in-game UI (background already done)
    call showMainGameScreen

    ; Non-blocking keyboard check
    mov ah, 01h
    int 16h
    jz .game_tick_end          ; no key available this frame

    mov ah, 00h                ; read key
    int 16h

    cmp ah, KEY_ESC
    je .pause_from_game

    ; handle other keys: letter popping etc.
    ; (example placeholder)
    ; cmp al, 'A'
    ; je .handle_letter_A

.game_tick_end:
    ; small frame delay (optional)
    call screenDelay

    jmp .state_game


.pause_from_game:
    ; Stop or pause timer counting when pausing (implementation-dependent)
    call pauseTimer            ; if you prefer to fully restore, use restoreTimerISR + mark inactive
    mov byte [game_state], STATE_PAUSE
    jmp game_loop


.game_time_up:
    ; Save final score if needed
    mov ax, [current_score]
    mov [final_score], ax

    ; Restore timer ISR and mark inactive
    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_GAMEOVER
    jmp game_loop


; ---------------------- PAUSE ------------------------
.state_pause:
    ; Draw pause UI (background already drawn)
    call showPauseScreen

    ; Wait for single keypress (blocking for pause screen)
    mov ah, 00h
    int 16h

    cmp ah, KEY_ESC         ; Resume
    je .resume_from_pause
    cmp al, 'r'             ; Restart
    je .restart_game
    cmp al, 'R'
    je .restart_game
    cmp al, 'q'             ; Quit to menu
    je .quit_to_menu_from_pause
    cmp al, 'Q'
    je .quit_to_menu_from_pause

    ; No valid key: stay in pause state, redraw pause screen
    jmp .state_pause

.resume_from_pause:
    ; If you fully restored ISR when pausing, re-install it here.
    ;; If pauseTimer simply stops counting, resumeTimer will continue.
    call resumeTimer
    mov byte [game_state], STATE_GAME
    jmp game_loop

.restart_game:
    ; Ensure we reset timer ISR correctly
    call restoreTimerISR      ; clear old ISR if present
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

    mov word [current_score], 0
    mov byte [game_state], STATE_GAME
    jmp game_loop

.quit_to_menu_from_pause:
    ; restore timer if active
    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_MENU
    jmp game_loop


; ---------------- Game Over ------------------
.state_gameover:
    call showGameOverScreen

    ; Wait for input
    mov ah, 00h
    int 16h

    cmp al, 'r'
    je .retry
    cmp al, 'R'
    je .retry
    cmp al, 'q'
    je .quit_to_menu
    cmp al, 'Q'
    je .quit_to_menu

    jmp .state_gameover

.retry:
    ; ensure timer is setup fresh when we re-enter game
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

    mov byte [game_state], STATE_GAME
    jmp game_loop

.quit_to_menu:
    ; ensure timer is stopped
    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_MENU
    jmp game_loop


; ---------------- HELP ------------------
.state_help:
    ; showHelpScreen draws help and waits. It should return control here.
    call showHelpScreen
    mov byte [game_state], STATE_MENU
    jmp game_loop


; ---------------- EXIT ------------------
.exit_program:
    ; Only restore timer if active
    mov al, [timer_active]
    cmp al, 1
    jne .skip_restore
    call restoreTimerISR
    mov byte [timer_active], 0

.skip_restore:
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

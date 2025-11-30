; mainRunner.asm — Entrypoint for VGA 320x200 mode
[BITS 16]
[ORG 0x100]

jmp start

%include "Code\font.asm"
%include "Code\colors.asm"
%include "Code\ui.asm"
%include "Code\constants.asm"
%include "Code\timer.asm"
%include "Code\sound.asm"
%include "Code\show_bg.asm"
%include "Code\navigation.asm"
%include "Code\main_menu.asm"
%include "Code\main_game_screen.asm"
%include "Code\pause_screen.asm"
%include "Code\game_over_screen.asm"
%include "Code\balloon_system.asm" 
%include "Code\balloon.asm"

; --------------------------------------------------------------------------
; PROGRAM ENTRY
; --------------------------------------------------------------------------
start:
    ; Set VGA 320x200x256 mode
    mov ax, 0x0013
    int 0x10

    mov byte [game_state], STATE_MENU

    call showBackground320x200

; --------------------------------------------------------------------------
; MAIN GAME LOOP (single unified frame pipeline)
; --------------------------------------------------------------------------
game_loop:

    ; 1) Decide state
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
    call drawMainMenu
    call handleMainMenuInput

    cmp al, 0xFF
    je .exit_program

    call executeMenuChoice
    jmp game_loop


; ---------------------- GAME -------------------------
.state_game:
    ; Install timer ISR IF NOT already active
    mov al, [timer_active]
    cmp al, 1
    je .enter_game_draw
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

    call showMainGameScreen
    call initBalloonSystem        

.enter_game_draw:
    ; Check timer expiry first
    call isTimerExpired
    cmp al, 1
    je .game_time_up

    ; Draw in-game UI
    call drawScorePanel
    call drawTimerPanel
    
    call updateBalloons        
    call renderBalloons       

    ; Non-blocking keyboard check
    mov ah, 01h
    int 16h
    jz .game_tick_end

    mov ah, 00h
    int 16h

    ; Handle letter input - ADDED SECTION START
    cmp al, 'a'
    jb .check_uppercase
    cmp al, 'z'
    ja .check_uppercase
    sub al, 32

.check_uppercase:
    cmp al, 'A'
    jb .check_esc
    cmp al, 'Z'
    ja .check_esc
    
    call checkBalloonHit
    cmp al, 1
    je .game_tick_end
    ; Handle letter input - ADDED SECTION END

.check_esc:
    cmp ah, KEY_ESC
    je .pause_from_game

.game_tick_end:
    call wait_vsync
    jmp .enter_game_draw


.pause_from_game:
    call pauseTimer
    mov byte [game_state], STATE_PAUSE
    call showBackground320x200
    jmp game_loop


.game_time_up:
    mov ax, [current_score]
    mov [final_score], ax

    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_GAMEOVER
    call showBackground320x200
    jmp game_loop

; ---------------------- PAUSE ------------------------
.state_pause:
    call showPauseScreen

    mov ah, 00h
    int 16h

    cmp ah, KEY_ESC
    je .resume_from_pause
    cmp al, 'r'
    je .restart_game
    cmp al, 'R'
    je .restart_game
    cmp al, 'q'
    je .quit_to_menu_from_pause
    cmp al, 'Q'
    je .quit_to_menu_from_pause

    jmp .state_pause

.resume_from_pause:
    call resumeTimer
    call showBackground320x200
    mov byte [game_state], STATE_GAME
    jmp game_loop

.restart_game:
    call restoreTimerISR
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

    mov word [current_score], 0
    call initBalloonSystem          ; <<< ADDED

    mov byte [game_state], STATE_GAME
    jmp game_loop

.quit_to_menu_from_pause:
    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_MENU
    call showBackground320x200
    jmp game_loop


; ---------------- Game Over ------------------
.state_gameover:
    call showGameOverScreen

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
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1

    mov word [current_score], 0
    call initBalloonSystem          ; <<< ADDED

    mov byte [game_state], STATE_GAME
    jmp game_loop

.quit_to_menu:
    call restoreTimerISR
    mov byte [timer_active], 0

    mov byte [game_state], STATE_MENU
    jmp game_loop


; ---------------- HELP ------------------
.state_help:
    call showHelpScreen
    mov byte [game_state], STATE_MENU
    jmp game_loop


; ---------------- EXIT ------------------
.exit_program:
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
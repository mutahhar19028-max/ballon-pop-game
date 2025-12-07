[BITS 16]
[ORG 0x100]

jmp start

%include "Code\font.asm"
%include "Code\colors.asm"
%include "Code\ui.asm"
%include "Code\constants.asm"
%include "Code\timer.asm"
%include "Code\sound.asm"
%include "Code\sound2.asm"
%include "Code\show_bg.asm"
%include "Code\navigation.asm"
%include "Code\main_menu.asm"
%include "Code\main_game_screen.asm"
%include "Code\pause_screen.asm"
%include "Code\game_over_screen.asm"
%include "Code\balloon_system.asm"
%include "Code\balloon.asm"

start:
    mov ax, 0x0013
    int 0x10

    mov byte [game_state], STATE_MENU
    call showBackground320x200
    call playMelody

game_loop:
    mov al, [game_state]
    cmp al, STATE_MENU
    je state_menu
    cmp al, STATE_GAME
    je state_game
    cmp al, STATE_PAUSE
    je state_pause
    cmp al, STATE_GAMEOVER
    je state_gameover
    cmp al, STATE_HELP
    je state_help
    cmp al, STATE_EXIT
    je exit_program
    jmp game_loop

state_menu:
    call drawMainMenu
    call handleMainMenuInput
    cmp al, 0xFF
    je exit_program
    call executeMenuChoice
    jmp game_loop

state_game:
    mov al, [timer_active]
    cmp al, 1
    je game_loop_draw
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1
    mov word [current_score], 0
    call showMainGameScreen
    call initBalloonSystem

game_loop_draw:
    call isTimerExpired
    cmp al, 1
    je game_time_up

    call updateBalloons
    call renderBalloons
    call drawScorePanel
    call drawTimerPanel

    mov ah, 01h
    int 16h
    jz game_tick_end

    mov ah, 00h
    int 16h

    cmp al, 'a'
    jb check_uppercase
    cmp al, 'z'
    ja check_uppercase
    sub al, 32

check_uppercase:
    cmp al, 'A'
    jb check_esc
    cmp al, 'Z'
    ja check_esc
    
    call checkBalloonHit
    cmp al, 1
    je game_tick_end

check_esc:
    cmp ah, KEY_ESC
    je pause_from_game

game_tick_end:
    call wait_vsync
    jmp game_loop_draw

pause_from_game:
    call pauseTimer
    mov byte [game_state], STATE_PAUSE
    call showBackground320x200
    jmp game_loop

game_time_up:
    mov ax, [current_score]
    mov [final_score], ax
    call restoreTimerISR
    mov byte [timer_active], 0
    mov byte [game_state], STATE_GAMEOVER
    call showBackground320x200
    jmp game_loop

state_pause:
    call showPauseScreen
    jmp game_loop

state_gameover:
    call showGameOverScreen
    mov ah, 00h
    int 16h
    cmp al, 'r'
    je retry
    cmp al, 'R'
    je retry
    cmp al, 'q'
    je quit_to_menu
    cmp al, 'Q'
    je quit_to_menu
    jmp state_gameover

retry:
    call installTimerISR
    call resetTimer
    mov byte [timer_active], 1
    mov word [current_score], 0
    call initBalloonSystem
    mov byte [game_state], STATE_GAME
    jmp game_loop

quit_to_menu:
    call restoreTimerISR
    mov byte [timer_active], 0
    mov byte [game_state], STATE_MENU
    jmp game_loop

state_help:
    call showHelpScreen
    mov byte [game_state], STATE_MENU
    jmp game_loop

exit_program:
    cmp byte [timer_active], 1
    jne skip_restore
    call restoreTimerISR
    mov byte [timer_active], 0
skip_restore:
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

BTN_RESUME      equ 0
BTN_MAINMENU    equ 1
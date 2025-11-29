; mainRunner.asm — Entrypoint for VGA 320x200 mode
[BITS 16]
[ORG 0x100]

jmp start

%include "Code\font.asm"
%include "Code\colors.asm"
%include "Code\ui.asm"
%include "Code\constants.asm"  
%include "Code\sound.asm"
%include "Code\show_bg.asm"
%include "Code\navigation.asm"      ; NEW: Navigation system
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

    ; Initialize game state
    mov byte [game_state], STATE_MENU

; --------------------------------------------------------------------------
; MAIN GAME LOOP
; --------------------------------------------------------------------------
game_loop:
    mov al, [game_state]

    call clearScreen320x200
    call showBackground320x200
    
    cmp al, STATE_MENU
    je .handle_menu
    cmp al, STATE_GAME
    je .handle_game
    cmp al, STATE_PAUSE
    je .handle_pause
    cmp al, STATE_GAMEOVER
    je .handle_gameover
    cmp al, STATE_EXIT
    je .exit_program
    
    jmp game_loop           ; Safety fallback

.handle_menu:
    call drawMainMenu
    call handleMainMenuInput    ; Returns selection in AL
    
    cmp al, 0xFF                ; ESC pressed?
    je .exit_program
    
    call executeMenuChoice
    jmp game_loop

.handle_game:
    ; TODO: Main game logic goes here
    call showMainGameScreen
    
    ; Temporary: Press any key to go to game over
    mov ah, 0x00
    int 0x16
    mov byte [game_state], STATE_GAMEOVER
    jmp game_loop

.handle_pause:
    call showPauseScreen
    ; TODO: Handle pause input
    mov byte [game_state], STATE_GAME
    jmp game_loop

.handle_gameover:
    call showGameOverScreen
    
    ; Wait for R (Retry) or Q (Quit)
    mov ah, 0x00
    int 0x16
    
    cmp al, 'r'
    je .retry
    cmp al, 'R'
    je .retry
    cmp al, 'q'
    je .quit_to_menu
    cmp al, 'Q'
    je .quit_to_menu
    jmp .handle_gameover

.retry:
    mov byte [game_state], STATE_GAME
    jmp game_loop

.quit_to_menu:
    mov byte [game_state], STATE_MENU
    jmp game_loop

.exit_program:
    ; Return to text mode
    mov ax, 0x0003
    int 0x10
    
    ; Exit to DOS
    mov ax, 0x4C00
    int 0x21
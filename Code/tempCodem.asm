; mainRunner.asm — Entrypoint for VGA 320x200 mode
[BITS 16]
[ORG 0x100]

jmp start

;%include "Code\font9x16.asm"
;%include "Code\ui.asm"
%include "Code\sound.asm"
%include "Code\show_bg.asm"
%include "Code\trie.asm"
;%include "Code\main_menu.asm"
;%include "Code\main_game_screen.asm"
;%include "Code\pause_screen.asm"
;%include "Code\game_over_screen.asm"

; --------------------------------------------------------------------------
; PROGRAM ENTRY
; --------------------------------------------------------------------------
start:
    
    ; --------------------------------------------------------
    ; Set VGA 320x200x256 mode
    ; --------------------------------------------------------
    mov ax, 0x0013
    int 0x10

    ; --- Initial game setup ---
    call showBackground320x200
    ;call drawGameUI
    ;call showPauseScreen

    ;mov word [final_score], ax
    ;mov byte [final_minutes], al
    ;mov byte [final_seconds], ah
    ;mov word [balloons_popped], bx
    ;mov word [balloons_missed], cx
    ;call showGameOverScreen

    call playCompletionSound

    mov dx, Z_data
    mov [write_word], dx
    mov cx, 235
    mov dx, 17
    mov si, 1
    mov al, 250
    mov [ColorHolder], al
    call DrawA

    ;mov si, msg

    ;.nextChar:
    ;    lodsb
    ;    cmp al, 0
    ;    je .done
    ;    call printChar
    ;    add bx, 9                ; move to next char
    ;    jmp .nextChar

    ;.done:
    ;    ret

    ;msg db "HELLO!",0

    
    mov ax,0
    int 16h
    
    mov ax, 0003h
    int 10h                  ; back to text mode

black : db 250
write_word : db 0
ColorHolder : db 250
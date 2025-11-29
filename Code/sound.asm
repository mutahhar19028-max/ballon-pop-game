; sound.asm — PC Speaker victory sound
; Compatible with NASM (COM or EXE)

melodyFreqs:
    dw 800, 900, 1000, 1100, 1200, 1300, 1400, 1500
    dw 1500, 1400, 1300, 1200, 1100, 1000, 900, 800
numNotes    equ 16
tempo       dw 2
pit_constant: dd 1193180    ; Store as 32-bit constant

; ---------------------------------------
; playCompletionSound — main entry
; ---------------------------------------
playCompletionSound:
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, melodyFreqs
    mov cx, numNotes
.loopNotes:
    lodsw                  ; AX = frequency
    or  ax, ax
    jz  .done
    call playTone
    loop .loopNotes

.done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------------------------------
; playTone — AX = frequency (Hz)
; ---------------------------------------
playTone:
    push ax
    push bx
    push cx
    push dx

    mov bx, ax              ; Save frequency in BX
    
    ; Load 1193180 into DX:AX
    mov ax, word [pit_constant]      ; Low word
    mov dx, word [pit_constant + 2]  ; High word
    
    ; Divide DX:AX by BX -> quotient in AX
    div bx                  ; DX:AX / BX = AX (remainder in DX)
    mov bx, ax              ; BX = divisor

    ; Program PIT channel 2
    mov al, 0xB6
    out 0x43, al
    mov ax, bx
    out 0x42, al            ; low byte
    mov al, ah
    out 0x42, al            ; high byte

    ; Enable speaker
    in al, 0x61
    or al, 3
    out 0x61, al

    ; Hold tone
    call toneDelay

    ; Disable speaker
    in al, 0x61
    and al, 0xFC
    out 0x61, al

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------------------------------
; toneDelay — simple busy wait
; ---------------------------------------
toneDelay:
    push cx
    push dx
    mov dx, [tempo]
.delayOuter:
    mov cx, 0xAFFF
.delayInner:
    loop .delayInner
    dec dx
    jnz .delayOuter
    pop dx
    pop cx
    ret
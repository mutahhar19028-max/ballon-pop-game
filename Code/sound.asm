melodyFreqs:
    dw 800, 900, 1000, 1100, 1200, 1300, 1400, 1500
    dw 1500, 1400, 1300, 1200, 1100, 1000, 900, 800
numNotes    equ 16
tempo       dw 2
pit_constant: dd 1193180

playCompletionSound:
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, melodyFreqs
    mov cx, numNotes
.loopNotes:
    lodsw
    or  ax, ax
    jz  .done
    call playTune
    loop .loopNotes

.done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

playTune:
    push ax
    push bx
    push cx
    push dx

    mov bx, ax
    
    mov ax, word [pit_constant]
    mov dx, word [pit_constant + 2]
    
    div bx
    mov bx, ax

    mov al, 0xB6
    out 0x43, al
    mov ax, bx
    out 0x42, al
    mov al, ah
    out 0x42, al

    in al, 0x61
    or al, 3
    out 0x61, al

    call toneDelay

    in al, 0x61
    and al, 0xFC
    out 0x61, al

    pop dx
    pop cx
    pop bx
    pop ax
    ret

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
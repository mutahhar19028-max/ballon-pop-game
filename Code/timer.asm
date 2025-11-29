; ============================================================
; timer.asm — IRQ0-based Timer System (1 second updates)
; ============================================================

; ------------------------------------------------------------
; TIMER CONFIGURATION
; ------------------------------------------------------------
%define PIT_CHANNEL0    0x40    ; PIT channel 0 data port
%define PIT_COMMAND     0x43    ; PIT command port
%define PIC_COMMAND     0x20    ; 8259 PIC command port
%define PIC_DATA        0x21    ; 8259 PIC data port

%define TICKS_PER_SEC   18      ; Default: 18.2 Hz, we'll use 18 for simplicity
%define GAME_TIME_SEC   120     ; 2 minutes = 120 seconds

; ------------------------------------------------------------
; TIMER VARIABLES
; ------------------------------------------------------------
timer_seconds       dw GAME_TIME_SEC    ; Remaining seconds (120)
timer_minutes       db 2                ; Display minutes
timer_display_sec   db 0                ; Display seconds
timer_ticks         db 0                ; Tick counter (0-17)
old_timer_vector    dd 0                ; Original IRQ0 handler address
timer_active        db 0                ; Timer running flag

; ------------------------------------------------------------
; installTimerISR
; Hooks IRQ0 (INT 08h) to custom timer handler
; Saves original vector for restoration
; ------------------------------------------------------------
installTimerISR:
    push ax
    push bx
    push cx
    push dx
    push es

    ; Save old INT 08h vector
    mov ax, 0x3508          ; AH=35h (Get interrupt vector), AL=08h
    int 0x21
    mov word [old_timer_vector], bx
    mov word [old_timer_vector+2], es

    ; Install new handler
    push ds
    mov ax, cs
    mov ds, ax
    mov dx, timerISR
    mov ax, 0x2508          ; AH=25h (Set interrupt vector), AL=08h
    int 0x21
    pop ds

    ; Initialize timer variables
    mov word [timer_seconds], GAME_TIME_SEC
    mov byte [timer_minutes], 2
    mov byte [timer_display_sec], 0
    mov byte [timer_ticks], 0
    mov byte [timer_active], 1

    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; restoreTimerISR
; Restores original IRQ0 handler
; Call before program exit!
; ------------------------------------------------------------
restoreTimerISR:
    push ax
    push dx
    push ds

    ; Restore old INT 08h vector
    lds dx, [old_timer_vector]
    mov ax, 0x2508
    int 0x21

    pop ds
    pop dx
    pop ax
    ret

; ------------------------------------------------------------
; timerISR
; Custom IRQ0 handler - called ~18.2 times per second
; Decrements timer every 18 ticks (approximately 1 second)
; ------------------------------------------------------------
timerISR:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    add word[current_score], 2

    ; Set DS to our data segment
    mov ax, cs
    mov ds, ax

    ; Check if timer is active
    cmp byte [timer_active], 1
    jne .chain_to_old

    ; Increment tick counter
    inc byte [timer_ticks]
    cmp byte [timer_ticks], TICKS_PER_SEC
    jb .chain_to_old        ; Not 1 second yet

    ; Reset tick counter
    mov byte [timer_ticks], 0

    ; Decrement seconds
    cmp word [timer_seconds], 0
    je .timer_expired       ; Already at 0

    dec word [timer_seconds]

    ; Update display format (MM:SS)
    call updateTimerDisplay

.chain_to_old:
    ; Send EOI to PIC
    mov al, 0x20
    out PIC_COMMAND, al

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret                    ; Return from interrupt

.timer_expired:
    ; Timer reached 0 - trigger game over
    mov byte [timer_active], 0
    ; Game state will be checked in main loop
    jmp .chain_to_old

; ------------------------------------------------------------
; updateTimerDisplay
; Converts timer_seconds to MM:SS format
; Updates timer_minutes and timer_display_sec
; ------------------------------------------------------------
updateTimerDisplay:
    push ax
    push bx
    push dx

    ; Get total seconds
    mov ax, [timer_seconds]

    ; Divide by 60 to get minutes
    xor dx, dx
    mov bx, 60
    div bx                  ; AX = minutes, DX = seconds

    ; Store results
    mov [timer_minutes], al
    mov [timer_display_sec], dl

    pop dx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; resetTimer
; Resets timer to initial value (120 seconds)
; ------------------------------------------------------------
resetTimer:
    push ax

    mov word [timer_seconds], GAME_TIME_SEC
    mov byte [timer_minutes], 2
    mov byte [timer_display_sec], 0
    mov byte [timer_ticks], 0
    mov byte [timer_active], 1

    pop ax
    ret

; ------------------------------------------------------------
; pauseTimer
; Pauses the timer (stops decrementing)
; ------------------------------------------------------------
pauseTimer:
    mov byte [timer_active], 0
    ret

; ------------------------------------------------------------
; resumeTimer
; Resumes the timer (continues decrementing)
; ------------------------------------------------------------
resumeTimer:
    mov byte [timer_active], 1
    ret

; ------------------------------------------------------------
; isTimerExpired
; Returns: AL = 1 if timer expired, 0 otherwise
; ------------------------------------------------------------
isTimerExpired:
    push bx
    
    mov al, 0
    cmp word [timer_seconds], 0
    jne .not_expired
    mov al, 1

.not_expired:
    pop bx
    ret

; ------------------------------------------------------------
; getTimerString
; Converts timer to "MM:SS" string format
; INPUT: SI = pointer to 6-byte buffer (output)
; OUTPUT: Buffer filled with "MM:SS\0"
; ------------------------------------------------------------
getTimerString:
    push ax
    push bx
    push cx
    push dx
    push di

    mov di, si              ; DI = output buffer

    ; Convert minutes to ASCII
    xor ah, ah
    mov al, [timer_minutes]
    mov bl, 10
    div bl                  ; AH = ones, AL = tens
    add al, '0'
    mov [di], al
    inc di
    mov al, ah
    add al, '0'
    mov [di], al
    inc di

    ; Add colon
    mov byte [di], ':'
    inc di

    ; Convert seconds to ASCII
    xor ah, ah
    mov al, [timer_display_sec]
    mov bl, 10
    div bl                  ; AH = ones, AL = tens
    add al, '0'
    mov [di], al
    inc di
    mov al, ah
    add al, '0'
    mov [di], al
    inc di

    ; Null terminator
    mov byte [di], 0

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
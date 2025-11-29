[org 0x0100]

; ------------------------------------
; Initialize values
; ------------------------------------
mov bx, 0B189h        ; BX = input number (we will count its 1-bits)
mov ax, 0ABA5h        ; AX = number we will transform later
mov dl, 17            ; DL = bit counter (17 steps to check all 16 bits of BX)
mov dh, 0             ; DH = counter to store number of 1’s found in BX

; ------------------------------------
; Loop through BX bits and count 1’s
; ------------------------------------
loop1:
    cmp dl, 0         ; are we done checking all bits?
    je finish         ; if yes → jump to finish stage

    rcr bx, 1         ; rotate BX right through CF → lowest bit goes into CF
    dec dl            ; decrement remaining bit counter

    jnc loop2         ; if CF = 0 (bit was 0), skip increment
    inc dh            ; if CF = 1 (bit was 1), increment count of ones

loop2:
    jmp loop1         ; repeat until all bits checked

; ------------------------------------
; Transform AX using the count of 1’s
; ------------------------------------
finish:
    cmp dh, 0         ; do we still have ones left to process?
    je complementInAX ; if none left, skip XOR step

    xor ax, 1         ; toggle lowest bit of AX
    dec dh            ; one “1” processed

complementInAX:
    ror ax, 1         ; rotate AX right by 1
    inc dl            ; increment rotation counter
    cmp dl, 16        ; did we complete 16 rotations?
    jne finish        ; if not, repeat

; ------------------------------------
; Exit program
; ------------------------------------
mov ax, 0x4C00
int 0x21
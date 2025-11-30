; ============================================================================
; balloon_system.asm — Balloon System with Background Buffer
; ============================================================================
; Uses background buffering to avoid redrawing entire screen
; Saves pixels before drawing, restores them before moving
; ============================================================================

; ------------------------------------------------------------
; BALLOON CONSTANTS
; ------------------------------------------------------------
%define MAX_BALLOONS        9
%define BALLOON_WIDTH       24              ; Pixels wide
%define BALLOON_HEIGHT      21              ; Pixels tall
%define BALLOON_STRING_LEN  2

%define SPAWN_Y             186             ; 200 - 14 = 186 (bottom)
%define DESPAWN_Y           40
%define MIN_SPAWN_X         30
%define MAX_SPAWN_X         286             ; 320 - 16 = 304

%define BALLOON_SPEED       1
%define MOVEMENT_DELAY      3               ; Move every 3 frames (slower!)
%define SPAWN_DELAY         100

; Buffer size per balloon: 16 * 14 = 224 bytes
%define BUFFER_SIZE         504

; Balloon colors (8 vibrant colors from your palette)
balloon_colors:
    db baby_light_light_blue, violet, grey, bright_cyan, light_orange, bright_yellow
; ------------------------------------------------------------
; BALLOON DATA STRUCTURE (16 bytes per balloon)
; ------------------------------------------------------------
; Offset | Size | Description
; -------+------+---------------------------
; +0     | 2    | x_position (word)
; +2     | 2    | y_position (word)
; +4     | 1    | letter (byte, ASCII 'A'-'Z')
; +5     | 1    | color_index (byte, 0-7)
; +6     | 1    | active_flag (byte, 0=inactive, 1=active)
; +7     | 1    | speed (byte, pixels/frame)
; +8     | 2    | buffer_offset (word, pointer to background buffer)
; +10-15 | 6    | Reserved
; ------------------------------------------------------------

balloon_array:      times (MAX_BALLOONS * 16) db 0
balloon_count:      db 0
spawn_timer:        dw 0
random_seed:        dw 0
movement_counter:   db 0        ; NEW: Frame counter for slower movement

; Background buffer: 10 balloons × 224 bytes = 2240 bytes
background_buffer:  times (MAX_BALLOONS * BUFFER_SIZE) db 0


; ============================================================================
; PUBLIC API FUNCTIONS
; ============================================================================

; ------------------------------------------------------------
; initBalloonSystem
; ------------------------------------------------------------
initBalloonSystem:
    push ax
    push bx
    push cx
    push di
    push es

    ; Clear balloon array
    mov ax, ds
    mov es, ax
    mov di, balloon_array
    mov cx, (MAX_BALLOONS * 16)
    xor al, al
    rep stosb

    ; Initialize buffer offsets for each balloon
    mov si, balloon_array
    mov ax, 0                   ; Buffer offset starts at 0
    mov cx, MAX_BALLOONS

.init_buffers:
    mov [si+8], ax              ; Store buffer offset
    add ax, BUFFER_SIZE         ; Next buffer
    add si, 16                  ; Next balloon
    loop .init_buffers

    ; Reset counters
    mov byte [balloon_count], 0
    mov word [spawn_timer], 0
    mov byte [movement_counter], 0  ; Reset movement counter

    ; Seed random
    mov ah, 0x00
    int 0x1A
    mov [random_seed], dx

    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; updateBalloons
; ------------------------------------------------------------
updateBalloons:
    push ax
    push bx
    push cx
    push dx

    ; Restore old backgrounds first
    call restoreAllBackgrounds

    ; Check spawn timer
    inc word [spawn_timer]
    mov ax, [spawn_timer]
    cmp ax, SPAWN_DELAY
    jb .skip_spawn
    
    call spawnBalloon
    mov word [spawn_timer], 0

.skip_spawn:
    ; Check movement timer (move every N frames)
    inc byte [movement_counter]
    mov al, [movement_counter]
    cmp al, MOVEMENT_DELAY
    jb .skip_move
    
    mov byte [movement_counter], 0
    call moveBalloons           ; Only move every MOVEMENT_DELAY frames
    
.skip_move:
    ; Remove off-screen balloons
    call removeOffscreenBalloons

    ; Save new backgrounds
    call saveAllBackgrounds

    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; renderBalloons
; ------------------------------------------------------------
renderBalloons:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.render_loop:
    ; Check active flag
    mov al, [si+6]
    cmp al, 1
    jne .next_balloon

    ; Get balloon data
    mov ax, [si+0]              ; X position
    mov bx, [si+2]              ; Y position
    mov dl, [si+4]              ; Letter
    mov dh, [si+5]              ; Color index

    ; Get actual color
    push si
    push cx
    xor ch, ch
    mov cl, dh
    and cl, 0x07
    mov si, balloon_colors
    add si, cx
    mov cl, [si]
    pop cx
    pop si

    ; Draw balloon
    push si
    push cx
    call drawBalloon
    pop cx
    pop si

.next_balloon:
    add si, 16
    loop .render_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; checkBalloonHit
; ------------------------------------------------------------
checkBalloonHit:
    push bx
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.check_loop:
    mov bl, [si+6]
    cmp bl, 1
    jne .next_check

    mov bl, [si+4]
    cmp al, bl
    je .hit_found

.next_check:
    add si, 16
    loop .check_loop

    xor al, al
    jmp .done

.hit_found:
    ; Restore background before removing
    push ax
    call restoreBalloonBackground   ; SI points to balloon
    pop ax

    ; Deactivate balloon
    mov byte [si+6], 0
    dec byte [balloon_count]

    ; Increment score
    add word [current_score], 10

    mov al, 1

.done:
    pop si
    pop cx
    pop bx
    ret


; ============================================================================
; BACKGROUND BUFFER FUNCTIONS
; ============================================================================

; ------------------------------------------------------------
; saveAllBackgrounds
; Saves background for all active balloons
; ------------------------------------------------------------
saveAllBackgrounds:
    push ax
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.save_loop:
    mov al, [si+6]              ; Check active
    cmp al, 1
    jne .next_save

    call saveBalloonBackground  ; SI points to balloon

.next_save:
    add si, 16
    loop .save_loop

    pop si
    pop cx
    pop ax
    ret


; ------------------------------------------------------------
; restoreAllBackgrounds
; Restores background for all active balloons
; ------------------------------------------------------------
restoreAllBackgrounds:
    push ax
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.restore_loop:
    mov al, [si+6]
    cmp al, 1
    jne .next_restore

    call restoreBalloonBackground

.next_restore:
    add si, 16
    loop .restore_loop

    pop si
    pop cx
    pop ax
    ret


; ------------------------------------------------------------
; saveBalloonBackground
; INPUT: SI = pointer to balloon structure
; Saves 16x14 pixel area to buffer
; ------------------------------------------------------------
saveBalloonBackground:
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push ds

    ; Get balloon position
    mov ax, [si+0]              ; X
    mov bx, [si+2]              ; Y
    mov di, [si+8]              ; Buffer offset

    ; Check bounds
    cmp bx, 0
    jl .done_save
    cmp bx, 200
    jge .done_save

    ; Setup segments
    mov dx, 0xA000
    mov ds, dx                  ; DS = VGA segment
    push cs
    pop es                      ; ES = our data segment
    add di, background_buffer   ; DI = buffer address

    ; Save 14 rows
    mov cx, BALLOON_HEIGHT

.save_row:
    push cx
    push ax
    push bx

    ; Check if row is visible
    cmp bx, 0
    jl .skip_row
    cmp bx, 200
    jge .skip_row

    ; Calculate VGA offset: Y * 320 + X
    push ax
    mov ax, bx
    mov dx, 320
    mul dx
    pop dx
    add ax, dx                  ; AX = VGA offset
    mov si, ax

    ; Copy 16 pixels
    mov cx, BALLOON_WIDTH
.copy_pixel:
    mov al, [ds:si]
    mov [es:di], al
    inc si
    inc di
    loop .copy_pixel
    jmp .next_row

.skip_row:
    ; Fill with zeros if off-screen
    mov cx, BALLOON_WIDTH
    xor al, al
.fill_zero:
    mov [es:di], al
    inc di
    loop .fill_zero

.next_row:
    pop bx
    pop ax
    inc bx                      ; Next Y
    pop cx
    loop .save_row

.done_save:
    pop ds
    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; restoreBalloonBackground
; INPUT: SI = pointer to balloon structure
; Restores 16x14 pixel area from buffer
; ------------------------------------------------------------
restoreBalloonBackground:
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push ds

    ; Get balloon position
    mov ax, [si+0]              ; X
    mov bx, [si+2]              ; Y
    mov si, [si+8]              ; Buffer offset

    ; Check bounds
    cmp bx, 0
    jl .done_restore
    cmp bx, 200
    jge .done_restore

    ; Setup segments
    push cs
    pop ds                      ; DS = our data segment
    add si, background_buffer   ; SI = buffer address
    mov dx, 0xA000
    mov es, dx                  ; ES = VGA segment

    ; Restore 14 rows
    mov cx, BALLOON_HEIGHT

.restore_row:
    push cx
    push ax
    push bx

    ; Check if row is visible
    cmp bx, 0
    jl .skip_restore_row
    cmp bx, 200
    jge .skip_restore_row

    ; Calculate VGA offset
    push ax
    mov ax, bx
    mov dx, 320
    mul dx
    pop dx
    add ax, dx
    mov di, ax

    ; Copy 16 pixels
    mov cx, BALLOON_WIDTH
.restore_pixel:
    mov al, [ds:si]
    mov [es:di], al
    inc si
    inc di
    loop .restore_pixel
    jmp .next_restore_row

.skip_restore_row:
    add si, BALLOON_WIDTH       ; Skip buffer row

.next_restore_row:
    pop bx
    pop ax
    inc bx
    pop cx
    loop .restore_row

.done_restore:
    pop ds
    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ============================================================================
; HELPER FUNCTIONS
; ============================================================================

; ------------------------------------------------------------
; spawnBalloon
; ------------------------------------------------------------
spawnBalloon:
    push ax
    push bx
    push cx
    push si

    mov al, [balloon_count]
    cmp al, MAX_BALLOONS
    jae .no_spawn

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.find_slot:
    mov al, [si+6]
    cmp al, 0
    je .found_slot
    add si, 16
    loop .find_slot
    jmp .no_spawn

.found_slot:
    ; Random X
    call getRandomNumber
    mov bx, 256
    xor dx, dx
    div bx
    add dx, MIN_SPAWN_X
    mov [si+0], dx

    ; Y at bottom
    mov word [si+2], SPAWN_Y

    ; Random letter
    call getRandomNumber
    mov bx, 26
    xor dx, dx
    div bx
    add dl, 'A'
    mov [si+4], dl

    ; Random color
    call getRandomNumber
    and al, 0x07
    mov [si+5], al

    ; Activate
    mov byte [si+6], 1
    mov byte [si+7], BALLOON_SPEED

    inc byte [balloon_count]

.no_spawn:
    pop si
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; moveBalloons
; ------------------------------------------------------------
moveBalloons:
    push ax
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.move_loop:
    mov al, [si+6]
    cmp al, 1
    jne .next_move

    ; Move UP: Y -= speed
    mov al, [si+7]
    xor ah, ah
    sub [si+2], ax

.next_move:
    add si, 16
    loop .move_loop

    pop si
    pop cx
    pop ax
    ret


; ------------------------------------------------------------
; removeOffscreenBalloons
; ------------------------------------------------------------
removeOffscreenBalloons:
    push ax
    push bx
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.remove_loop:
    mov al, [si+6]
    cmp al, 1
    jne .next_remove

    mov ax, [si+2]
    cmp ax, DESPAWN_Y
    jge .next_remove

    ; Restore background before deactivating
    call restoreBalloonBackground

    mov byte [si+6], 0
    dec byte [balloon_count]

.next_remove:
    add si, 16
    loop .remove_loop

    pop si
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; getRandomNumber
; ------------------------------------------------------------
getRandomNumber:
    push bx
    push dx

    mov ax, [random_seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    adc dx, 0
    mov [random_seed], ax

    pop dx
    pop bx
    ret
%define MAX_BALLOONS        9
%define BALLOON_WIDTH       24
%define BALLOON_HEIGHT      21
%define BALLOON_STRING_LEN  2

%define SPAWN_Y             186
%define DESPAWN_Y           40
%define MIN_SPAWN_X         30
%define MAX_SPAWN_X         286

%define BALLOON_SPEED       1
%define MOVEMENT_DELAY      3
%define SPAWN_DELAY         100

%define BUFFER_SIZE         504

balloon_colors:
    db baby_light_light_blue, violet, grey, bright_cyan, light_orange, bright_yellow

balloon_array:      times (MAX_BALLOONS * 16) db 0
balloon_count:      db 0
spawn_timer:        dw 0
random_seed:        dw 0
movement_counter:   db 0

background_buffer:  times (MAX_BALLOONS * BUFFER_SIZE) db 0

initBalloonSystem:
    push ax
    push bx
    push cx
    push di
    push es

    mov ax, ds
    mov es, ax
    mov di, balloon_array
    mov cx, (MAX_BALLOONS * 16)
    xor al, al
    rep stosb

    mov si, balloon_array
    mov ax, 0
    mov cx, MAX_BALLOONS

.init_buffers:
    mov [si+8], ax
    add ax, BUFFER_SIZE
    add si, 16
    loop .init_buffers

    mov byte [balloon_count], 0
    mov word [spawn_timer], 0
    mov byte [movement_counter], 0

    mov ah, 0x00
    int 0x1A
    mov [random_seed], dx

    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

updateBalloons:
    push ax
    push bx
    push cx
    push dx

    call restoreAllBackgrounds

    inc word [spawn_timer]
    mov ax, [spawn_timer]
    cmp ax, SPAWN_DELAY
    jb .skip_spawn
    
    call spawnBalloon
    mov word [spawn_timer], 0

.skip_spawn:
    inc byte [movement_counter]
    mov al, [movement_counter]
    cmp al, MOVEMENT_DELAY
    jb .skip_move
    
    mov byte [movement_counter], 0
    call moveBalloons
    
.skip_move:
    call removeOffscreenBalloons

    call saveAllBackgrounds

    pop dx
    pop cx
    pop bx
    pop ax
    ret

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
    mov al, [si+6]
    cmp al, 1
    jne .next_balloon

    mov ax, [si+0]
    mov bx, [si+2]
    mov dl, [si+4]
    mov dh, [si+5]

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
    push ax
    call restoreBalloonBackground
    call playPopSound
    pop ax

    mov byte [si+6], 0
    dec byte [balloon_count]

    add word [current_score], 10

    mov al, 1

.done:
    pop si
    pop cx
    pop bx
    ret

saveAllBackgrounds:
    push ax
    push cx
    push si

    mov si, balloon_array
    mov cx, MAX_BALLOONS

.save_loop:
    mov al, [si+6]
    cmp al, 1
    jne .next_save

    call saveBalloonBackground

.next_save:
    add si, 16
    loop .save_loop

    pop si
    pop cx
    pop ax
    ret

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

saveBalloonBackground:
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push ds

    mov ax, [si+0]
    mov bx, [si+2]
    mov di, [si+8]

    cmp bx, 0
    jl .done_save
    cmp bx, 200
    jge .done_save

    mov dx, 0xA000
    mov ds, dx
    push cs
    pop es
    add di, background_buffer

    mov cx, BALLOON_HEIGHT

.save_row:
    push cx
    push ax
    push bx

    cmp bx, 0
    jl .skip_row
    cmp bx, 200
    jge .skip_row

    push ax
    mov ax, bx
    mov dx, 320
    mul dx
    pop dx
    add ax, dx
    mov si, ax

    mov cx, BALLOON_WIDTH
.copy_pixel:
    mov al, [ds:si]
    mov [es:di], al
    inc si
    inc di
    loop .copy_pixel
    jmp .next_row

.skip_row:
    mov cx, BALLOON_WIDTH
    xor al, al
.fill_zero:
    mov [es:di], al
    inc di
    loop .fill_zero

.next_row:
    pop bx
    pop ax
    inc bx
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

restoreBalloonBackground:
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push ds

    mov ax, [si+0]
    mov bx, [si+2]
    mov si, [si+8]

    cmp bx, 0
    jl .done_restore
    cmp bx, 200
    jge .done_restore

    push cs
    pop ds
    add si, background_buffer
    mov dx, 0xA000
    mov es, dx

    mov cx, BALLOON_HEIGHT

.restore_row:
    push cx
    push ax
    push bx

    cmp bx, 0
    jl .skip_restore_row
    cmp bx, 200
    jge .skip_restore_row

    push ax
    mov ax, bx
    mov dx, 320
    mul dx
    pop dx
    add ax, dx
    mov di, ax

    mov cx, BALLOON_WIDTH
.restore_pixel:
    mov al, [ds:si]
    mov [es:di], al
    inc si
    inc di
    loop .restore_pixel
    jmp .next_restore_row

.skip_restore_row:
    add si, BALLOON_WIDTH

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
    call getRandomNumber
    mov bx, 256
    xor dx, dx
    div bx
    add dx, MIN_SPAWN_X
    mov [si+0], dx

    mov word [si+2], SPAWN_Y

    call getRandomNumber
    mov bx, 26
    xor dx, dx
    div bx
    add dl, 'A'
    mov [si+4], dl

    call getRandomNumber
    and al, 0x07
    mov [si+5], al

    mov byte [si+6], 1
    mov byte [si+7], BALLOON_SPEED

    inc byte [balloon_count]

.no_spawn:
    pop si
    pop cx
    pop bx
    pop ax
    ret

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

    call restoreBalloonBackground

    mov byte [si+6], 0
    dec byte [balloon_count]
    
    push si
    push cx
    call playErrorSound
    pop cx
    pop si

.next_remove:
    add si, 16
    loop .remove_loop

    pop si
    pop cx
    pop bx
    pop ax
    ret

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
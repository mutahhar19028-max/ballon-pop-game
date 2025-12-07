%define MODE_VGA13H  0x0013
%define VIDEO_SEG    0xA000
%define SCREEN_SIZE  64000
%define CHUNK_SIZE   8192

showBackground320x200:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov al, [palette_loaded]
    cmp al, 1
    je .skip_palette
    call load_palette
    mov byte [palette_loaded], 1

.skip_palette:
    mov ax, VIDEO_SEG
    mov es, ax
    xor di, di

    lea dx, [filename]
    mov ah, 0x3D
    xor al, al
    int 0x21
    jc .cleanup
    mov bx, ax

.read_loop:
    mov ah, 0x3F
    mov cx, CHUNK_SIZE
    lea dx, [buffer]
    int 0x21
    jc .close_file
    or ax, ax
    jz .close_file

    push ds
    mov si, buffer
    mov cx, ax
.copy_loop:
    mov al, [si]
    mov [es:di], al
    inc si
    inc di
    loop .copy_loop
    pop ds

    cmp di, SCREEN_SIZE
    jb .read_loop

.close_file:
    mov ah, 0x3E
    int 0x21

.cleanup:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

load_palette:
    push ax
    push bx
    push cx
    push dx
    push si
    push ds

    lea dx, [palette_filename]
    mov ah, 0x3D
    xor al, al
    int 0x21
    jc .lp_exit
    mov bx, ax

    mov ah, 0x3F
    mov cx, 768
    lea dx, [palette_buffer]
    int 0x21

    mov ah, 0x3E
    int 0x21

    mov dx, 0x03C8
    xor al, al
    out dx, al
    inc dx
    lea si, [palette_buffer]
    mov cx, 768
.lp_out:
    lodsb
    out dx, al
    loop .lp_out

.lp_exit:
    pop ds
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

filename          db "imgData.raw",0
palette_filename  db "palette.bin",0

buffer            times CHUNK_SIZE db 0
palette_buffer    times 768 db 0

palette_loaded    db 0
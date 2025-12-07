%define SCREEN_WIDTH    320
%define SCREEN_HEIGHT   200
%define VGA_SEGMENT     0xA000

; Inputs: AX=x, BX=y, CX=width, DX=height, SI=fill_color, DI=border_color
drawRoundedRect:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 10
    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov word [bp-8], dx
    mov word [bp-10], si

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 2
    mov cx, [bp-6]
    mov dx, [bp-8]
    sub dx, 4
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    mov cx, [bp-6]
    sub cx, 4
    mov dx, 2
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    add ax, 2
    mov bx, [bp-4]
    add bx, [bp-8]
    sub bx, 2
    mov cx, [bp-6]
    sub cx, 4
    mov dx, 2
    mov si, [bp-10]
    call drawFilledRect

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov cx, [bp-6]
    mov dx, [bp-8]
    mov si, di
    call drawRectOutline

    add sp, 10
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AX=x, BX=y, CX=width, DX=height, SI=color
drawFilledRect:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    push bp

    cmp ax, 320
    jae .done
    cmp bx, 200
    jae .done

    mov bp, VGA_SEGMENT
    mov es, bp

    mov bp, dx

.row_loop:
    push cx
    push ax
    
    mov di, bx
    push dx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    pop dx
    add di, ax

.col_loop:
    mov [es:di], si
    inc di
    loop .col_loop
    
    pop ax
    pop cx
    inc bx
    dec bp
    jnz .row_loop

.done:
    pop bp
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AX=x, BX=y, CX=width, DX=height, SI=color
drawRectOutline:
    push ax
    push bx
    push cx
    push dx
    push di
    push bp

    mov bp, sp
    sub sp, 8
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cx
    mov [bp-8], dx

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov cx, [bp-6]
    call drawHorizontalLine

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, [bp-8]
    dec bx
    mov cx, [bp-6]
    call drawHorizontalLine

    mov ax, [bp-2]
    mov bx, [bp-4]
    mov dx, [bp-8]
    call drawVerticalLine

    mov ax, [bp-2]
    add ax, [bp-6]
    dec ax
    mov bx, [bp-4]
    mov dx, [bp-8]
    call drawVerticalLine

    add sp, 8
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AX=start_x, BX=y, CX=length, SI=color
drawHorizontalLine:
    push ax
    push bx
    push cx
    push di
    push es
    push dx

    cmp bx, 200
    jae .done
    cmp ax, 320
    jae .done

    mov di, 0xA000
    mov es, di

    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    add di, ax

.draw_loop:
    cmp di, 64000
    jae .done
    mov [es:di], si
    inc di
    loop .draw_loop

.done:
    pop dx
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AX=x, BX=start_y, DX=length, SI=color
drawVerticalLine:
    push ax
    push bx
    push dx
    push di
    push es

    cmp ax, 320
    jae .done
    cmp bx, 200
    jae .done

    mov di, 0xA000
    mov es, di

.draw_loop:
    push dx
    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    pop dx
    add di, ax
    
    mov [es:di], si
    inc bx
    dec dx
    jnz .draw_loop

.done:
    pop es
    pop di
    pop dx
    pop bx
    pop ax
    ret

; Inputs: [char_color]=color_byte
clearScreen:
    push ax
    push cx
    push di
    push es

    mov ax, VGA_SEGMENT
    mov es, ax
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
    xor ah, ah
    mov al, [char_color]
    rep stosb

    pop es
    pop di
    pop cx
    pop ax
    ret

; Inputs: None (Uses hardcoded 320x200 loop)
display_palette_wide:
    push ax
    push bx
    push cx
    push di
    push es
    
    mov ax, 0A000h
    mov es, ax
    xor di, di

    mov cx, 256
    mov al, 0

outer_color_loop:
    mov bx, 320*200

inner_pixel_loop:
    stosb
    dec bx
    jnz inner_pixel_loop

    push ax
    mov ax, 0
    int 16h
    pop ax

    inc al
    loop outer_color_loop

    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

; Inputs: CX=x, DX=y, SI=string_ptr, BL=color, BH=scale
drawText:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov [dt_x_pos], cx
    mov [dt_y_pos], dx
    mov [dt_color], bl
    mov [dt_scale], bh

.next:
    lodsb
    or al, al
    jz .done
    cmp al, ' '
    je .space

    push si
    call drawChar
    pop si

.space:
    mov al, [dt_scale]
    xor ah, ah
    mov cl, 9
    mul cl
    add [dt_x_pos], ax
    mov cx, [dt_x_pos]
    mov dx, [dt_y_pos]
    jmp .next

.done:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AL=ascii_char, Uses:[dt_x_pos], [dt_y_pos], [dt_color], [dt_scale]
drawChar:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov ah, 0
    mov bl, 8
    mul bl
    mov si, FONT_OFF
    add si, ax
    mov ax, FONT_SEG
    mov es, ax

    mov ax, [dt_x_pos]
    mov [.start_x], ax
    mov ax, [dt_y_pos]
    mov [.start_y], ax

    mov bp, 8

.row_loop:
    mov al, [es:si]
    inc si

    mov cx, [.start_x]
    mov dx, [dt_y_pos]

    mov di, 8

.bit_loop:
    mov dx, [dt_y_pos]
    test al, 0x80
    jz .skip_bit

    push ax
    push di

    xor bh, bh
    mov bl, [dt_scale]
    mov [.scale_y_count], bx

.scale_y_loop:
    push cx
    push dx
    xor bh, bh
    mov bl, [dt_scale]
    mov [.scale_x_count], bx

.scale_x_loop:
    call putPixel
    inc cx
    dec word [.scale_x_count]
    jnz .scale_x_loop

    pop dx
    pop cx
    inc dx
    dec word [.scale_y_count]
    jnz .scale_y_loop

    pop di
    pop ax

.skip_bit:
    xor bh, bh
    mov bl, [dt_scale]
    add cx, bx
    shl al, 1
    dec di
    jnz .bit_loop

    mov ax, [dt_y_pos]
    mov bx, [dt_scale]
    add ax, bx
    mov [dt_y_pos], ax

    dec bp
    jnz .row_loop

    mov ax, [.start_y]
    mov [dt_y_pos], ax

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

.start_x        dw 0
.start_y        dw 0
.scale_x_count  dw 0
.scale_y_count  dw 0

; Inputs: CX=x, DX=y, [dt_color]=color
putPixel:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    cmp cx, 320
    jae .done_put
    cmp dx, 200
    jae .done_put

    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov di, ax

    mov ax, 0xA000
    mov es, ax
    mov al, [dt_color]
    mov [es:di], al

.done_put:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: CX=x, DX=y, BL=color
drawSelectionArrow:
    push ax
    push bx
    push cx
    push dx

    mov [dt_color], bl
    mov byte [dt_scale], 1
    mov [dt_x_pos], cx
    mov [dt_y_pos], dx
    mov al, '>'
    call drawChar

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: None (Waits for port 0x3DA)
wait_vsync:
    mov dx, 03DAh

.l1:
    in al, dx
    test al, 08h
    jz .l1

.l2:
    in al, dx
    test al, 08h
    jnz .l2

    ret

; Inputs: AX=center_x, BX=center_y, CX=radius, DL=color
drawCircleOutline:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16

    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    mov [dt_color], dl

    mov word [bp-10], 0
    mov ax, [bp-6]
    mov word [bp-12], ax

    mov ax, 1
    sub ax, [bp-6]
    mov word [bp-14], ax

.circle_outline_loop:
    mov ax, [bp-10]
    mov bx, [bp-12]

    mov cx, [bp-2]
    add cx, [bp-10]
    mov dx, [bp-4]
    add dx, [bp-12]
    call putPixel

    mov cx, [bp-2]
    sub cx, [bp-10]
    mov dx, [bp-4]
    add dx, [bp-12]
    call putPixel

    mov cx, [bp-2]
    add cx, [bp-10]
    mov dx, [bp-4]
    sub dx, [bp-12]
    call putPixel

    mov cx, [bp-2]
    sub cx, [bp-10]
    mov dx, [bp-4]
    sub dx, [bp-12]
    call putPixel

    mov cx, [bp-2]
    add cx, [bp-12]
    mov dx, [bp-4]
    add dx, [bp-10]
    call putPixel

    mov cx, [bp-2]
    sub cx, [bp-12]
    mov dx, [bp-4]
    add dx, [bp-10]
    call putPixel

    mov cx, [bp-2]
    add cx, [bp-12]
    mov dx, [bp-4]
    sub dx, [bp-10]
    call putPixel

    mov cx, [bp-2]
    sub cx, [bp-12]
    mov dx, [bp-4]
    sub dx, [bp-10]
    call putPixel

    mov ax, [bp-14]
    cmp ax, 0
    jl .d_less_zero
    
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    mov si, [bp-12]
    shl si, 1
    sub dx, si
    add ax, dx
    add ax, 5
    mov [bp-14], ax
    dec word [bp-12]
    jmp .d_done

.d_less_zero:
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    add ax, dx
    add ax, 3
    mov [bp-14], ax

.d_done:
    inc word [bp-10]
    mov ax, [bp-10]
    cmp ax, [bp-12]
    jle .circle_outline_loop

    add sp, 16
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AX=center_x, BX=center_y, CX=radius, DL=color
drawCircleFilled:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16
    
    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    mov word [bp-10], 0
    mov ax, [bp-6]
    mov word [bp-12], ax

    mov ax, 1
    sub ax, [bp-6]
    mov word [bp-14], ax

.fill_loop:
    mov ax, [bp-10]
    shl ax, 1
    add ax, 1
    mov cx, ax

    mov ax, [bp-2]
    sub ax, [bp-10]
    mov dx, ax

    mov bx, [bp-4]
    sub bx, [bp-12]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    mov bx, [bp-4]
    add bx, [bp-12]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    mov ax, [bp-12]
    shl ax, 1
    add ax, 1
    mov cx, ax

    mov ax, [bp-2]
    sub ax, [bp-12]
    mov dx, ax

    mov bx, [bp-4]
    sub bx, [bp-10]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    mov bx, [bp-4]
    add bx, [bp-10]
    mov ax, dx
    xor si, si
    mov si, word [bp-8]
    and si, 0x00FF
    call drawHorizontalLine

    mov ax, [bp-14]
    cmp ax, 0
    jl .f_d_less_zero
    
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    mov si, [bp-12]
    shl si, 1
    sub dx, si
    add ax, dx
    add ax, 5
    mov [bp-14], ax
    dec word [bp-12]
    jmp .f_d_done

.f_d_less_zero:
    mov ax, [bp-14]
    mov dx, [bp-10]
    shl dx, 1
    add ax, dx
    add ax, 3
    mov [bp-14], ax

.f_d_done:
    inc word [bp-10]
    mov ax, [bp-10]
    cmp ax, [bp-12]
    jle .fill_loop

    add sp, 16
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AL=color_byte
clearScreen320x200:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov bx, VGA_SEGMENT
    mov es, bx
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov ah, al
    rep stosb

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: AL=color_byte
clearScreenBIOS:
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x06
    mov al, 0
    mov bh, 0
    mov cx, 0
    mov dx, 0xC813
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Inputs: None (Sets Mode 13h)
setVideoMode13h:
    push ax
    mov ax, 0x0013
    int 0x10
    pop ax
    ret

; Inputs: None (Sets Mode 03h)
setTextMode:
    push ax
    mov ax, 0x0003
    int 0x10
    pop ax
    ret

; Inputs: None (Flushes keyboard buffer)
flushKeyboardBuffer:
    mov ah, 01h
    int 16h
    jz .done
    mov ah, 00h
    int 16h
    jmp flushKeyboardBuffer
.done:
    ret
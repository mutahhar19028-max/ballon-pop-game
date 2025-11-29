; ============================================================
; main_game_screen.asm — Game UI Components (Static Display)
; Draws score, timer, buttons, and game elements
; ============================================================

; ------------------------------------------------------------
; CONFIGURATION CONSTANTS - Customize these for easy changes
; ------------------------------------------------------------

; === COLORS (VGA 256-color palette indices) ===
%define COLOR_WHITE         180 ; border
%define COLOR_BLACK         200 ; score text
%define COLOR_BLUE          250 ; panel
%define COLOR_DARK_BLUE     0x01
%define COLOR_RED           0x0C
%define COLOR_ORANGE        0x06
%define COLOR_YELLOW        0x0E
%define COLOR_LIGHT_GRAY    0x07
%define COLOR_DARK_GRAY     0x08

%define PADDING 2
%define MAX_WIDTH 320
%define BOX_WIDTH 85
%define BOX_HEIGHT 15
%define BASE_RADIUS 10

; === SCORE PANEL ===
%define SCORE_PANEL_X       (MAX_WIDTH / 2) -  (SCORE_PANEL_WIDTH / 2)
%define SCORE_PANEL_Y       PADDING
%define SCORE_PANEL_WIDTH   BOX_WIDTH
%define SCORE_PANEL_HEIGHT  BOX_HEIGHT
%define SCORE_PANEL_COLOR   COLOR_BLUE
%define SCORE_BORDER_COLOR  COLOR_WHITE
%define SCORE_TEXT_X        (SCORE_PANEL_X + (SCORE_PANEL_WIDTH / 8))
%define SCORE_TEXT_Y        ((SCORE_PANEL_Y + SCORE_PANEL_HEIGHT) / 2) - PADDING
%define SCORE_VALUE_X       ((SCORE_PANEL_X + (SCORE_PANEL_WIDTH / 2)) + (SCORE_PANEL_WIDTH / 3))
%define SCORE_VALUE_Y       ((SCORE_PANEL_Y + SCORE_PANEL_HEIGHT) / 2)

; === TIMER PANEL ===
%define TIMER_PANEL_X       MAX_WIDTH - (TIMER_PANEL_WIDTH + PADDING)
%define TIMER_PANEL_Y       PADDING
%define TIMER_PANEL_WIDTH   BOX_WIDTH
%define TIMER_PANEL_HEIGHT  BOX_HEIGHT
%define TIMER_PANEL_COLOR   COLOR_BLUE
%define TIMER_BORDER_COLOR  COLOR_WHITE
%define TIMER_TEXT_X        (((TIMER_PANEL_X + TIMER_PANEL_WIDTH) / 2) - (TIMER_PANEL_WIDTH / 3))
%define TIMER_TEXT_Y        ((TIMER_PANEL_Y + TIMER_PANEL_HEIGHT) / 2)
%define TIMER_VALUE_X       TIMER_PANEL_X 
%define TIMER_VALUE_Y       ((TIMER_PANEL_Y + TIMER_PANEL_HEIGHT) / 2)

; === SOUND BUTTON ===
%define SOUND_BTN_RADIUS    BASE_RADIUS
%define SOUND_BTN_X         PADDING + ((SOUND_BTN_RADIUS / 2) + SOUND_BTN_RADIUS)
%define SOUND_BTN_Y         ((PADDING / 2) + PADDING) + SOUND_BTN_RADIUS
%define SOUND_BTN_COLOR     COLOR_BLUE
%define SOUND_BTN_BORDER    COLOR_WHITE

; === PAUSE BUTTON ===
%define PAUSE_BTN_RADIUS    BASE_RADIUS
%define PAUSE_BTN_X         SOUND_BTN_X + (((SOUND_BTN_RADIUS / 2) + SOUND_BTN_RADIUS) + PADDING + PAUSE_BTN_RADIUS)
%define PAUSE_BTN_Y         ((PADDING / 2) + PADDING) + PAUSE_BTN_RADIUS
%define PAUSE_BTN_COLOR     COLOR_BLUE
%define PAUSE_BTN_BORDER    COLOR_WHITE

; === BALLOONS ===
%define BALLOON_WIDTH       30
%define BALLOON_HEIGHT      40
%define BALLOON_STRING_LEN  30

; === TEXT RENDERING ===
%define CHAR_WIDTH          8
%define CHAR_HEIGHT         8

; ------------------------------------------------------------
; DATA SECTION
; ------------------------------------------------------------

current_score       dw 80
current_minutes     db 12
current_seconds     db 47
sound_enabled       db 1
game_paused         db 0

score_label         db 'SCORE', 120

font_0: db 0x3E, 0x63, 0x63, 0x63, 0x63, 0x63, 0x3E, 0x00
font_1: db 0x0C, 0x1C, 0x0C, 0x0C, 0x0C, 0x0C, 0x3F, 0x00
font_2: db 0x3E, 0x63, 0x03, 0x0E, 0x38, 0x60, 0x7F, 0x00
font_3: db 0x3E, 0x63, 0x03, 0x1E, 0x03, 0x63, 0x3E, 0x00
font_4: db 0x06, 0x0E, 0x1E, 0x36, 0x66, 0x7F, 0x06, 0x00
font_5: db 0x7F, 0x60, 0x7E, 0x03, 0x03, 0x63, 0x3E, 0x00
font_6: db 0x1E, 0x30, 0x60, 0x7E, 0x63, 0x63, 0x3E, 0x00
font_7: db 0x7F, 0x03, 0x06, 0x0C, 0x18, 0x18, 0x18, 0x00
font_8: db 0x3E, 0x63, 0x63, 0x3E, 0x63, 0x63, 0x3E, 0x00
font_9: db 0x3E, 0x63, 0x63, 0x3F, 0x03, 0x06, 0x3C, 0x00

font_table:
    dw font_0, font_1, font_2, font_3, font_4
    dw font_5, font_6, font_7, font_8, font_9

; ------------------------------------------------------------
; PUBLIC: drawGameUI
; ------------------------------------------------------------
drawGameUI:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    call drawScorePanel
    call drawTimerPanel
    call drawSoundButton
    call drawPauseButton
    call drawSampleBalloons

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawScorePanel
; ------------------------------------------------------------
drawScorePanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, SCORE_PANEL_X
    mov bx, SCORE_PANEL_Y
    mov cx, SCORE_PANEL_WIDTH
    mov dx, SCORE_PANEL_HEIGHT
    mov si, SCORE_PANEL_COLOR
    mov di, SCORE_BORDER_COLOR
    call drawRoundedRect

    mov ax, SCORE_TEXT_X
    mov bx, SCORE_TEXT_Y
    mov si, score_label
    mov dl, COLOR_BLACK
    call drawText

    mov ax, SCORE_VALUE_X
    mov bx, SCORE_VALUE_Y
    mov dx, [current_score]
    mov cl, COLOR_BLACK
    call drawNumber

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawTimerPanel
; ------------------------------------------------------------
drawTimerPanel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, TIMER_PANEL_X
    mov bx, TIMER_PANEL_Y
    mov cx, TIMER_PANEL_WIDTH
    mov dx, TIMER_PANEL_HEIGHT
    mov si, TIMER_PANEL_COLOR
    mov di, TIMER_BORDER_COLOR
    call drawRoundedRect

    mov ax, TIMER_VALUE_X
    mov bx, TIMER_VALUE_Y
    call drawTimerValue

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSoundButton
; ------------------------------------------------------------
drawSoundButton:
    push ax
    push bx
    push cx
    push dx

    mov ax, SOUND_BTN_X
    mov bx, SOUND_BTN_Y
    mov cx, SOUND_BTN_RADIUS
    mov dl, SOUND_BTN_COLOR
    call drawCircleFilled

    mov ax, SOUND_BTN_X
    mov bx, SOUND_BTN_Y
    mov cx, SOUND_BTN_RADIUS
    add cx, 1
    mov dl, SOUND_BTN_BORDER
    call drawCircleOutline

    mov ax, SOUND_BTN_X
    mov bx, SOUND_BTN_Y
    add ax, 2
    call drawSpeakerIcon

    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ------------------------------------------------------------
; drawPauseButton
; ------------------------------------------------------------
drawPauseButton:
    push ax
    push bx
    push cx
    push dx

    mov ax, PAUSE_BTN_X
    mov bx, PAUSE_BTN_Y
    mov cx, PAUSE_BTN_RADIUS
    mov dl, PAUSE_BTN_COLOR
    call drawCircleFilled

    mov ax, PAUSE_BTN_X
    mov bx, PAUSE_BTN_Y
    mov cx, PAUSE_BTN_RADIUS
    add cx, 1
    mov dl, PAUSE_BTN_BORDER
    call drawCircleOutline

    mov ax, PAUSE_BTN_X
    mov bx, PAUSE_BTN_Y
    add ax, 2
    call drawPauseIcon

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawRoundedRect
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawFilledRect
; ------------------------------------------------------------
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

    mov bp, 0xA000
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

; ------------------------------------------------------------
; drawRectOutline
; ------------------------------------------------------------
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
; ------------------------------------------------------------
; drawCircleOutline
; AX = center X
; BX = center Y
; CX = radius
; DL = color (byte)
; Uses: drawPixel (AX=x, BX=y, SI=color)
; ------------------------------------------------------------
drawCircleOutline:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16            ; allocate space for locals
                         ; [bp-2]  = saved AX (centerX)
                         ; [bp-4]  = saved BX (centerY)
                         ; [bp-6]  = saved CX (radius)
                         ; [bp-8]  = saved DL (color, low byte)
                         ; [bp-10] = x (current x)
                         ; [bp-12] = y (current y)
                         ; [bp-14] = d (decision, word)

    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    mov word [bp-10], 0               ; x = 0
    mov ax, [bp-6]
    mov word [bp-12], ax              ; y = radius

    mov ax, 1
    sub ax, [bp-6]                    ; d = 1 - radius
    mov word [bp-14], ax

.circle_outline_loop:
    ; load current x,y into registers for convenience
    mov ax, [bp-10]      ; ax = x
    mov bx, [bp-12]      ; bx = y

    ; Plot 8 symmetry points, color in SI
    ; 1: (cx + x, cy + y)
    mov ax, [bp-2]
    add ax, [bp-10]
    mov bx, [bp-4]
    add bx, [bp-12]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 2: (cx - x, cy + y)
    mov ax, [bp-2]
    sub ax, [bp-10]
    mov bx, [bp-4]
    add bx, [bp-12]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 3: (cx + x, cy - y)
    mov ax, [bp-2]
    add ax, [bp-10]
    mov bx, [bp-4]
    sub bx, [bp-12]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 4: (cx - x, cy - y)
    mov ax, [bp-2]
    sub ax, [bp-10]
    mov bx, [bp-4]
    sub bx, [bp-12]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 5: (cx + y, cy + x)
    mov ax, [bp-2]
    add ax, [bp-12]
    mov bx, [bp-4]
    add bx, [bp-10]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 6: (cx - y, cy + x)
    mov ax, [bp-2]
    sub ax, [bp-12]
    mov bx, [bp-4]
    add bx, [bp-10]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 7: (cx + y, cy - x)
    mov ax, [bp-2]
    add ax, [bp-12]
    mov bx, [bp-4]
    sub bx, [bp-10]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; 8: (cx - y, cy - x)
    mov ax, [bp-2]
    sub ax, [bp-12]
    mov bx, [bp-4]
    sub bx, [bp-10]
    push si
    mov si, [bp-8]
    call drawPixel
    pop si

    ; update decision variable
    mov ax, [bp-14]        ; ax = d
    cmp ax, 0
    jl .d_less_zero
    ; d >= 0  -> d = d + 2*(x - y) + 5 ; y = y - 1
    mov ax, [bp-14]
    mov dx, [bp-10]        ; dx = x
    shl dx, 1              ; dx = 2*x
    mov si, [bp-12]        ; si = y
    shl si, 1              ; si = 2*y
    sub dx, si             ; dx = 2*(x - y)
    add ax, dx
    add ax, 5
    mov [bp-14], ax
    dec word [bp-12]       ; y--
    jmp .d_done

.d_less_zero:
    ; d < 0 -> d = d + 2*x + 3
    mov ax, [bp-14]
    mov dx, [bp-10]        ; dx = x
    shl dx, 1              ; dx = 2*x
    add ax, dx
    add ax, 3
    mov [bp-14], ax

.d_done:
    inc word [bp-10]       ; x++
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


; ------------------------------------------------------------
; drawCircleFilled
; AX = center X
; BX = center Y
; CX = radius
; DL = color (byte)
; Uses: drawHorizontalLine (AX=startX, BX=y, CX=length, SI=color)
; ------------------------------------------------------------
drawCircleFilled:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 16            ; locals same layout as outline
    mov word [bp-2], ax
    mov word [bp-4], bx
    mov word [bp-6], cx
    mov byte [bp-8], dl

    mov word [bp-10], 0         ; x = 0
    mov ax, [bp-6]
    mov word [bp-12], ax        ; y = radius

    mov ax, 1
    sub ax, [bp-6]              ; d = 1 - radius
    mov word [bp-14], ax

.fill_loop:
    ; For each x,y draw horizontal spans:
    ;  span1 at cy - y : from (cx - x) to (cx + x)  length = 2*x + 1
    ;  span2 at cy + y : same
    ;  span3 at cy - x : from (cx - y) to (cx + y)  length = 2*y + 1
    ;  span4 at cy + x : same

    ; compute length1 = 2*x + 1
    mov ax, [bp-10]
    shl ax, 1
    add ax, 1
    mov cx, ax              ; CX = length1

    ; startX = cx_center - x
    mov ax, [bp-2]
    sub ax, [bp-10]
    mov dx, ax              ; DX = startX

    ; yCoord = cy - y
    mov bx, [bp-4]
    sub bx, [bp-12]
    ; call drawHorizontalLine: AX=startX, BX=yCoord, CX=length1, SI=color
    push si
    mov ax, dx
    mov bx, bx
    mov si, [bp-8]
    call drawHorizontalLine
    pop si

    ; lower half: cy + y
    mov bx, [bp-4]
    add bx, [bp-12]
    push si
    mov ax, dx
    mov si, [bp-8]
    call drawHorizontalLine
    pop si

    ; now spans for swapped coords (length2 = 2*y + 1)
    mov ax, [bp-12]
    shl ax, 1
    add ax, 1
    mov cx, ax              ; CX = length2

    ; startX2 = cx_center - y
    mov ax, [bp-2]
    sub ax, [bp-12]
    mov dx, ax              ; DX = startX2

    ; yCoord2 = cy - x
    mov bx, [bp-4]
    sub bx, [bp-10]
    push si
    mov ax, dx
    mov si, [bp-8]
    call drawHorizontalLine
    pop si

    ; lower: cy + x
    mov bx, [bp-4]
    add bx, [bp-10]
    push si
    mov ax, dx
    mov si, [bp-8]
    call drawHorizontalLine
    pop si

    ; update decision variable same as outline
    mov ax, [bp-14]
    cmp ax, 0
    jl .f_d_less_zero
    ; d >= 0
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

; ------------------------------------------------------------
; drawHorizontalLine
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawVerticalLine
; ------------------------------------------------------------
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

; ------------------------------------------------------------
; drawPixel
; ------------------------------------------------------------
drawPixel:
    push ax
    push bx
    push di
    push es
    push dx

    cmp ax, 320
    jae .skip
    cmp bx, 200
    jae .skip

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
    mov [es:di], si

.skip:
    pop dx
    pop es
    pop di
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawText
; ------------------------------------------------------------
drawText:
    push ax
    push bx
    push si
    push dx
    push cx

.char_loop:
    mov cl, byte [si]
    or cl, cl
    jz .done
    
    push ax
    push bx
    push si
    mov si, dx
    mov cx, 5
    mov dx, 7
    call drawFilledRect
    pop si
    pop bx
    pop ax
    
    add ax, 7
    inc si
    jmp .char_loop

.done:
    pop cx
    pop dx
    pop si
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawNumber
; ------------------------------------------------------------
drawNumber:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 12
    
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cl
    mov si, bp
    sub si, 12
    
    mov ax, dx
    mov bx, 10
    mov di, si
    
.convert:
    xor dx, dx
    div bx
    add dl, '0'
    dec di
    mov [di], dl
    test ax, ax
    jnz .convert
    
    mov cx, si
    sub cx, di
    
    mov ax, [bp-2]
    mov bx, [bp-4]
    mov dl, byte [bp-6]

.print_loop:
    push cx
    push ax
    push bx
    push dx
    push di
    
    mov al, byte [di]
    sub al, '0'
    call drawDigit
    
    pop di
    pop dx
    pop bx
    pop ax
    add ax, 8
    inc di
    pop cx
    loop .print_loop
    
    add sp, 12
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawDigit
; ------------------------------------------------------------
drawDigit:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push bp

    mov bp, sp
    sub sp, 6
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], dl
    
    xor ah, ah
    cmp al, 9
    ja .done
    shl ax, 1
    mov si, ax
    mov si, [font_table + si]
    
    mov ax, 0xA000
    mov es, ax
    
    mov cx, 8
    mov bx, [bp-4]
    
.row_loop:
    push cx
    mov al, byte [si]
    mov cx, 7
    mov ax, [bp-2]
    
.bit_loop:
    push cx
    push ax
    
    mov di, bx
    mov dx, 320
    push ax
    mov ax, di
    mul dx
    mov di, ax
    pop ax
    add di, ax
    
    mov al, byte [si]
    mov cl, 7
    push bp
    mov bp, sp
    sub cl, byte [bp+2]
    pop bp
    shl al, cl
    test al, 0x80
    jz .skip_bit
    
    mov al, byte [bp-6]
    mov byte [es:di], al
    
.skip_bit:
    pop ax
    inc ax
    pop cx
    loop .bit_loop
    
    inc si
    inc bx
    pop cx
    loop .row_loop
    
.done:
    add sp, 6
    pop bp
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawTimerValue
; ------------------------------------------------------------
drawTimerValue:
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, ax
    
    mov al, [current_minutes]
    xor ah, ah
    mov dl, COLOR_BLACK
    call drawDigit
    
    add si, 8
    mov ax, si
    mov al, [current_minutes]
    xor ah, ah
    mov cl, 10
    xor ah, ah
    div cl
    mov al, ah
    mov dl, COLOR_BLACK
    call drawDigit
    
    add si, 8
    mov ax, si
    add ax, 2
    add bx, 2
    mov cx, 2
    mov dx, 2
    push si
    mov si, COLOR_BLACK
    call drawFilledRect
    pop si
    add bx, 3
    mov ax, si
    add ax, 2
    mov cx, 2
    mov dx, 2
    push si
    mov si, COLOR_BLACK
    call drawFilledRect
    pop si
    sub bx, 5
    
    add si, 10
    mov ax, si
    mov al, [current_seconds]
    xor ah, ah
    mov cl, 10
    div cl
    mov dl, COLOR_BLACK
    call drawDigit
    
    add si, 8
    mov ax, si
    mov al, [current_seconds]
    xor ah, ah
    mov cl, 10
    div cl
    mov al, ah
    mov dl, COLOR_BLACK
    call drawDigit

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSpeakerIcon
; ------------------------------------------------------------
drawSpeakerIcon:
    push ax
    push bx
    push cx
    push dx
    push si

    sub ax, 6
    sub bx, 4
    mov cx, 5
    mov dx, 8
    mov si, COLOR_WHITE
    call drawFilledRect
    
    add ax, 8
    add bx, 2
    mov cx, 2
    mov dx, 4
    mov si, COLOR_WHITE
    call drawFilledRect

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawPauseIcon
; ------------------------------------------------------------
drawPauseIcon:
    push ax
    push bx
    push cx
    push dx
    push si

    sub ax, 6
    sub bx, 6
    mov cx, 3
    mov dx, 12
    mov si, COLOR_WHITE
    call drawFilledRect
    
    add ax, 6
    mov cx, 3
    mov dx, 12
    mov si, COLOR_WHITE
    call drawFilledRect

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawBalloon
; ------------------------------------------------------------
drawBalloon:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov bp, sp
    sub sp, 8
    mov [bp-2], ax
    mov [bp-4], bx
    mov [bp-6], cl
    mov [bp-8], dl

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 15
    mov cx, 15
    mov dl, byte [bp-6]
    call drawCircleFilled

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 15
    mov cx, 15
    mov dl, COLOR_BLACK
    call drawCircleOutline

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 30
    mov cx, 3
    mov dx, 2
    mov si, [bp-6]
    call drawFilledRect

    mov ax, [bp-2]
    mov bx, [bp-4]
    add bx, 32
    mov dx, BALLOON_STRING_LEN
    mov si, COLOR_BLACK
    call drawVerticalLine

    mov ax, [bp-2]
    sub ax, 4
    mov bx, [bp-4]
    add bx, 12
    mov al, byte [bp-8]
    cmp al, '0'
    jb .draw_as_char
    cmp al, '9'
    ja .draw_as_char
    
    sub al, '0'
    mov dl, COLOR_BLACK
    call drawDigit
    jmp .done

.draw_as_char:
    mov ax, [bp-2]
    sub ax, 3
    mov bx, [bp-4]
    add bx, 12
    mov cx, 6
    mov dx, 8
    mov si, COLOR_BLACK
    call drawFilledRect

.done:
    add sp, 8
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; drawSampleBalloons
; ------------------------------------------------------------
drawSampleBalloons:
    push ax
    push bx
    push cx
    push dx

    mov ax, 80
    mov bx, 100
    mov cl, COLOR_ORANGE
    mov dl, '1'
    call drawBalloon

    mov ax, 130
    mov bx, 140
    mov cl, COLOR_ORANGE
    mov dl, '2'
    call drawBalloon

    mov ax, 200
    mov bx, 70
    mov cl, COLOR_RED
    mov dl, '3'
    call drawBalloon

    mov ax, 260
    mov bx, 110
    mov cl, COLOR_YELLOW
    mov dl, '4'
    call drawBalloon

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================================
; HELPER FUNCTIONS FOR GAME CUSTOMIZATION
; ============================================================

; ------------------------------------------------------------
; updateScore
; ------------------------------------------------------------
updateScore:
    push ax
    mov [current_score], ax
    pop ax
    ret

; ------------------------------------------------------------
; updateTimer
; ------------------------------------------------------------
updateTimer:
    push ax
    mov [current_minutes], al
    mov [current_seconds], ah
    pop ax
    ret

; ------------------------------------------------------------
; toggleSound
; ------------------------------------------------------------
toggleSound:
    push ax
    mov al, [sound_enabled]
    xor al, 1
    mov [sound_enabled], al
    pop ax
    ret

; ------------------------------------------------------------
; togglePause
; ------------------------------------------------------------
togglePause:
    push ax
    mov al, [game_paused]
    xor al, 1
    mov [game_paused], al
    pop ax
    ret

; ------------------------------------------------------------
; drawCustomBalloon
; ------------------------------------------------------------
drawCustomBalloon:
    call drawBalloon
    ret

; ------------------------------------------------------------
; clearGameArea
; ------------------------------------------------------------
clearGameArea:
    push si
    mov si, COLOR_BLACK
    call drawFilledRect
    pop si
    ret

; ------------------------------------------------------------
; refreshUI
; ------------------------------------------------------------
refreshUI:
    call drawScorePanel
    call drawTimerPanel
    ret

; ------------------------------------------------------------
; getScore
; ------------------------------------------------------------
getScore:
    mov ax, [current_score]
    ret

; ------------------------------------------------------------
; getTimerMinutes
; ------------------------------------------------------------
getTimerMinutes:
    mov al, [current_minutes]
    ret

; ------------------------------------------------------------
; getTimerSeconds
; ------------------------------------------------------------
getTimerSeconds:
    mov al, [current_seconds]
    ret

; ------------------------------------------------------------
; isSoundEnabled
; ------------------------------------------------------------
isSoundEnabled:
    mov al, [sound_enabled]
    ret

; ------------------------------------------------------------
; isGamePaused
; ------------------------------------------------------------
isGamePaused:
    mov al, [game_paused]
    ret

; ============================================================
; END OF main_game_screen.asm
; ============================================================
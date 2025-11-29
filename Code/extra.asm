; ------------------------------------------------------------
; display_palette_wide
; ------------------------------------------------------------
; EFFECT:
;   Prints 256 colors as wide strips (160 pixels each)
; ------------------------------------------------------------
    
; ------------------------------------------------------------
; Data Segment (Variables)
; ------------------------------------------------------------
    HISTOGRAM_ARRAY DW 256 DUP(0) ; 512 bytes for 256 WORD counters
    
    ; Label to save the result
    LEAST_FREQUENT_COLOR DB 0     ; 8-bit index of the least frequent color
    
    ; Label to save the lowest count found (initialized high)
    MIN_FREQUENCY     DW 64001    ; Start higher than the max possible pixel count (64000)

; ------------------------------------------------------------
; findLeastFrequentColor
; ------------------------------------------------------------
; INPUT:
;   DS:SI points to the start of the HISTOGRAM_ARRAY
; OUTPUT:
;   LEAST_FREQUENT_COLOR is updated with the index (0-255)
;   MIN_FREQUENCY is updated with the lowest count
; EFFECT:
;   Traverses the histogram array to find the minimum non-zero count.
; ------------------------------------------------------------
findLeastFrequentColor:
    PUSH AX
    PUSH CX
    PUSH DI
    PUSH SI
    
    ; Initialize registers
    MOV CX, 256         ; CX = Outer loop counter (256 color indices)
    
    ; Set the pointers for the Histogram Array
    ; Assuming DS is already set to the Data Segment
    MOV SI, [HISTOGRAM_ARRAY] ; SI points to the start of the histogram
    
    ; Load initial minimum values from data
    MOV AX, [MIN_FREQUENCY]      ; AX = Current lowest count (64001)
    
    ; Note: The color index is implicitly tracked by CX/DI/SI manipulation
    
color_check_loop:
    ; DI now holds the current color index (0, 1, 2, ...)
    ; The loop counter CX is decremented from 256 down to 1.
    ; Current index is 256 - CX

    ; Load the current color's frequency count (WORD) into BX
    MOV BX, [SI]         ; BX = Frequency count for the current color index

    ; 1. Check if the count is zero (i.e., the color is unused)
    CMP BX, 0
    JE skip_update       ; If count is 0, skip to the next color (don't use unused color)

    ; 2. Compare the new frequency (BX) with the old minimum frequency (AX)
    CMP BX, AX           ; Is new frequency < old minimum frequency?
    JGE skip_update      ; If new >= old, skip update

    ; --- Update Found! (BX < AX) ---
    
    MOV AX, BX           ; Update MIN_FREQUENCY: AX = BX (new lowest count)
    
    ; Calculate the current color index (Index = 256 - CX)
    MOV DI, 256          ; DI = 256
    SUB DI, CX           ; DI = 256 - CX (The current color index)
    
    ; Store the color index
    MOV AL, DL           ; Clear AH (AL is fine for byte store)
    MOV AX, DI           ; AL = Current color index (0-255)
    MOV [LEAST_FREQUENT_COLOR], AL ; Save the new least frequent color index
    MOV [MIN_FREQUENCY], AX      ; Save the new minimum frequency count

skip_update:
    ADD SI, 2            ; Move SI to the next WORD in the histogram
    LOOP color_check_loop ; Decrement CX, loop if CX != 0

    POP SI
    POP DI
    POP CX
    POP AX
    RET
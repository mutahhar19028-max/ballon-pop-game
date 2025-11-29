%define MENU_BUTTON_WIDTH 85
%define MENU_BUTTON_HEIGHT 23
%define MENU_BUTTON_X 120
%define MENU_BUTTON_Y 80

DISP : dw 0

title_text:         db "BALLOON GAME",0
menu_play:          db "PLAY",0
menu_help:          db "HELP",0
menu_exit:          db "EXIT",0
instruction_text:   db "Press ENTER to Select",0

dt_x_pos    dw 0
dt_y_pos    dw 0
dt_color    db 0
dt_scale    db 0
temp_width  dw 0
temp_height dw 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;PAUSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ============================================================
; pause_screen.asm — Enhanced Pause Overlay with Animations
; ============================================================
; NOTE: Add these NEW FUNCTIONS to ui.asm for reusability:
;   - drawGradientRect     (AX=x, BX=y, CX=width, DX=height, SI=color1, DI=color2)
;   - drawTextCentered     (DS:SI -> string, BX=y, AL=color) [auto-centers on screen]
;   - drawMenuOption       (AX=x, BX=y, DS:SI -> string, AL=color, DL=selected_flag)
;   - drawDarkenOverlay    (AL=darkness_level 0-3) [darkens entire screen]
;   - drawPulseEffect      (frame_counter -> returns pulsing color in AL)
;
; Call showPauseScreen from main game loop when pause key pressed
; ============================================================

; ------------------------------------------------------------
; CONFIGURATION CONSTANTS
; ------------------------------------------------------------

; === COLORS ===
%define PAUSE_PANEL_COLOR       [light_orange]    ; Dark blue
%define PAUSE_BORDER_COLOR      [dark_orange]    ; Cyan
%define PAUSE_TITLE_COLOR       [dark_brown]

; === PANEL DIMENSIONS ===
%define PAUSE_PANEL_WIDTH       180
%define PAUSE_PANEL_HEIGHT      140
%define PAUSE_PANEL_X           ((320 - PAUSE_PANEL_WIDTH) / 2)
%define PAUSE_PANEL_Y           ((200 - PAUSE_PANEL_HEIGHT) / 2)

; === TITLE POSITIONING ===
%define PAUSE_TITLE_Y           (PAUSE_PANEL_Y + 20)

; === MENU POSITIONING ===
%define MENU_START_Y            (PAUSE_PANEL_Y + 55)
%define MENU_SPACING            18
%define MENU_OPTION_X           (PAUSE_PANEL_X + 30)

%define PAUSE_MENU_BUTTON_WIDTH     120
%define PAUSE_MENU_BUTTON_HEIGHT    20
%define PAUSE_MENU_BUTTON_X         PAUSE_PANEL_X + 30
%define PAUSE_MENU_BUTTON_Y         PAUSE_PANEL_Y + PAUSE_PANEL_HEIGHT / 3

; ------------------------------------------------------------
; DATA SECTION
; ------------------------------------------------------------

pause_title         db "PAUSED", 0
menu_resume         db "RESUME(ESC)", 0
menu_restart        db "RESTART(R)", 0
;menu_quit           db "QUIT(Q)", 0 [common in pause and game over]

DIST : dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;GAMEOVER;;;;;;;;;;;;;;;;;;;;;;;;;;

; ============================================================
; gameover_screen.asm — Epic Game Over Screen with Animations
; ============================================================
; NOTE: Add these NEW FUNCTIONS to ui.asm for reusability:
;   - drawFadeEffect       (AL=fade_level 0-15) [fades screen to color]
;   - drawShadowText       (DS:SI -> string, BX=y, AL=color, DL=shadow_offset)
;   - drawExplosionParticle(AX=x, BX=y, CL=size, DL=color)
;   - drawScoreBreakdown   (AX=x, BX=y, DX=score, AL=color)
;   - drawPressKeyPrompt   (BX=y, AL=blink_state)
;   - drawStatBar          (AX=x, BX=y, CX=width, DX=value, SI=max_value, DI=color)
;
; Call showGameOverScreen when game ends (player loses/wins)
; ============================================================

; ------------------------------------------------------------
; CONFIGURATION CONSTANTS
; ------------------------------------------------------------

; === COLORS ===
%define GAMEOVER_PANEL_COLOR       [light_orange]    ; Dark blue
%define GAMEOVER_BORDER_COLOR      [dark_orange]    ; Cyan
%define GAMEOVER_TITLE_COLOR       [dark_brown]

; === PANEL DIMENSIONS ===
%define GAMEOVER_PANEL_WIDTH       180
%define GAMEOVER_PANEL_HEIGHT      170
%define GAMEOVER_PANEL_X           ((320 - PAUSE_PANEL_WIDTH) / 2)
%define GAMEOVER_PANEL_Y           (200 - GAMEOVER_PANEL_HEIGHT) / 2

%define GAMEOVER_MENU_BUTTON_WIDTH     120
%define GAMEOVER_MENU_BUTTON_HEIGHT    20
%define GAMEOVER_MENU_BUTTON_X         PAUSE_PANEL_X + 30
%define GAMEOVER_MENU_BUTTON_Y         PAUSE_PANEL_Y + PAUSE_PANEL_HEIGHT / 4
; ------------------------------------------------------------
; DATA SECTION
; ------------------------------------------------------------

gameover_title      db "GAMEOVER", 0
stats_score_label   db "SCORE: 120", 0
stats_time_label    db "TIME:12:33", 0
stats_balloons_label db "BALLOONS:", 0
menu_retry          db " RETRY(R)", 0
menu_quit           db "  QUIT(Q)", 0

; Game stats (populated by main game before calling)
final_score         dw 120
final_minutes       db 3
final_seconds       db 12
balloons_popped     dw 111
balloons_missed     dw 5

DIS : dw 0

;;;;;;;;;;;;;;;;;;;;MAIN GAME SCREEN;;;;;;;;;;;;;;;;;;;;;;;;;;
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
%define BOX_WIDTH 90
%define BOX_HEIGHT 20
%define BASE_RADIUS 10

; === SCORE PANEL ===
%define SCORE_PANEL_X       (MAX_WIDTH / 2) -  (SCORE_PANEL_WIDTH / 2) - 8 * PADDING
%define SCORE_PANEL_Y       2 * PADDING
%define SCORE_PANEL_WIDTH   BOX_WIDTH
%define SCORE_PANEL_HEIGHT  BOX_HEIGHT
%define SCORE_PANEL_COLOR   [light_orange]
%define SCORE_BORDER_COLOR  [dark_orange]
%define SCORE_TEXT_X        (SCORE_PANEL_X + (SCORE_PANEL_WIDTH / 16)) + PADDING
%define SCORE_TEXT_Y        ((SCORE_PANEL_Y + SCORE_PANEL_HEIGHT) / 2) - PADDING
%define SCORE_VALUE_X       ((SCORE_PANEL_X + (SCORE_PANEL_WIDTH / 2)) + (SCORE_PANEL_WIDTH / 3))
%define SCORE_VALUE_Y       ((SCORE_PANEL_Y + SCORE_PANEL_HEIGHT) / 2)

; === TIMER PANEL ===
%define TIMER_PANEL_X       MAX_WIDTH - (TIMER_PANEL_WIDTH + 3 * PADDING)
%define TIMER_PANEL_Y       2 * PADDING
%define TIMER_PANEL_WIDTH   BOX_WIDTH + 15
%define TIMER_PANEL_HEIGHT  BOX_HEIGHT
%define TIMER_PANEL_COLOR   [light_orange]
%define TIMER_BORDER_COLOR  [dark_orange]
%define TIMER_TEXT_X        TIMER_PANEL_X + 4 * PADDING
%define TIMER_TEXT_Y        ((TIMER_PANEL_Y + TIMER_PANEL_HEIGHT) / 2) - PADDING
%define TIMER_VALUE_X       TIMER_PANEL_X 
%define TIMER_VALUE_Y       ((TIMER_PANEL_Y + TIMER_PANEL_HEIGHT) / 2)

; === SOUND BUTTON ===
%define SOUND_BTN_RADIUS    BASE_RADIUS
%define SOUND_BTN_X         PADDING + ((SOUND_BTN_RADIUS / 2) + SOUND_BTN_RADIUS)
%define SOUND_BTN_Y         ((PADDING / 2) + PADDING) + SOUND_BTN_RADIUS
%define SOUND_BTN_COLOR     [light_orange]
%define SOUND_BTN_BORDER    [dark_orange]

; === PAUSE BUTTON ===
%define PAUSE_BTN_RADIUS    BASE_RADIUS
%define PAUSE_BTN_X         SOUND_BTN_X + (((SOUND_BTN_RADIUS / 2) + SOUND_BTN_RADIUS) + PADDING + PAUSE_BTN_RADIUS)
%define PAUSE_BTN_Y         ((PADDING / 2) + PADDING) + PAUSE_BTN_RADIUS
%define PAUSE_BTN_COLOR     [light_orange]
%define PAUSE_BTN_BORDER    [dark_brown]

; === BALLOONS ===
%define BALLOON_WIDTH       30
%define BALLOON_HEIGHT      40
%define BALLOON_STRING_LEN  18

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

score_label         db "SCORE:120", 0
timer_label         db "TIME:12:33", 0

temp_color  db 0    ; Temporary storage for circle fill color

; ============================================================
; NAVIGATION CONSTANTS
; ============================================================
%define MENU_OPTION_PLAY    0
%define MENU_OPTION_HELP    1
%define MENU_OPTION_EXIT    2
%define TOTAL_MENU_OPTIONS  3

; Arrow indicator position
%define ARROW_X_OFFSET      100
%define ARROW_FIRST_Y       (MENU_BUTTON_Y + 8)

; Keyboard scan codes
%define KEY_UP              0x48
%define KEY_DOWN            0x50
%define KEY_ENTER           0x1C
%define KEY_ESC             0x01

; Game states
%define STATE_MENU          0
%define STATE_GAME          1
%define STATE_PAUSE         2
%define STATE_GAMEOVER      3
%define STATE_EXIT          4

; Global variables
current_selection   db 0        ; Currently selected menu option (0-2)
game_state          db STATE_MENU
# 🎈 Balloon Typing Game

A fast-paced typing game written in x86 Assembly Language for DOS/DOSBox. Pop rising balloons by typing their letters before time runs out!

![Platform](https://img.shields.io/badge/Platform-DOS%2FDOSBox-blue)
![Architecture](https://img.shields.io/badge/Architecture-x86%20(8086)-green)
![Language](https://img.shields.io/badge/Language-Assembly%20(NASM)-red)
![Graphics](https://img.shields.io/badge/Graphics-VGA%20Mode%2013h-orange)

---

## 📋 Project Information

**Course:** EE2003 - Computer Organisation and Assembly Language  
**Institution:** FAST NUCES 
**Instructor:** Aleena Ahmed  
**Semester:** 3rd

---

## 🎮 Game Overview

### Objective
Type letters on rising balloons to pop them and earn points within a 2-minute time limit. Test your typing speed and accuracy while experiencing low-level graphics and sound programming!

### Game Rules
- **Timer:** 2 minutes (120 seconds) to play
- **Scoring:** Each popped balloon awards 10 points
- **Controls:** Type A-Z letters to pop matching balloons
- **Penalty:** Balloons that reach the top trigger an error sound
- **Goal:** Maximize your score before time expires

---

## 🎯 Features

### Core Gameplay
✅ Random balloon spawning with letters A-Z  
✅ Smooth upward balloon movement  
✅ Real-time collision detection  
✅ 2-minute countdown timer  
✅ Score tracking and display  

### Graphics & UI
✅ VGA Mode 13h (320×200, 256 colors)  
✅ Custom color palette  
✅ Background image support  
✅ Rounded UI panels  
✅ Custom font rendering (8×8 BIOS font)  
✅ Main menu with navigation  
✅ Pause screen  
✅ Game over screen with statistics  

### Technical Features
✅ Background buffering system (flicker-free rendering)  
✅ VSync synchronization  
✅ Custom timer interrupt (INT 1Ch ISR)  
✅ PC Speaker sound effects  
✅ 24-note musical score  
✅ Linear Congruential Generator for randomness  
✅ Non-blocking keyboard input  

---

## 🖥️ Technical Specifications

### Hardware Requirements
- **Processor:** Intel 8088/8086 (16-bit real mode)
- **Memory:** Minimum 64KB RAM
- **Graphics:** VGA-compatible adapter
- **Sound:** PC Speaker
- **Input:** PC Keyboard

### Software Requirements
- **Operating System:** DOS or DOSBox emulator
- **Assembler:** NASM (Netwide Assembler)
- **Execution Format:** COM file (ORG 0x100)

### Graphics Specifications
- **Mode:** VGA Mode 13h
- **Resolution:** 320×200 pixels
- **Color Depth:** 8-bit indexed (256 colors)
- **Memory Segment:** 0xA000
- **Palette:** Custom 768-byte palette (palette.bin)
- **Background:** Raw image file (imgData.raw)

---

## 🗂️ Project Structure

```
Project Root/
├── mainRunner.asm              # Entry point and game loop
├── Code/
│   ├── font.asm               # 8×8 BIOS font data
│   ├── colors.asm             # Color palette definitions
│   ├── ui.asm                 # Drawing primitives (circles, rectangles, text)
│   ├── constants.asm          # Game constants and macros
│   ├── timer.asm              # Timer ISR implementation
│   ├── sound.asm              # Basic PC speaker functions
│   ├── sound2.asm             # Musical score system
│   ├── show_bg.asm            # Background image loader
│   ├── navigation.asm         # Menu navigation system
│   ├── main_menu.asm          # Main menu screen
│   ├── main_game_screen.asm   # In-game UI components
│   ├── pause_screen.asm       # Pause overlay
│   ├── game_over_screen.asm   # Game over screen
│   ├── balloon_system.asm     # Balloon logic (spawn, move, collision)
│   └── balloon.asm            # Balloon rendering
├── palette.bin                # 256-color VGA palette (768 bytes)
├── imgData.raw                # Background image (320×200 raw pixels)
└── README.md                  # This file
```

---

## 🔨 Compilation & Execution

### Compile
```bash
nasm -f bin mainRunner.asm -o BALLOON.COM
```

### Run in DOSBox
```bash
# Mount directory containing BALLOON.COM
mount c /path/to/project
c:
BALLOON.COM
```

### Run on Real DOS
Simply execute `BALLOON.COM` from the project directory.

---

## 🎮 Controls

### Main Menu
- **↑/↓ Arrow Keys** - Navigate menu options
- **Enter** - Select highlighted option
- **ESC** - Exit game

### Gameplay
- **A-Z Keys** - Type letter to pop matching balloon
- **ESC** - Pause game

### Pause Screen
- **ESC** - Resume game
- **R** - Restart game
- **Q** - Quit to main menu

### Game Over Screen
- **R** - Retry (restart game)
- **Q** - Quit to main menu

---

## 🎨 Game Architecture

### State Machine
```
START → MENU → GAME → PAUSE → GAME
                ↓       ↓
            GAMEOVER → MENU
                ↓
               EXIT
```

### Game States
1. **STATE_MENU (0)** - Main menu screen
2. **STATE_GAME (1)** - Active gameplay
3. **STATE_PAUSE (2)** - Game paused
4. **STATE_GAMEOVER (3)** - Timer expired
5. **STATE_HELP (5)** - Instructions
6. **STATE_EXIT (4)** - Program termination

---

## 🎈 Balloon System

### Balloon Specifications
- **Size:** 24 pixels wide × 21 pixels tall
- **Components:** Oval body + knot + string
- **Colors:** 8 vibrant colors (yellow, orange, cyan, green, blue, brown)
- **Letters:** Random A-Z assignment
- **Max Active:** 3 balloons simultaneously

### Data Structure (16 bytes per balloon)
```
Offset | Size | Field
-------+------+---------------------------
+0     | 2    | x_position (30-286 pixels)
+2     | 2    | y_position (0-186 pixels)
+4     | 1    | letter (ASCII 'A'-'Z')
+5     | 1    | color_index (0-7)
+6     | 1    | active_flag (0=inactive, 1=active)
+7     | 1    | speed (pixels per move)
+8     | 2    | buffer_offset (pointer to background buffer)
+10-15 | 6    | Reserved
```

### Movement Mechanics
- **Direction:** Upward (Y decreases)
- **Speed:** 1 pixel per move
- **Delay:** Moves every 100 frames (~5.5 seconds to cross screen)
- **Spawn Rate:** New balloon every 40 frames (~2 seconds)
- **Despawn:** Y < 40 (top limit)

### Background Buffering
- **Purpose:** Eliminate flicker and screen tearing
- **Buffer Size:** 504 bytes per balloon (24×21 pixels)
- **Algorithm:**
  1. Save background pixels before drawing
  2. Restore pixels before moving (erase old balloon)
  3. Draw balloon at new position

---

## ⏱️ Timer System

### Implementation
- **Interrupt:** Custom INT 1Ch ISR (timer tick)
- **Frequency:** ~18.2 Hz (every 55ms)
- **Duration:** 2 minutes (120 seconds)
- **Display Format:** MM:SS (e.g., "02:00", "01:23")
- **Update:** Real-time countdown via ISR

### ISR Behavior
1. Increment tick counter
2. Every 18 ticks (~1 second):
   - Decrement seconds
   - Update display variables
   - Handle minute rollover
3. Chain to original timer ISR
4. Return from interrupt

---

## 🔊 Sound System

### PC Speaker Implementation
- **Hardware:** Programmable Interval Timer (PIT) Channel 2
- **Ports:** 43h (control), 42h (frequency), 61h (speaker gate)
- **Frequency Formula:** `freq = 1193180 / divisor`

### Sound Effects
1. **Startup Melody** - 24-note musical sequence
2. **Pop Sound** - Quick descending tone (balloon hit)
3. **Error Sound** - Low beep (balloon escaped)

---

## 🎯 Scoring System

- **Pop Balloon:** +10 points
- **Escaped Balloon:** 0 points (error sound plays)
- **Display:** Real-time score panel (top-left)
- **Format:** "SCORE: ####" (4-digit display)

---

## 🖼️ Graphics System

### Drawing Primitives
- **Pixels:** Direct VGA memory write (0xA000:offset)
- **Lines:** Horizontal and vertical line algorithms
- **Rectangles:** Filled and outlined variants
- **Circles:** Midpoint circle algorithm (filled and outlined)
- **Text:** 8×8 BIOS font with scalable rendering
- **Rounded Rectangles:** 2-pixel corner radius

### Color Palette
Custom 256-color palette loaded from `palette.bin`:
- Format: 256 colors × 3 bytes (RGB)
- Range: 0-63 per channel
- Loaded via VGA DAC ports (3C8h, 3C9h)

---

## 🧮 Random Number Generation

### Algorithm
Linear Congruential Generator (LCG)
```
Formula: next = (25173 × seed + 13849) mod 65536
Seed: System timer (INT 1Ah)
```

### Usage
- **Spawn Position:** Random X coordinate (30-286)
- **Letter:** Random A-Z (modulo 26)
- **Color:** Random palette index (modulo 8)

---

## 🔧 Performance Optimizations

### VSync Synchronization
Waits for vertical retrace period to eliminate tearing:
```assembly
; Port 3DAh: VGA status register
; Bit 3: Vertical retrace active
```

### Memory Efficiency
- Compact 16-byte balloon structure
- Sequential buffer access
- Minimal branching in hot paths

### Drawing Order
1. Update balloon positions (logic)
2. Render balloons (graphics)
3. Draw UI panels (overlay)

---

## 📊 Statistics Tracked

- **Current Score** - Real-time display
- **Final Score** - Saved on game over
- **Time Remaining** - Countdown display
- **Balloons Popped** - Internal counter
- **Balloons Escaped** - Triggers error sound

---

## 🐛 Known Issues & Limitations

### Current Limitations
- Maximum x simultaneous balloons (adjustable via `MAX_BALLOONS`)
- Fixed 2-minute time limit
- Single difficulty level
- No high score persistence

### Technical Notes
- Requires `palette.bin` and `imgData.raw` in same directory
- COM format limits total size to ~64KB
- Real mode memory addressing only
- PC speaker sound may not work in all emulators

---

## 📚 Key Concepts Demonstrated

### Assembly Programming
✅ 16-bit real mode programming  
✅ Segment:offset memory addressing  
✅ Register optimization  
✅ Stack frame management  
✅ Procedure calling conventions  

### Hardware Interfacing
✅ VGA Mode 13h direct memory access  
✅ Interrupt vector table manipulation  
✅ ISR implementation and chaining  
✅ PC Speaker (PIT) programming  
✅ Keyboard input via BIOS interrupts  

### Algorithms & Data Structures
✅ State machine design  
✅ Circular buffer for balloons  
✅ Background buffering technique  
✅ Midpoint circle algorithm  
✅ Linear Congruential Generator (LCG)  
✅ Collision detection (letter matching)  

### System Programming
✅ Custom interrupt handlers  
✅ Non-blocking I/O  
✅ Real-time graphics rendering  
✅ File I/O for assets (palette, image)  
✅ Memory segmentation  

---

## 📄 License

This project is created for educational purposes as part of the EE2003 course curriculum.

---

*Last Updated: December 2024*

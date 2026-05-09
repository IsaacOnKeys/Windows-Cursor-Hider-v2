# Windows-Cursor-Hider-v2
Windows cursor-hider for AutoHotkey v2. Hides the pointer while typing and restores the user’s current cursor scheme on mouse movement.

This is an AutoHotkey v2-compatible update based on Stefan Z Camilleri's Windows Cursor Hider.

## Improvements

- Compatible with AutoHotkey v2.
- Restores the real Windows cursor scheme using SPI_SETCURSORS.
- Avoids fuzzy/low-resolution cursor restoration caused by copied cursor handles.
- Restores the cursor when mouse movement occurs on either axis.
- Adds common typing/navigation keys such as Space, Backspace, Enter, Tab, arrows, Home/End, PgUp/PgDn, Esc.

## Usage

1. Install AutoHotkey v2.
2. Run `cursor_hider_v2.ahk`.
3. Type to hide the cursor.
4. Move the mouse to restore it.

## Attribution

Original script by Stefan Z Camilleri.

This version was updated for AutoHotkey v2 and modified to better preserve the user's Windows cursor appearance.

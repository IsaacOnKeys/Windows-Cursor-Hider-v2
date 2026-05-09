; AutoHotkey Version: 2.x
; Language:       English
; Platform:       Windows
; Original Author: Stefan Z Camilleri - stefan@camilleri.me
; Updated for AutoHotkey v2 syntax
; Modified to restore the real Windows cursor scheme instead of restoring copied cursor handles

#Requires AutoHotkey v2.0
#SingleInstance Force

; Keep the script running so timers and hotkeys stay active.
Persistent()

; Recommended for new scripts due to its superior speed and reliability.
SendMode("Input")

; Ensures a consistent starting directory.
SetWorkingDir(A_ScriptDir)

; Ensure the cursor is made visible when the script exits.
OnExit(ShowCursor)

; Track whether the cursor is currently hidden.
global cursorHidden := false

; Initialize the mouse cursor.
SystemCursor("Init")

; Get the current mouse position, and store its coordinates.
global mX0 := 0
global mY0 := 0
MouseGetPos(&mX0, &mY0)

; Set a timer to check if the mouse has moved every 250ms.
SetTimer(CheckIdle, 250)

; Register the ordinary character keys you want to listen on.
keys := "``1234567890-=qwertyuiop[]\asdfghjkl;'zxcvbnm,./"

; For every defined character key, register a call to hide the mouse cursor.
Loop Parse keys
{
    Hotkey("~*" A_LoopField, Hoty)
}

; Register named keys useful while typing/coding.
extraKeys := [
    "Space",
    "Backspace",
    "Enter",
    "Tab",
    "Delete",
    "Left",
    "Right",
    "Up",
    "Down",
    "Home",
    "End",
    "PgUp",
    "PgDn",
    "Esc"
]

; For every named key, register a call to hide the mouse cursor.
for _, key in extraKeys
{
    Hotkey("~*" key, Hoty)
}

return


; Checks if the mouse has moved, and if so, shows it and records the new position.
CheckIdle()
{
    global mX0, mY0, cursorHidden

    MouseGetPos(&mX, &mY)

    ; Use OR here, not AND: movement on either axis should restore the cursor.
    if (mX0 != mX || mY0 != mY)
    {
        if (cursorHidden)
        {
            SystemCursor("On")
            cursorHidden := false
        }

        mX0 := mX
        mY0 := mY
    }
}


; Hides the mouse cursor.
Hoty(*)
{
    global cursorHidden

    if (!cursorHidden)
    {
        SystemCursor("Off")
        cursorHidden := true
    }
}


; Shows the mouse cursor before exiting.
ShowCursor(*)
{
    global cursorHidden

    SystemCursor("On")
    cursorHidden := false
}


; Function to hide or show the mouse cursor.
SystemCursor(OnOff := 1)   ; INIT = "I","Init"; OFF = 0,"Off"; ON = others
{
    static initialized := false

    ; System cursors.
    static systemCursors := [
        32512,  ; OCR_NORMAL
        32513,  ; OCR_IBEAM
        32514,  ; OCR_WAIT
        32515,  ; OCR_CROSS
        32516,  ; OCR_UP
        32642,  ; OCR_SIZENWSE
        32643,  ; OCR_SIZENESW
        32644,  ; OCR_SIZEWE
        32645,  ; OCR_SIZENS
        32646,  ; OCR_SIZEALL
        32648,  ; OCR_NO
        32649,  ; OCR_HAND
        32650   ; OCR_APPSTARTING
    ]

    ; Blank cursors.
    static blankCursors := []

    ; Cursor mask buffers.
    static andMask := unset
    static xorMask := unset

    if (!initialized)
    {
        ; Use the system cursor dimensions instead of hard-coding 32x32.
        cursorW := DllCall("GetSystemMetrics", "Int", 13, "Int")  ; SM_CXCURSOR
        cursorH := DllCall("GetSystemMetrics", "Int", 14, "Int")  ; SM_CYCURSOR

        ; 1-bit masks sized for the cursor dimensions.
        maskBytes := ((cursorW + 31) // 32) * 4 * cursorH

        andMask := Buffer(maskBytes, 0xFF)
        xorMask := Buffer(maskBytes, 0)

        blankCursors := []

        for _, cursorId in systemCursors
        {
            ; Create a blank cursor.
            blankCursors.Push(DllCall("CreateCursor"
                , "Ptr", 0
                , "Int", 0
                , "Int", 0
                , "Int", cursorW
                , "Int", cursorH
                , "Ptr", andMask.Ptr
                , "Ptr", xorMask.Ptr
                , "Ptr"))
        }

        initialized := true
    }

    ; Init only prepares the blank cursors. It should not alter the visible cursor.
    if (OnOff = "Init" || OnOff = "I")
        return

    ; Hide cursor by replacing system cursors with blank cursors.
    if (OnOff = 0 || OnOff = "Off")
    {
        for index, cursorId in systemCursors
        {
            hCursor := DllCall("CopyImage"
                , "Ptr", blankCursors[index]
                , "UInt", 2
                , "Int", 0
                , "Int", 0
                , "UInt", 0
                , "Ptr")

            DllCall("SetSystemCursor"
                , "Ptr", hCursor
                , "UInt", cursorId)
        }
    }
    else
    {
        ; Restore the real current Windows cursor scheme.
        ; This avoids restoring fuzzy, low-resolution copied cursor handles.
        DllCall("SystemParametersInfo"
            , "UInt", 0x0057   ; SPI_SETCURSORS
            , "UInt", 0
            , "Ptr", 0
            , "UInt", 0)
    }
}
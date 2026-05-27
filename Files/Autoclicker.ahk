#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Screen"
SendMode "Event"

; Get screen resolution
ScreenWidth := A_ScreenWidth
ScreenHeight := A_ScreenHeight

; Determine click coordinates based on resolution
if (ScreenWidth = 1680 and ScreenHeight = 1050) {
    clickX := 842
    clickY := 600
} else if (ScreenWidth = 1920 and ScreenHeight = 1080) {
    clickX := 930
    clickY := 595
} else {
    ; Default fallback or calculate proportionally
    ; Option 1: Throw error or use default
    MsgBox "Unsupported resolution: " ScreenWidth "x" ScreenHeight "`nPlease add coordinates for this resolution."
    ExitApp
    
    ; Option 2: Calculate proportionally from 1920x1080 base
    ; clickX := Round(955 * (ScreenWidth / 1920))
    ; clickY := Round(636 * (ScreenHeight / 1080))
}

flagFile  := A_Temp "\clicking.flag"
pauseFile := A_Temp "\pause.flag"
speedFile := A_Temp "\speed.txt"

delay := 30

FileAppend("running", flagFile)

; ─────────────────────────────────────────
; MAIN LOOP
; ─────────────────────────────────────────
Loop {

    ; stop signal from main script
    if !FileExist(flagFile)
        break

    ; pause support
    if FileExist(pauseFile) {
        Sleep 50
        continue
    }

    Click clickX, clickY

    ; optional dynamic speed
    if FileExist(speedFile) {
        try delay := Integer(Trim(FileRead(speedFile)))
    }

    Sleep delay
}
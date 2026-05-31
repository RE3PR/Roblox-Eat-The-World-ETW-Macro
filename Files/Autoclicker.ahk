#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Screen"
SendMode "Event"

flagFile  := A_Temp "\clicking.flag"
pauseFile := A_Temp "\pause.flag"
speedFile := A_Temp "\speed.txt"

; Get screen resolution
ScreenWidth := A_ScreenWidth
ScreenHeight := A_ScreenHeight

; Determine click coordinates
if (ScreenWidth = 1680 && ScreenHeight = 1050) {
    clickX := 842
    clickY := 600
}
else if (ScreenWidth = 1920 && ScreenHeight = 1080) {
    clickX := 930
    clickY := 595
}
else {
    FileAppend(
        A_Now " Unsupported resolution: "
        ScreenWidth "x" ScreenHeight "`n",
        A_Temp "\autoclicker_debug.txt"
    )
    ExitApp
}

delay := 30

; Create startup flag
try {
    if FileExist(flagFile)
        FileDelete(flagFile)

    FileAppend(A_TickCount, flagFile)
}
catch Error as e {
    FileAppend(
        A_Now " Failed to create flag: "
        e.Message "`n",
        A_Temp "\autoclicker_debug.txt"
    )
    ExitApp
}

; Debug startup log
FileAppend(
    A_Now " Started successfully`n",
    A_Temp "\autoclicker_debug.txt"
)

; Main click loop
Loop {

    ; Stop signal
    if !FileExist(flagFile)
        break

    ; Pause support
    if FileExist(pauseFile) {
        Sleep 50
        continue
    }

    Click clickX, clickY

    ; Dynamic speed
    if FileExist(speedFile) {
        try delay := Integer(Trim(FileRead(speedFile)))
    }

    Sleep delay
}

; Cleanup
try FileDelete(flagFile)

ExitApp

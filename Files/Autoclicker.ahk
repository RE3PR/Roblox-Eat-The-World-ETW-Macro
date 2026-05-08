#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Screen"
SendMode "Event"

clickX := 842
clickY := 600

flagFile  := A_Temp "\clicking.flag"
pauseFile := A_Temp "\pause.flag"
speedFile := A_Temp "\speed.txt"

delay := 30

FileAppend("running", flagFile)

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

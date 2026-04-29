; Copyright (C) 2026 Your Name
; Licensed under GPL-3.0-or-later
; See LICENSE file for full license details


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

Loop {
  
    if !FileExist(flagFile)
        break

    if FileExist(pauseFile) {
        Sleep 50
        continue
    }

    if FileExist(speedFile) {
        try delay := Integer(FileRead(speedFile))
    }

    Click clickX, clickY

    Loop 5 {
        if !FileExist(flagFile)
            break 2
        if FileExist(pauseFile)
            break
        Sleep delay // 5
    }
}

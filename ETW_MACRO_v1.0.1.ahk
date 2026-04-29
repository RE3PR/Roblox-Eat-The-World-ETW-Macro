; Copyright (C) 2026 Your Name
; Licensed under GPL-3.0-or-later
; See LICENSE file for full license details


#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
SendMode "Event"

#Include Gdip_All.ahk

if !pToken := Gdip_Startup() {
    MsgBox "GDI+ failed to start"
    ExitApp()
}
global lastOCR := ""
global stableStart := 0
global isPaused := false
global lastPauseTime := 0

flagFile  := A_Temp "\clicking.flag"
pauseFile := A_Temp "\pause.flag"
speedFile := A_Temp "\speed.txt"
global lastOCR := ""
global stableStart := 0
global isPaused := false
global privateLink := ""
global ExitKey := "o"
global PauseKey := "p"
global Language := "English"
global DeviceType := "Windows"
global UpgradeSystem := "Size"
global RatioValue :=  5.5
global Browser := "Google Chrome"
global map_Studville := 0
global map_MiddleRobloxia := 0
global map_BlockTown := 1
global map_MegaGrid := 1
global map_MegaBaseplate := 1
global map_TownOfRobloxia := 1

global isRunning := false
global selectedMaps := Map()
global tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"


global lastOCR := ""
global stableStart := 0
global isPaused := false

global originalWidth := ""
global originalHeight := ""
global originalDPI := ""

global linkFile := A_ScriptDir "\link.txt"

versionFile := A_ScriptDir "\version.txt"
versionURL := "https://raw.githubusercontent.com/RE3PR/Roblox-Eat-The-World-ETW-Macro/refs/heads/main/version.txt"

GetLocalVersion(filePath) {
    try {
        if FileExist(filePath)
            return Trim(FileRead(filePath))
    }
    return ""
}

GetOnlineVersion(url) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, false)
        whr.Send()
        return Trim(whr.ResponseText)
    }
    return ""
}

CheckVersion() {
    global versionFile, versionURL

    localVer := CleanVersion(GetLocalVersion(versionFile))
    onlineVer := CleanVersion(GetOnlineVersion(versionURL))

    if (localVer = "" || onlineVer = "")
        return

    if (localVer != onlineVer) {
        MsgBox "Your macro is OUTDATED.`n`nInstalled: " localVer "`nLatest: " onlineVer
    }
}

CleanVersion(str) {
    str := Trim(str)
    str := StrReplace(str, "`r")
    str := StrReplace(str, "`n")
    str := StrReplace(str, " ")
    return str
}


CheckVersion()

IsValidLink(link) {
    return InStr(link, "https://www.roblox.com/share?code=")
}

SafeInt(str) {
    str := Trim(str)         
    if (str = "")
        return 0
    try
        return Integer(str)
    catch
        return 0               
}


map_Studville      := Integer(map_Studville      || 0)
map_MiddleRobloxia := Integer(map_MiddleRobloxia || 0)
map_BlockTown      := Integer(map_BlockTown      || 0)
map_MegaGrid       := Integer(map_MegaGrid       || 0)
map_MegaBaseplate  := Integer(map_MegaBaseplate  || 0)
map_TownOfRobloxia := Integer(map_TownOfRobloxia || 0)


if (ExitKey = "")    ExitKey := "o"
if (PauseKey = "")   PauseKey := "p"
if (Language = "")   Language := "English"
if (DeviceType = "") DeviceType := "Windows"


if FileExist(linkFile) {
    data := FileRead(linkFile)

for line in StrSplit(data, "`n", "`r") {
    line := Trim(line)
    if (line = "")
        continue

    pos := InStr(line, "=")
    if (!pos)
        continue

    key := Trim(SubStr(line, 1, pos - 1))
    value := Trim(SubStr(line, pos + 1))

    switch key {
        case "link": privateLink := value
        case "exit": ExitKey := value
        case "pause": PauseKey := value
        case "language": Language := value
        case "device": DeviceType := value
        case "browser": Browser := value
        case "upgrade": UpgradeSystem := value
        case "ratio": RatioValue := value + 0

        case "map_Studville": map_Studville := SafeInt(value)
        case "map_MiddleRobloxia": map_MiddleRobloxia := SafeInt(value)
        case "map_BlockTown": map_BlockTown := SafeInt(value)
        case "map_MegaGrid": map_MegaGrid := SafeInt(value)
        case "map_MegaBaseplate": map_MegaBaseplate := SafeInt(value)
        case "map_TownOfRobloxia": map_TownOfRobloxia := SafeInt(value)
    }
}
}
MyGui := Gui("-MinimizeBox", "Eat The World Macro v1.0.1")

MyGui.Add("Tab3", "x10 y10 w380 h280 vMainTabs", ["General", "Keybinds", "Map Selection"])

MyGui["MainTabs"].UseTab(1)

MyGui.Add("Text", "x30 y50", "Selected Resolution:")
MyGui.Add("DropDownList", "x180 y45 w150 vResolution Choose1", ["1680x1050 (16:10)"])

MyGui.Add("Text", "x30 y80", "Device Type:")
ddlDevice := MyGui.Add("DropDownList", "x180 y75 w150 vDeviceType", ["Windows", "Laptop"])

if (DeviceType = "Laptop")
    ddlDevice.Choose(2)
else
    ddlDevice.Choose(1)

ddlDevice.OnEvent("Change", SaveDevice)

MyGui.Add("Text", "x30 y110 vStatusText", "Status: Checking...")
btnEdit := MyGui.Add("Button", "x180 y108 w150", "Edit link")
btnEdit.OnEvent("Click", OpenEditGui)

MyGui.Add("Text", "x30 y140", "Browser:")

ddlBrowser := MyGui.Add("DropDownList", "x180 y135 w150 vBrowser",
    ["Google Chrome","Microsoft Edge","Mozilla Firefox","Opera","Opera GX","Brave","Vivaldi","Safari"])

browserList := ["Google Chrome","Microsoft Edge","Mozilla Firefox","Opera","Opera GX","Brave","Vivaldi","Safari"]

browserIndex := 1
for i, val in browserList {
    if (val = Browser) {
        browserIndex := i
        break
    }
}
ddlBrowser.Choose(browserIndex)

ddlBrowser.OnEvent("Change", SaveBrowser)

MyGui.Add("Text", "x30 y170", "Upgrade System:")

ddlUpgrade := MyGui.Add("DropDownList", "x180 y165 w150 vUpgradeSystem",
    ["Size","WalkSpeed","Multiplier","EatSpeed","Ratio","Coins"])


upgradeIndex := 1
for i, val in ["Size","WalkSpeed","Multiplier","EatSpeed","Ratio","Coins"] {
    if (val = UpgradeSystem) {
        upgradeIndex := i
        break
    }
}
ddlUpgrade.Choose(upgradeIndex)

ddlUpgrade.OnEvent("Change", UpgradeChanged)

MyGui.Add("Text", "x30 y205 vRatioLabel Hidden", "Ratio (4.0 - 6.0):")
MyGui.Add("Edit", "x180 y200 w60 vRatioValue Hidden", RatioValue)

btnMinus := MyGui.Add("Button", "x250 y200 w30 h23 vRatioMinus Hidden", "-")
btnPlus  := MyGui.Add("Button", "x285 y200 w30 h23 vRatioPlus Hidden", "+")

btnMinus.OnEvent("Click", RatioDown)
btnPlus.OnEvent("Click", RatioUp)

MyGui["MainTabs"].UseTab(2)

MyGui.Add("Text", "x30 y40 w200", "Click a box then press a key")
MyGui.Add("Text", "x30 y80 w80", "Exit:")

hkExit := MyGui.Add("Hotkey", "x120 y77 w100 vExitKey", ExitKey)
hkExit.OnEvent("Change", SaveKeys)

MyGui.Add("Text", "x30 y120 w80", "Pause:")

hkPause := MyGui.Add("Hotkey", "x120 y117 w100 vPauseKey", PauseKey)
hkPause.OnEvent("Change", SaveKeys)

MyGui["MainTabs"].UseTab(3)

MyGui.Add("Text", "x30 y45 w250 h20", "Choose the maps you want to farm:")
MyGui.Add("GroupBox", "x20 y70 w350 h190")

MyGui.Add("Text", "x40 y82 w200 h20", "Map Name")

cbStudville := MyGui.Add("CheckBox", "x40 y100 w200 h20 vmap_Studville", "Studville (worst map)")
cbMiddle := MyGui.Add("CheckBox", "x40 y125 w250 h20 vmap_MiddleRobloxia", "Middle Robloxia")
cbBlock := MyGui.Add("CheckBox", "x40 y150 w220 h20 vmap_BlockTown", "Block Town")
cbMegaGrid := MyGui.Add("CheckBox", "x40 y175 w150 h20 vmap_MegaGrid", "Mega Grid")
cbMegaBase := MyGui.Add("CheckBox", "x40 y200 w150 h20 vmap_MegaBaseplate", "Mega Baseplate")
cbTown := MyGui.Add("CheckBox", "x40 y225 w180 h20 vmap_TownOfRobloxia", "Town of Robloxia")

cbStudville.OnEvent("Click", SaveMaps)
cbMiddle.OnEvent("Click", SaveMaps)
cbBlock.OnEvent("Click", SaveMaps)
cbMegaGrid.OnEvent("Click", SaveMaps)
cbMegaBase.OnEvent("Click", SaveMaps)
cbTown.OnEvent("Click", SaveMaps)

MyGui["map_Studville"].Value := map_Studville
MyGui["map_MiddleRobloxia"].Value := map_MiddleRobloxia
MyGui["map_BlockTown"].Value := map_BlockTown
MyGui["map_MegaGrid"].Value := map_MegaGrid
MyGui["map_MegaBaseplate"].Value := map_MegaBaseplate
MyGui["map_TownOfRobloxia"].Value := map_TownOfRobloxia

MyGui["MainTabs"].UseTab()

MyGui.SetFont("cBlack s9")

txtCredit := MyGui.Add("Text", "x20 y300 w200 h20", "Made by Reaper")
txtLang   := MyGui.Add("Text", "x250 y300 w60 h20", "Language:")

ddlLanguage := MyGui.Add("DropDownList", "x310 y298 w100 vLanguage", ["English"])

if (Language = "English")
    ddlLanguage.Choose(1)

ddlLanguage.OnEvent("Change", SaveLang)

btnExit := MyGui.Add("Button", "x20 y330 w80 h25", "Exit")
btnStart := MyGui.Add("Button", "x310 y330 w80 h25", "Start")

btnExit.OnEvent("Click", ExitScript)
btnStart.OnEvent("Click", StartScript)

MyGui.Show("w420 h370")

if (UpgradeSystem = "Ratio")
    UpgradeChanged()
    
if (DeviceType = "Laptop")
    MyGui["DeviceType"].Choose(2)
else
    MyGui["DeviceType"].Choose(1)

MyGui["DeviceType"].Redraw()

SaveAll()
UpdateStatus()

SaveBrowser(*) {
    global Browser, MyGui

    Browser := MyGui["Browser"].Text

    if (Browser = "")
        Browser := "Google Chrome"

    SaveAll()
}

SaveMaps(*) {
    global map_Studville, map_MiddleRobloxia, map_BlockTown
    global map_MegaGrid, map_MegaBaseplate, map_TownOfRobloxia, MyGui

    map_Studville      := MyGui["map_Studville"].Value
    map_MiddleRobloxia := MyGui["map_MiddleRobloxia"].Value
    map_BlockTown      := MyGui["map_BlockTown"].Value
    map_MegaGrid       := MyGui["map_MegaGrid"].Value
    map_MegaBaseplate  := MyGui["map_MegaBaseplate"].Value
    map_TownOfRobloxia := MyGui["map_TownOfRobloxia"].Value

    SaveAll()
}

SaveKeys(*) {
    global ExitKey, PauseKey
    ExitKey := MyGui["ExitKey"].Value
    PauseKey := MyGui["PauseKey"].Value
    
    if (ExitKey = "")    ExitKey := "o"
    if (PauseKey = "")   PauseKey := "p"
    
    SaveAll()
}

SaveLang(*) {
    global Language
    Language := MyGui["Language"].Text
    if (Language = "")
        Language := "English"
    SaveAll()
}

SaveDevice(*) {
    global DeviceType, MyGui

    idx := MyGui["DeviceType"].Value
    DeviceType := (idx = 2) ? "Laptop" : "Windows"

    SaveAll()   
}

OpenEditGui(*) {
    global privateLink, MyGui
    
    prevText := (privateLink = "") ? "Previous link: None" : "Previous link: " . privateLink
    
    editGui := Gui("-MinimizeBox +Owner" MyGui.Hwnd, "Edit Private Link")
    
    editGui.Add("Text", "x20 y20 w350 vPrevLinkText", prevText)
    editGui.Add("Text", "x20 y60", "Private server link:")
    editGui.Add("Edit", "x20 y80 w350 vNewLink", privateLink)

    editGui.Add("Button", "x60 y130 w100", "Cancel").OnEvent("Click", (*) => editGui.Destroy())
    editGui.Add("Button", "x200 y130 w100", "Update").OnEvent("Click", (*) => SaveLink(editGui))
    
    editGui.Show("w400 h180")
}

CancelEdit(guiObj) {
    guiObj.Destroy()
}

SaveLink(editGui) {
    global privateLink
    
    newLink := Trim(editGui["NewLink"].Value)
    
    if (!IsValidLink(newLink)) {
        MsgBox("Please enter a valid Roblox private server link.", "Invalid Link", "Iconx")
        editGui["NewLink"].Value := privateLink   
        return
    }
    
    privateLink := newLink

    SaveAll()
    editGui.Destroy()
    UpdateStatus()
    TrayTip("Link saved successfully!", "Eat The World Bot", 0x1)
}

SaveAll() {
    global UpgradeSystem, RatioValue
    global privateLink, ExitKey, PauseKey, Language, DeviceType
    global map_Studville, map_MiddleRobloxia, map_BlockTown, map_MegaGrid, map_MegaBaseplate, map_TownOfRobloxia
    global coinCollection, coin_MaxLevel, coin_Multi, coin_Walk, coin_Eat
    global MyGui, linkFile


    if IsSet(MyGui) {

        UpgradeSystem := MyGui["UpgradeSystem"].Text
        RatioValue := MyGui["RatioValue"].Value + 0

        ExitKey := MyGui["ExitKey"].Value
        PauseKey := MyGui["PauseKey"].Value

        map_Studville      := MyGui["map_Studville"].Value
        map_MiddleRobloxia := MyGui["map_MiddleRobloxia"].Value
        map_BlockTown      := MyGui["map_BlockTown"].Value
        map_MegaGrid       := MyGui["map_MegaGrid"].Value
        map_MegaBaseplate  := MyGui["map_MegaBaseplate"].Value
        map_TownOfRobloxia := MyGui["map_TownOfRobloxia"].Value

    }

    FileDelete(linkFile)

    safeLink := IsValidLink(privateLink) ? privateLink : ""

content := ""

content .= "link=" safeLink "`n"
content .= "exit=" ExitKey "`n"
content .= "pause=" PauseKey "`n"
content .= "language=" Language "`n"
content .= "device=" DeviceType "`n"
content .= "browser=" Browser "`n"
content .= "upgrade=" UpgradeSystem "`n"
content .= "ratio=" RatioValue "`n"

content .= "map_Studville=" map_Studville "`n"
content .= "map_MiddleRobloxia=" map_MiddleRobloxia "`n"
content .= "map_BlockTown=" map_BlockTown "`n"
content .= "map_MegaGrid=" map_MegaGrid "`n"
content .= "map_MegaBaseplate=" map_MegaBaseplate "`n"
content .= "map_TownOfRobloxia=" map_TownOfRobloxia "`n"
    

    FileAppend(content, linkFile)
}

UpdateStatus() {
    valid := IsValidLink(privateLink)
    
    if (valid) {
        MyGui["StatusText"].Text := "Status: Good link provided"
        MyGui["StatusText"].SetFont("cGreen Bold")
    } else {
        MyGui["StatusText"].Text := "Status: No valid link"
        MyGui["StatusText"].SetFont("cRed Bold")
    }
}

StartScript(*) {
    global privateLink, ExitKey, PauseKey, coinCollection
    global map_Studville, map_MiddleRobloxia, map_BlockTown, map_MegaGrid, map_MegaBaseplate, map_TownOfRobloxia
    global originalWidth, originalHeight, originalDPI
    Hotkey(ExitKey, HandleExit, "On")
    Hotkey(PauseKey, HandlePause, "On")

    if (!IsValidLink(privateLink)) {
        MsgBox("You must set a valid private server link before starting.", "Error", "Iconx")
        return
    }

    if (ExitKey = PauseKey) {
        MsgBox("Exit key and Pause key cannot be the same.", "Keybind Error", "Iconx")
        MyGui.Show()
        MyGui["MainTabs"].Choose(2)
        return
    }

    if (!(map_Studville || map_MiddleRobloxia || map_BlockTown || map_MegaGrid || map_MegaBaseplate || map_TownOfRobloxia)) {
        MsgBox("You must select at least 1 map before starting.", "Map Error", "Iconx")
        MyGui.Show()
        MyGui["MainTabs"].Choose(3)
        return
    }


    res := GetCurrentResolution()
    parts := StrSplit(res, "|")
    originalWidth := parts[1]
    originalHeight := parts[2]
    originalDPI := GetScaling()
    

    SetResolution(1680, 1050)
	Sleep 2000 
    SetScaling(96)  
    

    Hotkey(ExitKey, HandleExit, "On")
 
    MyGui.Hide()
	
    isRunning := true

    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        Rejoin()
    } else {
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
        Sleep 2000
        StartLogic()
    }

    SetTimer(MainLoop, 10000)
	SetTimer(CheckCrash, 10000)
}

ExitScript(*) => ExitApp()

MyGui.OnEvent("Close", (*) => ExitApp())

MainLoop(*) {
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        Rejoin()
    } else {
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    }
    Sleep 2000
}
StartLogic() {

    Loop {
	WaitIfPaused()
        style := WinGetStyle("ahk_exe RobloxPlayerBeta.exe")

        if (style & 0xC00000) {
            Send "{F11}"
            Sleep 1000
        } else {
            break
        }
    }

color1 := PixelGetColor(60, 692, "RGB")

if (!ColorMatch(color1, 0x000000, 10)) {
    Rejoin()
    return
}

color2 := PixelGetColor(1525, 225, "RGB")
color3 := PixelGetColor(32, 576, "RGB")
color4 := PixelGetColor(1410, 188, "RGB")

if (ColorMatch(color2, 0xD10000, 12)) {
    Click 1452, 241
    Sleep 400
}

if (!ColorMatch(color3, 0xFFFFFF, 10) && ColorMatch(color4, 0xD10000, 12)) {

    extraColor := PixelGetColor(518, 280, "RGB")

    if (ColorMatch(extraColor, 0xE70000, 12)) {
        Click 630, 865
        Sleep 500
    }

    Click 1414, 224
}

if (CheckColor(65, 571, 0xBDBDBD, 10)) {

    if (!ColorMatch(color4, 0xD10000, 12)) {
        Click 67, 575
        Sleep 300
    }

    detected := []

    CheckAndStore(checkX, checkY, clickX, clickY) {
        col := PixelGetColor(checkX, checkY, "RGB")

        if (ColorMatch(col, 0xFFFFFF, 10)) {
            detected.Push([clickX, clickY])
        }
    }

    CheckAndStore(1051, 425, 958, 407)
    CheckAndStore(1247, 425, 1152, 414)
    CheckAndStore(1336, 423, 1348, 407)

    CheckAndStore(1051, 604, 960, 588)
    CheckAndStore(1247, 609, 1154, 583)
    CheckAndStore(1442, 607, 1349, 585)

    CheckAndStore(1051, 788, 958, 772)
    CheckAndStore(1247, 792, 1153, 768)
    CheckAndStore(1442, 788, 1348, 768)

    lastIndex := detected.Length

    if (lastIndex >= 1) {
        Loop lastIndex {
            WaitIfPaused()
            pos := detected[A_Index]

            Click pos[1], pos[2]

            if (A_Index < lastIndex)
                Sleep 3000
        }
    }

    extraColor := PixelGetColor(522, 273, "RGB")

    if (ColorMatch(extraColor, 0xE70000, 12)) {
        Sleep 3000
        Click 655, 922
    }

    Click 1410, 221

} else {

    color4 := PixelGetColor(1410, 188, "RGB")

    if (ColorMatch(color4, 0xD10000, 12)) {
        color5 := PixelGetColor(518, 280, "RGB")

        if (ColorMatch(color5, 0xE70000, 12)) {
            Click 776, 878
            Sleep 500
            Click 1414, 224
        }
    }
}

MegaMaps()
}

MegaMaps() {

    Loop {
        WaitIfPaused()
        megaCheck := PixelGetColor(241, 1004, "RGB")

        if (ColorMatch(megaCheck, 0x1A1F20, 10))
            break

        Click 172, 971
        Sleep 500
    }

    checkBlack := PixelGetColor(35, 1009, "RGB")
    if (!ColorMatch(checkBlack, 0x000000, 15)) {
        Rejoin()
        return
    }

    whiteCheck := PixelGetColor(55, 598, "RGB")

    if (!ColorMatch(whiteCheck, 0xFFFFFF, 10)) {

        Loop {
            WaitIfPaused()
            checkColor := PixelGetColor(698, 608, "RGB")

            if (ColorMatch(checkColor, 0x181A1B, 10))
                break

            Click 62, 648

            Sleep 200
            checkColor := PixelGetColor(698, 608, "RGB")

            if (ColorMatch(checkColor, 0x181A1B, 10))
                break

            Loop {
                WaitIfPaused()
                Click 62, 648
                Sleep 1000

                checkColor := PixelGetColor(698, 608, "RGB")

                if (ColorMatch(checkColor, 0x181A1B, 10))
                    break 2
            }
        }

        Sleep 250

        Loop {
            WaitIfPaused()
            whiteCheck := PixelGetColor(55, 598, "RGB")

            if (ColorMatch(whiteCheck, 0xFFFFFF, 10))
                break

            Click 697, 736
            Sleep 1000
        }
    }

    Loop {
        WaitIfPaused()
        loadColor := PixelGetColor(194, 974, "RGB")

        if (ColorMatch(loadColor, 0x161A1B, 10))
            break

        Sleep 500
    }

    checkBlack2 := PixelGetColor(35, 1009, "RGB")

    if (!ColorMatch(checkBlack2, 0x000000, 15)) {
        Rejoin()
        return
    }

    CheckSelectedMap()
}

CheckSelectedMap() {
if (!WaitForMaps()) {
    return
}

settings := Map()

if FileExist("link.txt") {
    content := FileRead("link.txt")

    for line in StrSplit(content, "`n", "`r") {

        line := Trim(line)
        if (line = "" || !InStr(line, "="))
            continue

        parts := StrSplit(line, "=", , 2) 

        key := Trim(parts[1])
        val := Trim(parts[2])

        settings[key] := val
    }
} else {
    MsgBox("link.txt not found")
    return
}

    maps := Map()

    maps["Mega Baseplate"] := [
        {x:871, y:16, color:0xF0F0F0},
        {x:767, y:9,  color:0x707070}
    ]

    maps["Mega Grid"] := [
        {x:857, y:9,  color:0x1D1D1D},
        {x:859, y:16, color:0xA0A0A0}
    ]
	
    maps["Town of Robloxia"] := [
        {x:911, y:14, color:0xF0F0F0},
        {x:772, y:22, color:0xFAFAFA}
    ]

    maps["Middle Robloxia"] := [
        {x:825, y:14, color:0xD9D9D9},
        {x:917, y:17, color:0xFFFFFF}
    ]

    maps["Block Town"] := [
        {x:835, y:14, color:0x4B4B4B},
        {x:893, y:13, color:0x808080}
    ]

    maps["Studville"] := [
        {x:825, y:21, color:0x9A9A9A},
        {x:875, y:19, color:0xE2E2E2}
    ]


    nameMap := Map(
        "Mega Baseplate", "map_MegaBaseplate",
        "Mega Grid", "map_MegaGrid",
        "Town of Robloxia", "map_TownOfRobloxia",
        "Middle Robloxia", "map_MiddleRobloxia",
        "Block Town", "map_BlockTown",
        "Studville", "map_Studville"
    )

anySelected := false

for mapName, pixels in maps {

    keyName := nameMap[mapName]
    val := settings.Has(keyName) ? Trim(settings[keyName]) : "0"

    if (Integer(val) = 1) {
        anySelected := true

        matchAll := true

        for p in pixels {
            c := PixelGetColor(p.x, p.y, "RGB")

            if (!ColorMatch(c, p.color)) {
                matchAll := false
                break
            }
        }

        if (matchAll) {
		    SendEvent "{Esc}"
            Sleep 700
            SendEvent "r"
            Sleep 700
            SendEvent "{Enter}"
			Sleep 6700
            MainMacro()
            return
        }
    }
}

if (anySelected) {
    MapSelection()
    return
}
}

ColorMatch(c1, c2, tolerance := 10) {
    r1 := (c1 >> 16) & 0xFF
    g1 := (c1 >> 8) & 0xFF
    b1 := c1 & 0xFF

    r2 := (c2 >> 16) & 0xFF
    g2 := (c2 >> 8) & 0xFF
    b2 := c2 & 0xFF

    return (Abs(r1 - r2) <= tolerance
         && Abs(g1 - g2) <= tolerance
         && Abs(b1 - b2) <= tolerance)
}

WaitForMaps(timeout := 10000) {
    start := A_TickCount

    maps := [
        [{x:871, y:16, color:0xF0F0F0}, {x:767, y:9,  color:0x707070}], ; Mega Baseplate
        [{x:857, y:9,  color:0x1D1D1D}, {x:859, y:16, color:0xA0A0A0}], ; Mega Grid
        [{x:911, y:14, color:0xF0F0F0}, {x:772, y:22, color:0xFAFAFA}], ; Town
        [{x:825, y:14, color:0xD9D9D9}, {x:917, y:17, color:0xFFFFFF}], ; Middle
        [{x:835, y:14, color:0x4B4B4B}, {x:893, y:13, color:0x808080}], ; Block Town
        [{x:825, y:21, color:0x9A9A9A}, {x:875, y:19, color:0xE2E2E2}]  ; Studville
    ]

    while (A_TickCount - start < timeout) {

        for pixels in maps {

            matchAll := true

            for p in pixels {
                c := PixelGetColor(p.x, p.y, "RGB")

                if (!ColorMatch(c, p.color)){
                    matchAll := false
                    break
                }
            }

            if (matchAll) {
                return true
            }
        }

        Sleep(200) 
    }

    return false 
}

MapSelection() {
    global selectedMaps

        if (CheckColor(1410, 188, 0xD10000, 12)) {
        StopClicking()
        Click 1414, 224
        Sleep 100  
    }

    Loop {
        WaitIfPaused()
        mapReady := PixelGetColor(686, 683, "RGB")
        if (CheckColor(686, 683, 0x181A1C, 10))
            break

        Click 49, 1000
        Sleep 200
    }

    col1 := PixelGetColor(761, 499, "RGB")
    col2 := PixelGetColor(764, 494, "RGB")

    if (CheckColor(761, 499, 0x52B04D, 12) || CheckColor(764, 494, 0x397B36, 12)) {
        Click 760, 673
        Sleep 500
    } else {
        Click 758, 502
        Sleep 200
        Click 760, 673
        Sleep 6500
    }

    Loop {
        WaitIfPaused()
        found := false

        if (map_MegaBaseplate) {
            c1 := PixelGetColor(1036, 223, "RGB")
            if (CheckColor(1036, 223, 0x24924C, 12)) {
                Click 1036, 223
                found := true
            }
        }

        if (!found && map_MegaGrid) {
            c1 := PixelGetColor(644, 226, "RGB")
            c2 := PixelGetColor(836, 227, "RGB")
            c3 := PixelGetColor(1032, 226, "RGB")

            if (CheckColor(644, 226, 0xCD82C6, 12)) {
                Click 644, 226
                found := true
            } else if (CheckColor(836, 227, 0xB86EB3, 12)) {
                Click 836, 227
                found := true
            } else if (CheckColor(1032, 226, 0xC46DBB, 12)) {
                Click 1032, 226
                found := true
            }
        }

        if (!found && map_TownOfRobloxia) {
            c2 := PixelGetColor(829, 226, "RGB")
            c3 := PixelGetColor(1028, 224, "RGB")

            if (CheckColor(829, 226, 0x4CA953, 12)) {
                Click 829, 226
                found := true
            } else if (CheckColor(1028, 224, 0x48A853, 12)) {
                Click 1028, 224
                found := true
            }
        }

        if (!found && map_MiddleRobloxia) {
            c1 := PixelGetColor(646, 228, "RGB")
            if (CheckColor(646, 228, 0x3CAE53, 12)) {
                Click 646, 228
                found := true
            }
        }

        if (!found && map_Studville) {
            c2 := PixelGetColor(837, 227, "RGB")
            c3 := PixelGetColor(1024, 223, "RGB")

            if (CheckColor(837, 227, 0x3E564F, 12)) {
                Click 837, 227
                found := true
            } else if (CheckColor(1024, 223, 0x2D5244, 12)) {
                Click 1024, 223
                found := true
            }
        }

        if (!found && map_BlockTown) {
            c1 := PixelGetColor(653, 222, "RGB")
            c2 := PixelGetColor(844, 224, "RGB")
            c3 := PixelGetColor(1033, 222, "RGB")

            if (CheckColor(653, 222, 0x002C4B, 12)) {
                Click 653, 222
                found := true
            } else if (CheckColor(844, 224, 0x326C91, 12)) {
                Click 844, 224
                found := true
            } else if (CheckColor(1033, 222, 0xA59B93, 12)) {
                Click 1033, 222
                found := true
            }
        }

        if (found) {
            WaitMapLoad()
            break
        }

        c1 := PixelGetColor(825, 44, "RGB")
        c2 := PixelGetColor(819, 43, "RGB")

        if (CheckColor(825, 44, 0xFFFFFF, 10) || CheckColor(819, 43, 0xFFFFFF, 10)) {
            Click 760, 673
            Sleep 500

            while (true) {
                c1 := PixelGetColor(825, 44, "RGB")
                c2 := PixelGetColor(819, 43, "RGB")

                if (!CheckColor(825, 44, 0xFFFFFF, 10) && !CheckColor(819, 43, 0xFFFFFF, 10))
                    break

                Sleep 100
            }
        }

        Sleep 200
    }

    MainMacro()
}

CheckColor(x, y, targetColor, tolerance := 5) {
    col := PixelGetColor(x, y, "RGB")

    r := (col >> 16) & 0xFF
    g := (col >> 8) & 0xFF
    b := col & 0xFF

    tr := (targetColor >> 16) & 0xFF
    tg := (targetColor >> 8) & 0xFF
    tb := targetColor & 0xFF

    return (Abs(r - tr) <= tolerance
        && Abs(g - tg) <= tolerance
        && Abs(b - tb) <= tolerance)
}

CheckMapWaitOnce(x1, y1, c1, x2 := "", y2 := "", c2 := "", x3 := "", y3 := "", c3 := "", tolerance := 5) {

    if (CheckColor(x1, y1, c1, tolerance)) {
        Click x1, y1
        return true
    }

    if (x2 != "" && CheckColor(x2, y2, c2, tolerance)) {
        Click x2, y2
        return true
    }

    if (x3 != "" && CheckColor(x3, y3, c3, tolerance)) {
        Click x3, y3
        return true
    }

    return false
}

WaitMapLoad() {
    global isRunning

    isRunning := false 

    Loop {
        WaitIfPaused()
        topWhite := PixelGetColor(745, 20, "RGB")
        if (CheckColor(745, 20, 0xFFFFFF, 10))
            break
        Sleep 500
    }

    SendEvent "{Esc}"
    Sleep 700
    SendEvent "r"
    Sleep 700
    SendEvent "{Enter}"

    Sleep 6700

    isRunning := true   
}
MainMacro() {
    WaitIfPaused()
    static firstRun := true

    if (firstRun) {
        firstRun := false
        Sleep 3000   ; give game time to settle
    }

    StartClicking(30)
    SetTimer Sell, 100
    Sleep 400
    SetTimer CheckRGB, 1000
    SetTimer OCRChecker, 2000
}

AutoClicker(*) {
WaitIfPaused()
    global isPaused
    if (isPaused)
        return

    Click 145, 950
}

StartClicking(delay := 30) {
    flagFile := A_Temp "\clicking.flag"

    if FileExist(flagFile)
        FileDelete flagFile  

    FileAppend "", flagFile

    Run A_ScriptDir "\Autoclicker.ahk"
}

StopClicking() {
    flagFile := A_Temp "\clicking.flag"

    if FileExist(flagFile)
        FileDelete flagFile
}

Sell(*) {
WaitIfPaused()
    color1 := PixelGetColor(1471, 999, "RGB")

    if (CheckColor(1471, 999, 0x3C8B26, 12)) {

    SetTimer CheckRGB, 0
    SetTimer StartOCR, 0
    SetTimer Sell, 0
    SetTimer OCRChecker, 0
    StartClicking(150)

    Loop {
        WaitIfPaused()
        if (CheckColor(1484, 997, 0x3C8F26, 12))
            break
        Sleep 50
    }

    StopClicking()
    

    Loop {
        WaitIfPaused()
        Click 178, 971
        Sleep 200

        if (CheckColor(184, 1000, 0x191C1D, 10)) {
            MapSelection()
            break
        }
    }
}
}

CheckRGB(*) {
    if (CheckColor(65, 573, 0xBDBDBD, 10)) {
        SetTimer(CheckRGB, 0)
        SetTimer(StartOCR, -1)
    }
}

StartOCR(*) {
  prevText := ""
stableCount := 0

Loop {
    WaitIfPaused()
    text := GetOCR(606, 963, 1127, 1036)

    stableCount := (text = prevText) ? stableCount + 1 : 0
    prevText := text

    if (stableCount >= 3)
        break

    Sleep 420
}

prevText := GetOCR(606, 963, 1127, 1036)

Loop {
    WaitIfPaused()
    text := GetOCR(606, 963, 1127, 1036)


    if (text != prevText)
        break

    Sleep 15
}

prevText := text
stableCount := 0

ToolTip()

    StopClicking()
	SetTimer OCRChecker, 0
	Sleep 100
    Click 67, 575
    Sleep 150

    detected := []

    CheckAndStore(&detected, 1051, 425, 958, 407)
    CheckAndStore(&detected, 1247, 425, 1152, 414)
    CheckAndStore(&detected, 1336, 423, 1348, 407)
    CheckAndStore(&detected, 1051, 604, 960, 588)
    CheckAndStore(&detected, 1247, 609, 1154, 583)
    CheckAndStore(&detected, 1442, 607, 1349, 585)
    CheckAndStore(&detected, 1051, 788, 958, 772)
    CheckAndStore(&detected, 1247, 792, 1153, 768)
    CheckAndStore(&detected, 1442, 788, 1348, 768)

lastIndex := detected.Length

for i, pos in detected {
    Click pos[1], pos[2]


    if (CheckColor(1301, 718, 0x411E57, 10)) {
        Upgrades()
        return
    }

    if (pos[1] == 1348 && pos[2] == 768) {
        Upgrades()
        return
    }

    if (lastIndex > 1 && i < lastIndex)
        Sleep 2000
}

if (CheckColor(522, 273, 0xE70000, 10)) {
    Sleep 2000
    Click 655, 922
} else {
    if (CheckColor(1410, 188, 0xD10000, 10)
        && CheckColor(518, 280, 0xE70000, 10)) {
        Click 776, 878
        Sleep 500
        Click 1414, 224
    }
}

Click 1414, 224
MainMacro()

}

CheckAndStore(&arr, checkX, checkY, clickX, clickY) {
    if (PixelGetColor(checkX, checkY, "RGB") = 0xFFFFFF)
        arr.Push([clickX, clickY])
}

GetOCR(x1, y1, x2, y2)
{
    global tesseractPath

    w := x2 - x1
    h := y2 - y1

    tempImage := A_Temp "\ocr_" A_TickCount ".png"
    tempOutput := A_Temp "\ocr_" A_TickCount

    pBitmap := Gdip_BitmapFromScreen(x1 "|" y1 "|" w "|" h)

    width := Gdip_GetImageWidth(pBitmap)
    height := Gdip_GetImageHeight(pBitmap)

    Loop height {
	WaitIfPaused()
        y := A_Index - 1
        Loop width {
		WaitIfPaused()
            x := A_Index - 1

            color := Gdip_GetPixel(pBitmap, x, y)

            r := (color >> 16) & 0xFF
            g := (color >> 8) & 0xFF
            b := color & 0xFF

            if (r > 200 && g > 200 && b > 200) {
                Gdip_SetPixel(pBitmap, x, y, 0xFFFFFFFF)
            } else {     
                Gdip_SetPixel(pBitmap, x, y, 0xFF000000)
            }
        }
    }

    Gdip_SaveBitmapToFile(pBitmap, tempImage)
    Gdip_DisposeImage(pBitmap)

    RunWait '"' tesseractPath '" "' tempImage '" "' tempOutput '" --oem 3 --psm 7 -c tessedit_char_whitelist=0123456789', , "Hide"

    text := ""
    if FileExist(tempOutput ".txt") {
        text := Trim(FileRead(tempOutput ".txt"))
    }

    FileDelete tempImage
    FileDelete tempOutput ".txt"

    return text
}


PauseClicking() {
    global isPaused, pauseFile

    if (isPaused)
        return

    isPaused := true

    FileAppend "", pauseFile

    SetTimer ResumeClicking, -2000
}

ResumeClicking(*) {
    global isPaused, pauseFile

    isPaused := false

    FileDelete pauseFile

    Sleep 200
    ToolTip
}

OCRChecker(*) {
    global lastOCR, stableStart, isPaused, lastPauseTime

    current := GetOCR(606, 963, 1127, 1036)

    if (current = "")
        return

    if (current = lastOCR) {

        if (stableStart = 0)
            stableStart := A_TickCount

        if ((A_TickCount - stableStart) >= 8000
            && (A_TickCount - lastPauseTime) > 3000) {

            lastPauseTime := A_TickCount
            PauseClicking()

            stableStart := 0
        }

    } else {
        lastOCR := current
        stableStart := A_TickCount
    }
}

Upgrades() {
WaitIfPaused()
DisableAllTimers()
SetTimer(MainLoop, 10000)
SetTimer(CheckCrash, 10000)
    filePath := A_ScriptDir "\link.txt"
    if !FileExist(filePath) {
        MsgBox "link.txt not found!"
        return
    }

    content := FileRead(filePath)

    upgradeType := ""
    ratioValue := ""

for line in StrSplit(content, "`n") {
    line := Trim(line)

    if InStr(line, "upgrade=")
        upgradeType := Trim(StrReplace(line, "upgrade="))

    if InStr(line, "ratio=")
        ratioValue := Trim(StrReplace(line, "ratio="))
}

if (upgradeType = "Coins") {
    NormalMaps()
    return
}

    color := PixelGetColor(1411, 207, "RGB")

    if (CheckColor(1411, 207, 0xD10000, 10)) {
        Click 1411, 222
    }

    Sleep 100
    color := PixelGetColor(554, 364, "RGB")

    if (!CheckColor(554, 364, 0x000000, 10)) {
        Click 62, 434
    }
    Sleep 200

    for line in StrSplit(content, "`n") {
        line := Trim(line)

        if InStr(line, "upgrade=")
            upgradeType := Trim(StrReplace(line, "upgrade="))

        if InStr(line, "ratio=")
            ratioValue := Trim(StrReplace(line, "ratio="))
    }

selectedRatio := ratioValue

if (upgradeType = "Ratio") {
    RatioUpgrade(selectedRatio)
}

else if (upgradeType != "") {
    NormalUpgrade(upgradeType)
} 
else {
    MsgBox "No upgrade type found!"
    return
}
    AfterUpgrade()
}

NormalUpgrade(type) {
WaitIfPaused()

    if (type = "Size") {
        Click 1268, 449
    }
    else if (type = "Walkspeed") {
        Click 1267, 649
    }
    else if (type = "Multiplier") {
        Click 1266, 842
    }
    else if (type = "EatSpeed") {
        Click 1036, 354
        start := A_TickCount
        while (A_TickCount - start < 300) {
            Send "{WheelDown}"
        }
        Sleep 250
        Click 1266, 867
    }
}

AfterUpgrade() {

    Sleep 2000

    if (CheckColor(65, 604, 0xFFFFFF, 10)) {
        NormalMaps()
        return
    }

    loop {
        WaitIfPaused()
        if (CheckColor(642, 616, 0x335FFF, 10)) {

            loop {
                WaitIfPaused()
                Click 1037, 381
                Sleep 100

                if (CheckColor(774, 212, 0x535351, 10)) {
                    NormalMaps()
                    return
                }
            }
        } 
        else {
            Sleep 2000
        }
    }
}

RatioUpgrade(ratio) {

    sizeText := GetOCR(971, 429, 1119, 461)
    multiText := GetOCR(960, 823, 1140, 855)

    sizeLevel := RegExReplace(sizeText, "[^0-9\.]")
    multiLevel := RegExReplace(multiText, "[^0-9\.]")

    size := Number(sizeLevel)
    multi := Number(multiLevel)
    ratioVal := Number(ratio)

    if (size = 0 || multi = 0 || ratioVal = 0) {
        return
    }

    expectedSize := ratioVal * multi
    tolerance := 0.2

    if (Abs(size - expectedSize) <= tolerance) {
        Click 1268, 449
    }
    else if (size < expectedSize) {
        Click 1268, 449
    }
    else {
        Click 1266, 842
    }
}

NormalMaps() {
WaitIfPaused()
    Loop {
        WaitIfPaused()
        Click 1455, 224
        Sleep 300

        if (!CheckColor(1455, 224, 0xD10000, 10))
            break
    }
    
    color1 := PixelGetColor(301, 998, "RGB")

    if (CheckColor(301, 998, 0x3C8E26, 10)) {
        GoFullLogic()
    } else {
        GoEndLogic()
    }
}

GoFullLogic() {
SetTimer AutoClicker, 20
SetTimer CheckRGB, 0
SetTimer Sell, 0

Loop {
WaitIfPaused()
    if (CheckColor(1471, 999, 0x3C8B26, 10))
        break
    Sleep 50
}
SetTimer AutoClicker, 150

Loop {
WaitIfPaused()
    if (CheckColor(1497, 998, 0x3C8F26, 10))
        break
    Sleep 50
}

SetTimer AutoClicker, 0
SetTimer OCRChecker, 0

Loop {
WaitIfPaused()
    Click 178, 971
    Sleep 1000

    if (CheckColor(184, 1000, 0x191C1D, 10))
        break
}

if (CheckColor(181, 1001, 0x3C8B26, 10)) {
    Loop {
        WaitIfPaused()
        Click 175, 966
        Sleep 300

        if (CheckColor(186, 1011, 0x181C1C, 10))
            break
    }
}

GoEndLogic()
}

GoEndLogic() {

    if (CheckColor(175, 998, 0x3C8D26, 10)) {
        Loop {
            WaitIfPaused()

            Click 175, 971
            Sleep 100

            if (CheckColor(175, 1004, 0x1A1C20, 10))
                break
        }
    }

    Loop {
        WaitIfPaused()
        Click 61, 603
        Sleep 1000

        if (CheckColor(704, 431, 0x181A1B, 10))
            break
    }

    Loop {
        WaitIfPaused()
        Click 697, 692
        Sleep 1000

        if (CheckColor(18, 599, 0xE2E2E2, 10))
            break
    }

    Loop {
        WaitIfPaused()
        Sleep 200
        if (CheckColor(190, 993, 0x191C1D, 10))
            break
    }

    Sleep 7000
    StartLogic()
    SetTimer(MainLoop, 10000)
    SetTimer(CheckCrash, 10000)
}

CheckCrash() {
WaitIfPaused()
    if (PixelGetColor(710, 425, "RGB") = 0x393B3D) {
        ProcessClose("RobloxPlayerBeta.exe")
        Sleep 2000
        Rejoin()
    }
}


Rejoin() {
WaitIfPaused()
    global privateLink, Browser
    DisableAllTimers()
    SetTimer(MainLoop, 0)
    SetTimer(CheckCrash, 0)
    isRunning := false

if WinExist("ahk_exe RobloxPlayerBeta.exe") {
    WinClose("ahk_exe RobloxPlayerBeta.exe")
    if !WinWaitClose("ahk_exe RobloxPlayerBeta.exe", , 3) {
        ProcessClose("RobloxPlayerBeta.exe")
        Sleep 200
    }
}
    maxAttempts := 3
    success := false

    Loop maxAttempts {
        WaitIfPaused()
        attempt := A_Index

        RunBrowser(privateLink)

        if WinWait("ahk_exe RobloxPlayerBeta.exe", , 30) {
            success := true
            break
        }
        Sleep 2000
    }

    if !success {
        MsgBox("Invalid or failed Roblox link. Script will now exit.")
        ExitApp()
    }

    CloseBrowser()
    Sleep 1000

    Loop {
        WaitIfPaused()
        style := WinGetStyle("ahk_exe RobloxPlayerBeta.exe")

        if (style & 0xC00000) {
            Send "{F11}"
            Sleep 1000
        } else {
            break
        }
    }

    Loop {
        WaitIfPaused()

        if (CheckColor(192, 975, 0x161A1B, 10))
            break

        Sleep 500
    }

    Sleep 1000
    ToolTip()

    StartLogic()
    SetTimer(MainLoop, 10000)
    SetTimer(CheckCrash, 10000)
}

RunBrowser(link) {
    global Browser

    try {
        switch Browser {
            case "Google Chrome":
                Run('chrome.exe "' link '"')

            case "Microsoft Edge":
                Run('msedge.exe "' link '"')

            case "Mozilla Firefox":
                Run('firefox.exe "' link '"')

            case "Opera":
                Run('opera.exe "' link '"')

            case "Opera GX":
                Run('opera.exe "' link '"')

            case "Brave":
                Run('brave.exe "' link '"')

            case "Vivaldi":
                Run('vivaldi.exe "' link '"')

            default:
                Run(link)
        }
    } catch {
        Run(link)
    }
}

CloseBrowser() {
    global Browser

    switch Browser {
        case "Google Chrome":
            WinClose("ahk_exe chrome.exe")

        case "Microsoft Edge":
            WinClose("ahk_exe msedge.exe")

        case "Mozilla Firefox":
            WinClose("ahk_exe firefox.exe")

        case "Opera":
            WinClose("ahk_exe opera.exe")

        case "Opera GX":
            WinClose("ahk_exe opera.exe")

        case "Brave":
            WinClose("ahk_exe brave.exe")

        case "Vivaldi":
            WinClose("ahk_exe vivaldi.exe")
    }
}

DisableAllTimers() {

    StopClicking()
    SetTimer Sell, 0
    SetTimer CheckRGB, 0
    SetTimer OCRChecker, 0

}

GetCurrentResolution() {
    devmode := Buffer(156, 0)
    NumPut("UInt", 156, devmode, 36)                    
    DllCall("EnumDisplaySettingsA", "Ptr", 0, "UInt", -1, "Ptr", devmode.Ptr)
    width  := NumGet(devmode, 108, "UInt")  
    height := NumGet(devmode, 112, "UInt")  
    return width "|" height
}
SetResolution(w, h) {
    devmode := Buffer(156, 0)

   
    NumPut("UShort", 156, devmode, 36)

    DllCall("EnumDisplaySettingsA", "Ptr", 0, "UInt", -1, "Ptr", devmode.Ptr)

    NumPut("UInt", 0x5C0000, devmode, 40)
    NumPut("UInt", w, devmode, 108)
    NumPut("UInt", h, devmode, 112)

    result := DllCall("ChangeDisplaySettingsA", "Ptr", devmode.Ptr, "UInt", 0)

    return result
}
GetScaling() {
    try {
        RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "LogPixels")
    } catch {
        return 96
    }
}

SetScaling(dpiValue) {
    try {
        RegWrite(dpiValue, "REG_DWORD", "HKEY_CURRENT_USER\Control Panel\Desktop", "LogPixels")
        RegWrite(1, "REG_DWORD", "HKEY_CURRENT_USER\Control Panel\Desktop", "Win8DpiScaling")
        DllCall("user32\SystemParametersInfo", "UInt", 0x009F, "UInt", 0, "Ptr", 0, "UInt", 2) 
    }
}

RestoreDisplay() {
    global originalWidth, originalHeight, originalDPI
    if (originalWidth != "")
        SetResolution(originalWidth, originalHeight)
    if (originalDPI != "")
        SetScaling(originalDPI)
}

HandleExit(*) {
    StopClicking()   
    RestoreDisplay()
    ExitApp()
}

UpgradeChanged(*) {
    global UpgradeSystem, MyGui

    UpgradeSystem := MyGui["UpgradeSystem"].Text

    if (UpgradeSystem = "Ratio") {
        MyGui["RatioLabel"].Visible := true
        MyGui["RatioValue"].Visible := true
        MyGui["RatioMinus"].Visible := true
        MyGui["RatioPlus"].Visible := true
    } else {
        MyGui["RatioLabel"].Visible := false
        MyGui["RatioValue"].Visible := false
        MyGui["RatioMinus"].Visible := false
        MyGui["RatioPlus"].Visible := false
    }

    SaveAll()
}

RatioUp(*) {
    global RatioValue, MyGui
    if (RatioValue < 6) {
        RatioValue += 0.5
        MyGui["RatioValue"].Value := RatioValue
        SaveAll()
    }
}

RatioDown(*) {
    global RatioValue, MyGui
    if (RatioValue > 4) {
        RatioValue -= 0.5
        MyGui["RatioValue"].Value := RatioValue
        SaveAll()
    }
}
HandlePause(*) {
    global isPaused, pauseFile

    isPaused := !isPaused  

    if (isPaused) {
        FileAppend "", pauseFile   
        ToolTip("⏸ Paused")
    } else {
        FileDelete pauseFile      
        ToolTip("▶ Resumed")
    }

    SetTimer(() => ToolTip(), -3000)
}
WaitIfPaused() {
    global isPaused
    while (isPaused)
        Sleep 50
}

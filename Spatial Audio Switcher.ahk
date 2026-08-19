#Requires AutoHotkey v2.0

; ============================================================
; Spatial Audio Switcher
; Updated by DestructiveBurn
; v1.07 (Added Audio Tools & Display/System Quick Switches)
; ============================================================

; ----------------
; Global Variables
; ----------------

global configFile := "SpatialAudioSwitcher.ini"

global desktopIconsVisible := true
global tripleClickEnabled := false

global currentSpatial := ""
global currentSpeakerConfig := "Stereo"
global currentDefaultFormat := "16 Bit, 44100 Hz"
global currentExclusivity := "Not Exclusive"

global defaultPresetSlot := 0
global defaultPresetEnabled := false

global activePresetIcon := ""
global atmosTimerActive := false

global startupEnabled := false
global CurrentStatusItem := "Disabled"

global Tray
global SpatialMenu
global Select
global Settings
global Configuration
global DefaultFormat
global Exclusivity
global SpatialApps
global PresetsMenu
global DefaultPresetMenu
global VolumeMenu
global OutputDevicesMenu

global SpeakerMasks := Map(
    "Stereo",       "0x3",
    "Quadraphonic", "0x33",
    "5.1",          "0x3f",
    "7.1",          "0x63f"
)

global DefaultFormats := Map(
    "16 Bit, 44100 Hz",  [16, 44100],
    "16 Bit, 48000 Hz",  [16, 48000],
    "16 Bit, 96000 Hz",  [16, 96000],
    "16 Bit, 192000 Hz", [16, 192000],
    "24 Bit, 44100 Hz",  [24, 44100],
    "24 Bit, 48000 Hz",  [24, 48000],
    "24 Bit, 96000 Hz",  [24, 96000],
    "24 Bit, 192000 Hz", [24, 192000]
)

; Load saved settings
if FileExist(configFile) {
    tripleClickEnabled := IniRead(configFile, "DesktopIcons", "TripleClickEnabled", "0") = "1"
    defaultPresetSlot := Integer(IniRead(configFile, "DefaultSettings", "DefaultPresetSlot", "0"))
    defaultPresetEnabled := IniRead(configFile, "DefaultSettings", "DefaultPresetEnabled", "0") = "1"
}

; Load startup state
if FileExist(A_Startup "\Spatial Audio Switcher.lnk") {
    startupEnabled := true
}

; ----------------
; Helper Functions
; ----------------

Empty(*) {
}

RunSvcl(args, delayMs := 120, retries := 1) {
    exe := A_ScriptDir "\Resources\svcl.exe"

    if (retries < 1)
        retries := 1

    Loop retries {
        try {
            RunWait("`"" exe "`" " args, , "Hide")
        }

        if (delayMs > 0)
            Sleep delayMs
    }
}

SafeTraySetIcon(iconFile) {
    global activePresetIcon
    if (iconFile != "")
        activePresetIcon := iconFile
    try TraySetIcon(iconFile)
}

SafeMenuIcon(menuObj, itemName, iconFile) {
    try menuObj.SetIcon(itemName, iconFile)
}

SetMenuRadio(menuObj, checkedItem, items*) {
    for item in items {
        try menuObj.Uncheck(item)
    }

    try menuObj.Check(checkedItem)
}

UpdateStatusItem(newText, iconFile := "") {
    global Tray, CurrentStatusItem

    try {
        Tray.Rename(CurrentStatusItem, newText)
    } catch {
        try Tray.Add(newText, Empty)
    }

    CurrentStatusItem := newText

    if (iconFile != "") {
        try Tray.SetIcon(newText, iconFile)
    } else {
        try Tray.SetIcon(newText, "")
    }
}

; ----------------
; Volume & Audio Tools
; ----------------

SetMasterVolume(level) {
    SoundSetVolume(level)
    vol := Round(SoundGetVolume())
    ToolTip("Volume: " vol "%")
    SetTimer(() => ToolTip(), -1500)
}

AdjustMasterVolume(delta) {
    currentVol := SoundGetVolume()
    newVol := Min(100, Max(0, currentVol + delta))
    SoundSetVolume(newVol)
    ToolTip("Volume: " Round(newVol) "%")
    SetTimer(() => ToolTip(), -1500)
}

ToggleMasterMute(*) {
    isMuted := SoundGetMute()
    SoundSetMute(!isMuted)
    status := !isMuted ? "Muted" : "Unmuted"
    ToolTip("Audio " status)
    SetTimer(() => ToolTip(), -1500)
}

PopulateOutputDevicesMenu() {
    global OutputDevicesMenu
    OutputDevicesMenu.Delete()
    
    ; Query active playback devices using svcl
    tempFile := A_Temp "\svcl_devices.csv"
    try FileDelete(tempFile)
    
    RunWait('"' A_ScriptDir '\Resources\svcl.exe" /scomma "' tempFile '"', , "Hide")
    
    if FileExist(tempFile) {
        csvData := FileRead(tempFile)
        Loop Parse, csvData, "`n", "`r" {
            if (A_LoopField = "")
                continue
            
            fields := StrSplit(A_LoopField, ",")
            if (fields.Length >= 5) {
                deviceName := Trim(fields[1], '"')
                deviceType := Trim(fields[3], '"')
                deviceState := Trim(fields[5], '"')
                
                if (deviceType = "Render" && deviceState = "Active") {
                    OutputDevicesMenu.Add(deviceName, GetSetDeviceCallback(deviceName))
                    SafeMenuIcon(OutputDevicesMenu, deviceName, "Icons\output-device.ico")
                }
            }
        }
    }
	
    deviceCount := 0
	
    If (deviceCount = 0)
    {
        OutputDevicesMenu.Add("Open Windows Sound Panel", Traditional)
        SafeMenuIcon(OutputDevicesMenu, "Open Windows Sound Panel", "Icons\as-spe.ico")
    }
}

GetSetDeviceCallback(devName) {
    return (*) => (
        RunSvcl('/SetDefault "' devName '" 0', 100, 1),
        RunSvcl('/SetDefault "' devName '" 1', 100, 1),
        RunSvcl('/SetDefault "' devName '" 2', 100, 1),
        ToolTip("Default Output: " devName),
        SetTimer(() => ToolTip(), -1500)
    )
}

; ----------------
; System Tools (Taskbar Auto-Hide)
; ----------------

ToggleTaskbar(*) {
    static ABS_AUTOHIDE := 0x1
    static ABS_ALWAYSONTOP := 0x2

    APPBARDATA := Buffer(A_PtrSize = 8 ? 48 : 36, 0)
    NumPut("UInt", APPBARDATA.Size, APPBARDATA, 0)
    
    state := DllCall("Shell32\SHAppBarMessage", "UInt", 4, "Ptr", APPBARDATA.Ptr, "UInt")
    
    if (state & ABS_AUTOHIDE) {
        NumPut("UInt", ABS_ALWAYSONTOP, APPBARDATA, A_PtrSize = 8 ? 40 : 32)
        ToolTip("Taskbar: Always On Top")
    } else {
        NumPut("UInt", ABS_AUTOHIDE, APPBARDATA, A_PtrSize = 8 ? 40 : 32)
        ToolTip("Taskbar: Auto-Hide Enabled")
    }
    
    DllCall("Shell32\SHAppBarMessage", "UInt", 10, "Ptr", APPBARDATA.Ptr)
    SetTimer(() => ToolTip(), -1500)
    
    UpdateTaskbarMenu()
}

UpdateTaskbarMenu() {
    global Tray
    static ABS_AUTOHIDE := 0x1

    APPBARDATA := Buffer(A_PtrSize = 8 ? 48 : 36, 0)
    NumPut("UInt", APPBARDATA.Size, APPBARDATA, 0)
    state := DllCall("Shell32\SHAppBarMessage", "UInt", 4, "Ptr", APPBARDATA.Ptr, "UInt")

    if (state & ABS_AUTOHIDE) {
        try Tray.Check("Show/Hide Taskbar Auto-Hide")
    } else {
        try Tray.Uncheck("Show/Hide Taskbar Auto-Hide")
    }
}

; ----------------
; About GUI
; ----------------

ShowAbout(*) {
    version := "v1.07"
    date := "2026-08-18"
    author := "DestructiveBurn"
    dbUpdates := "https://destructiveburn.com/spatial-audio-switcher/"
    dbgitUpdates := "https://github.com/DestructiveBurn/spatial-audio-switcher/"
    soundVolCmd := "https://www.nirsoft.net/utils/sound_volume_command_line.html"
    soundVolView := "https://www.nirsoft.net/utils/sound_volume_view.html"

    aboutGui := Gui("+AlwaysOnTop -SysMenu -Caption +Border", "About Spatial Audio Switcher")
    aboutGui.BackColor := "2D2D2D"
    aboutGui.SetFont("cF5F5F5 s10", "Segoe UI")

    aboutGui.Add("Text", "x10 y10 w380 Center", "Spatial Audio Switcher " version " (" date ")")
    aboutGui.Add("Text", "x10 y+2 w380 Center", "Updated by " author)
    aboutGui.Add("Text", "x10 y+10 w380 0x10")

    changelog := "
    (LTrim
    [ChangeLog v1.07]
	• Changed Presets menu structure.
	• Added Enable Default Switching On Launch.
    • Added the ability to create Custom Preset Names
    • Added Volume Control Sub-Menu to both context menus.
    • Quick volume preset steps, step up/down adjustments, and mute toggle.
    • Added toggle taskbar auto-hide with shortcut.
    )"

    aboutGui.Add("Text", "x20 y+10 w360", changelog)
    aboutGui.Add("Text", "x10 y+10 w380 0x10")

    aboutGui.Add("Picture", "x20 y+10 w16 h16", "Icons\DB.ico")
    aboutGui.Add("Text", "x+5 yp+3", "DB Updates (Recommended): ")
    linkHere1 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere1.OnEvent("Click", (*) => Run(dbUpdates))

    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\gh.ico")
    aboutGui.Add("Text", "x+5 yp+3", "DB GitHub Updates: ")
    linkHere2 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere2.OnEvent("Click", (*) => Run(dbgitUpdates))

    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\nirsoft.ico")
    aboutGui.Add("Text", "x+5 yp+3", "SoundVolumeCommandLine: ")
    linkHere4 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere4.OnEvent("Click", (*) => Run(soundVolCmd))

    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\nirsoft.ico")
    aboutGui.Add("Text", "x+5 yp+3", "SoundVolumeView: ")
    linkHere5 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere5.OnEvent("Click", (*) => Run(soundVolView))

    aboutGui.Add("Text", "x10 y+10 w380 0x10")

    btnClose := aboutGui.Add("Button", "x150 y+10 w100 h30", "Close")
    btnClose.OnEvent("Click", (*) => aboutGui.Destroy())

    aboutGui.Show("AutoSize")
}

; ----------------
; Shortcuts GUI
; ----------------

ShowShortcuts(*) {
    shortcutsGui := Gui("+AlwaysOnTop -SysMenu -Caption +Border", "Spatial Audio Switcher Shortcuts")
    shortcutsGui.BackColor := "2D2D2D"
    shortcutsGui.SetFont("cF5F5F5 s10", "Segoe UI")

    shortcutsGui.Add("Text", "x10 y10 w380 Center", "Spatial Audio Switcher Shortcuts")
    shortcutsGui.Add("Text", "x10 y+10 w380 0x10")

    shortcutsText := "
    (LTrim
    Tray / Menu
    • Left-click tray icon: Opens quick Spatial Audio menu.
    • Right-click tray icon: Opens full Spatial Audio Switcher menu.

    Keyboard Shortcuts
    • Win + Alt + S: Opens quick Spatial Audio menu.
	• Win + Alt + T: Toggle taskbar auto-hide.
	• Win + Alt + S: Opens Left Spatial Audio Menu.
    • Ctrl + Alt + 1-5: Load Presets 1 through 5.
    )"

    shortcutsGui.Add("Text", "x20 y+10 w360", shortcutsText)
    shortcutsGui.Add("Text", "x10 y+10 w380 0x10")

    btnClose := shortcutsGui.Add("Button", "x150 y+10 w100 h30", "Close")
    btnClose.OnEvent("Click", (*) => shortcutsGui.Destroy())

    shortcutsGui.Show("AutoSize")
}

; ----------------
; Desktop Icon Toggle
; ----------------

ToggleDesktopIcons(*) {
    global tripleClickEnabled, configFile

    tripleClickEnabled := !tripleClickEnabled
    IniWrite(tripleClickEnabled ? "1" : "0", configFile, "DesktopIcons", "TripleClickEnabled")
    UpdateDesktopIconsMenu()
}

UpdateDesktopIconsMenu() {
    global tripleClickEnabled, Tray

    if (tripleClickEnabled) {
        try Tray.Check("Shows/Hide Desktop Icons Triple-Click")
    } else {
        try Tray.Uncheck("Shows/Hide Desktop Icons Triple-Click")
    }
}

#HotIf WinActive("ahk_class Progman") && tripleClickEnabled
~LButton::
{
    static clickCount := 0
    static lastClickTime := 0

    currentTime := A_TickCount
    timeSinceLastClick := currentTime - lastClickTime

    if (timeSinceLastClick > 400) {
        clickCount := 1
    } else {
        clickCount += 1
    }

    lastClickTime := currentTime

    if (clickCount = 3) {
        clickCount := 0

        global desktopIconsVisible

        try {
            if (hwnd := ControlGetHwnd("SysListView321", "ahk_class Progman")) {
                if (desktopIconsVisible) {
                    WinHide("ahk_id " hwnd)
                } else {
                    WinShow("ahk_id " hwnd)
                }

                desktopIconsVisible := !desktopIconsVisible
            }
        }
    }
}
#HotIf

; ----------------
; Save / Restore
; ----------------

SaveCurrentSettings() {
    global currentSpatial, currentSpeakerConfig, currentDefaultFormat, currentExclusivity, configFile

    IniWrite(currentSpatial,        configFile, "AudioSettings", "Spatial")
    IniWrite(currentSpeakerConfig,  configFile, "AudioSettings", "SpeakerConfig")
    IniWrite(currentDefaultFormat,  configFile, "AudioSettings", "DefaultFormat")
    IniWrite(currentExclusivity,    configFile, "AudioSettings", "Exclusivity")
}

RestoreSavedSettings() {
    global configFile

    savedSpatial        := IniRead(configFile, "AudioSettings", "Spatial", "")
    savedSpeakerConfig := IniRead(configFile, "AudioSettings", "SpeakerConfig", "Stereo")
    savedDefaultFormat := IniRead(configFile, "AudioSettings", "DefaultFormat", "16 Bit, 44100 Hz")
    savedExclusivity   := IniRead(configFile, "AudioSettings", "Exclusivity", "Not Exclusive")

    ApplySpatialSetting(savedSpatial, false)
    ApplySpeakerConfig(savedSpeakerConfig, false)
    ApplyDefaultFormat(savedDefaultFormat, false)
    ApplyExclusivity(savedExclusivity, false)

    SaveCurrentSettings()
}

; ----------------
; Audio Apply Functions
; ----------------

TriggerTemporaryAtmosIcon() {
    global atmosTimerActive, activePresetIcon
    if (FileExist("Icons\dolby.ico")) {
        try TraySetIcon("Icons\dolby.ico")
        atmosTimerActive := true
        SetTimer(RevertTrayIcon, -3000)
    }
}

RevertTrayIcon() {
    global atmosTimerActive, activePresetIcon
    atmosTimerActive := false
    if (activePresetIcon != "" && FileExist(activePresetIcon)) {
        try TraySetIcon(activePresetIcon)
    } else {
        try TraySetIcon("Icons\icon.ico")
    }
}

ApplySpatialSetting(spatialType, save := true) {
    global currentSpatial, Tray, SpatialMenu

    switch spatialType {
        case "":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"`"", 150, 1)
            SafeTraySetIcon("Icons\icon.ico")
            UpdateStatusItem("Disabled")
            try Tray.Disable("&Disable Spatial Audio")
            try SpatialMenu.Disable("&Disable Spatial Audio")
            currentSpatial := ""

        case "Dolby Atmos":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"Dolby Atmos`"", 150, 1)
            TriggerTemporaryAtmosIcon()
            UpdateStatusItem("Dolby Atmos for Headphones", "Icons\dolby.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "Dolby Atmos"

        case "Dolby Atmos HT":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"Dolby Atmos for home theater`"", 150, 1)
            TriggerTemporaryAtmosIcon()
            UpdateStatusItem("Dolby Atmos for Home Theater", "Icons\dolby.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "Dolby Atmos HT"

        case "DTS":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"DTS`"", 150, 1)
            SafeTraySetIcon("Icons\dts.ico")
            UpdateStatusItem("DTS Headphone:X", "Icons\dts.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "DTS"

        case "DTS:X HT":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"DTS:X for home theater`"", 150, 1)
            SafeTraySetIcon("Icons\dts.ico")
            UpdateStatusItem("DTS:X for Home Theater", "Icons\dts.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "DTS:X HT"

        case "Windows Sonic":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"{b53d940c-b846-4831-9f76-d102b9b725a0}`"", 150, 1)
            SafeTraySetIcon("Icons\sonic.ico")
            UpdateStatusItem("Windows Sonic for Headphones", "Icons\sonic.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "Windows Sonic"
    }

    if (save)
        SaveCurrentSettings()
}

ApplySpeakerConfig(config, save := true) {
    global currentSpeakerConfig, Configuration, SpeakerMasks

    if !SpeakerMasks.Has(config)
        return

    mask := SpeakerMasks[config]
    RunSvcl("/SetSpeakersConfig `"DefaultRenderDevice`" " mask " " mask " " mask, 175, 2)

    SetMenuRadio(
        Configuration,
        "&" config,
        "&Stereo",
        "&Quadraphonic",
        "&5.1",
        "&7.1"
    )

    currentSpeakerConfig := config

    if (save)
        SaveCurrentSettings()
}

ApplyDefaultFormat(format, save := true) {
    global currentDefaultFormat, DefaultFormat, DefaultFormats

    if !DefaultFormats.Has(format)
        return

    data := DefaultFormats[format]
    bits := data[1]
    hz := data[2]

    RunSvcl("/SetDefaultFormat `"DefaultRenderDevice`" " bits " " hz, 125, 1)

    SetMenuRadio(
        DefaultFormat,
        format,
        "16 Bit, 44100 Hz",
        "16 Bit, 48000 Hz",
        "16 Bit, 96000 Hz",
        "16 Bit, 192000 Hz",
        "24 Bit, 44100 Hz",
        "24 Bit, 48000 Hz",
        "24 Bit, 96000 Hz",
        "24 Bit, 192000 Hz"
    )

    currentDefaultFormat := format

    if (save)
        SaveCurrentSettings()
}

ApplyExclusivity(exclusive, save := true) {
    global currentExclusivity, Exclusivity

    if (exclusive = "Exclusive") {
        RunSvcl("/SetAllowExclusive `"DefaultRenderDevice`" 1", 100, 1)
        try Exclusivity.Check("&Exclusive")
        try Exclusivity.Uncheck("&Not Exclusive")
        currentExclusivity := "Exclusive"
    } else {
        RunSvcl("/SetAllowExclusive `"DefaultRenderDevice`" 0", 100, 1)
        try Exclusivity.Uncheck("&Exclusive")
        try Exclusivity.Check("&Not Exclusive")
        currentExclusivity := "Not Exclusive"
    }

    if (save)
        SaveCurrentSettings()
}

; ----------------
; Compatibility Wrappers
; ----------------

Disable(*)            => ApplySpatialSetting("")
DolbyAtmosEnable(*)  => ApplySpatialSetting("Dolby Atmos")
DolbyAtmosHTEnable(*) => ApplySpatialSetting("Dolby Atmos HT")
DTSEnable(*)         => ApplySpatialSetting("DTS")
DTSXHTEnable(*)      => ApplySpatialSetting("DTS:X HT")
SonicEnable(*)       => ApplySpatialSetting("Windows Sonic")

Stereo(*)            => ApplySpeakerConfig("Stereo")
Quadraphonic(*)      => ApplySpeakerConfig("Quadraphonic")
FivePointOne(*)      => ApplySpeakerConfig("5.1")
SevenPointOne(*)     => ApplySpeakerConfig("7.1")

SetExclusive(*)      => ApplyExclusivity("Exclusive")
SetNonExclusive(*)   => ApplyExclusivity("Not Exclusive")

; ----------------
; External Apps
; ----------------

DolbyAccess(*) {
    Run "explorer.exe shell:appsFolder\DolbyLaboratories.DolbyAccess_rz1tebttyb220!App"
}

DTSSoundUnbound(*) {
    Run "explorer.exe shell:appsFolder\DTSInc.DTSSoundUnbound_t5j2fzbtdg37r!App"
}

Advanced(*) {
    Run "Resources\SoundVolumeView.exe"
}

Modern(*) {
    Run "ms-settings:sound"
}

Traditional(*) {
    Run "control mmsys.cpl sounds"
}

Volume(*) {
    Run "ms-settings:apps-volume"
}

Spatial(*) {
    global SpatialMenu
    PopulateOutputDevicesMenu()
    SpatialMenu.Show()
}

; ----------------
; Presets
; ----------------

GetPresetName(slot) {
    global configFile
    return IniRead(configFile, "Preset" slot, "Name", "Preset " slot)
}

SetPresetName(slot, name) {
    global configFile
    name := SubStr(Trim(name), 1, 32)
    if (name = "")
        name := "Preset " slot
    IniWrite(name, configFile, "Preset" slot, "Name")
    UpdatePresetsMenu()
}

PromptRenamePreset(slot) {
    currentName := GetPresetName(slot)
	
    iconFile := IniRead(configFile, "Preset" slot, "IconFile", "Icons\preset" slot ".ico")
    if (!FileExist(iconFile))
        iconFile := "Icons\preset1.ico"

    renameGui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox +Owner", "Rename Preset " slot)
    renameGui.BackColor := "2D2D2D"
    renameGui.SetFont("cF5F5F5 s10", "Segoe UI")

    renameGui.Add("Text", "x15 y15 w270", "Enter profile name (Max 32 chars):")
    editName := renameGui.Add("Edit", "x15 y+8 w270 c000000 Limit32", currentName)

    btnSave := renameGui.Add("Button", "x60 y+15 w80 h28 Default", "Save")
    btnCancel := renameGui.Add("Button", "x150 yp w80 h28", "Cancel")

    btnSave.OnEvent("Click", (*) => (SetPresetName(slot, editName.Value), renameGui.Destroy()))
    btnCancel.OnEvent("Click", (*) => renameGui.Destroy())

    renameGui.Show("w300 h125")
	
    if FileExist(iconFile) {
        hIcon := LoadPicture(iconFile, "w32 h32", &imgType)
        if (hIcon) {
            SendMessage(0x0080, 0, hIcon, renameGui.Hwnd)
            SendMessage(0x0080, 1, hIcon, renameGui.Hwnd)
        }
    }
}

SavePreset(slot) {
    global configFile, currentSpatial, currentSpeakerConfig, currentDefaultFormat, currentExclusivity

    slot := Integer(slot)
    if (slot < 1 || slot > 5)
        return

    section := "Preset" slot

    IniWrite(currentSpatial,       configFile, section, "Spatial")
    IniWrite(currentSpeakerConfig, configFile, section, "SpeakerConfig")
    IniWrite(currentDefaultFormat, configFile, section, "DefaultFormat")
    IniWrite(currentExclusivity,   configFile, section, "Exclusivity")

    if (IniRead(configFile, section, "IconFile", "") = "") {
        IniWrite("Icons\preset" slot ".ico", configFile, section, "IconFile")
    }

    UpdatePresetsMenu()
}

LoadPreset(slot) {
    global configFile

    slot := Integer(slot)
    if (slot < 1 || slot > 5)
        return

    section := "Preset" slot

    presetSpatial := IniRead(configFile, section, "Spatial", "")
    presetSpeaker := IniRead(configFile, section, "SpeakerConfig", "")

    if (presetSpatial = "" && presetSpeaker = "")
        return

    presetFormat   := IniRead(configFile, section, "DefaultFormat", "16 Bit, 44100 Hz")
    presetExcl     := IniRead(configFile, section, "Exclusivity", "Not Exclusive")
    presetIconFile := IniRead(configFile, section, "IconFile", "")

    ApplySpatialSetting(presetSpatial, false)
    Sleep 150
    ApplySpeakerConfig(presetSpeaker, false)
    Sleep 100
    ApplyDefaultFormat(presetFormat, false)
    Sleep 75
    ApplyExclusivity(presetExcl, false)

    if (presetIconFile != "" && FileExist(presetIconFile)) {
        SafeTraySetIcon(presetIconFile)
    }

    SaveCurrentSettings()
}

DeletePreset(slot) {
    global configFile

    slot := Integer(slot)
    if (slot < 1 || slot > 5)
        return

    section := "Preset" slot

    for key in ["Spatial", "SpeakerConfig", "DefaultFormat", "Exclusivity", "IconFile"] {
        IniWrite("", configFile, section, key)
    }

    UpdatePresetsMenu()
}

UpdatePresetsMenu() {
    global PresetsMenu, DefaultPresetMenu, configFile, defaultPresetSlot, defaultPresetEnabled

    if !IsObject(PresetsMenu)
        return

    PresetsMenu.Delete()

    Loop 5 {
        slot := A_Index
        pName := GetPresetName(slot)
        section := "Preset" slot
        hasData := false

        if FileExist(configFile) {
            s  := IniRead(configFile, section, "Spatial", "")
            sp := IniRead(configFile, section, "SpeakerConfig", "")
            df := IniRead(configFile, section, "DefaultFormat", "")
            ex := IniRead(configFile, section, "Exclusivity", "")

            if (s != "" || sp != "" || df != "" || ex != "")
                hasData := true
        }

        itemMenu := Menu()

        itemMenu.Add("Load", GetLoadPresetCallback(slot))
        SafeMenuIcon(itemMenu, "Load", "Icons\preset.ico")
        if (!hasData)
            itemMenu.Disable("Load")

        itemMenu.Add("Save Current State", GetSavePresetCallback(slot))
        SafeMenuIcon(itemMenu, "Save Current State", "Icons\preset.ico")

        itemMenu.Add("Rename", GetRenamePresetCallback(slot))
        SafeMenuIcon(itemMenu, "Rename", "Icons\preset.ico")

        itemMenu.Add("Delete", GetDeletePresetCallback(slot))
        SafeMenuIcon(itemMenu, "Delete", "Icons\preset.ico")
        if (!hasData)
            itemMenu.Disable("Delete")

        PresetsMenu.Add(pName, itemMenu)
        SafeMenuIcon(PresetsMenu, pName, "Icons\preset.ico")

        if (hasData)
            PresetsMenu.Check(pName)
    }

    PresetsMenu.Add() ; Separator

    DefaultPresetMenu := Menu()
    PresetsMenu.Add("Default Startup Preset Settings", DefaultPresetMenu)

    DefaultPresetMenu.Add("Enable Default Switching On Launch", ToggleDefaultSwitching)
    if (defaultPresetEnabled)
        DefaultPresetMenu.Check("Enable Default Switching On Launch")

    DefaultPresetMenu.Add()
    DefaultPresetMenu.Add("None", (*) => SetDefaultPresetSlot(0))
    if (defaultPresetSlot = 0)
        DefaultPresetMenu.Check("None")

    Loop 5 {
        slot := A_Index
        pName := GetPresetName(slot)
        DefaultPresetMenu.Add(pName, GetSetDefaultSlotCallback(slot))
        if (defaultPresetSlot = slot)
            DefaultPresetMenu.Check(pName)
    }
}

ToggleDefaultSwitching(*) {
    global defaultPresetEnabled, configFile
    defaultPresetEnabled := !defaultPresetEnabled
    IniWrite(defaultPresetEnabled ? "1" : "0", configFile, "DefaultSettings", "DefaultPresetEnabled")
    UpdatePresetsMenu()
}

SetDefaultPresetSlot(slot) {
    global defaultPresetSlot, configFile
    defaultPresetSlot := slot
    IniWrite(slot, configFile, "DefaultSettings", "DefaultPresetSlot")
    UpdatePresetsMenu()
}

GetSetDefaultSlotCallback(slot) {
    return (*) => SetDefaultPresetSlot(slot)
}

GetRenamePresetCallback(slot) {
    return (*) => PromptRenamePreset(slot)
}

GetSavePresetCallback(slot) {
    return (*) => SavePreset(slot)
}

GetLoadPresetCallback(slot) {
    return (*) => LoadPreset(slot)
}

GetDeletePresetCallback(slot) {
    return (*) => DeletePreset(slot)
}

GetDefaultFormatCallback(formatName) {
    return (*) => ApplyDefaultFormat(formatName)
}

ApplyPresetIconForCurrentSettings() {
    global configFile, currentSpatial, currentSpeakerConfig, currentDefaultFormat, currentExclusivity

    if !FileExist(configFile)
        return

    Loop 5 {
        section := "Preset" A_Index

        pSpatial := IniRead(configFile, section, "Spatial", "")
        pSpeaker := IniRead(configFile, section, "SpeakerConfig", "")
        pFormat  := IniRead(configFile, section, "DefaultFormat", "")
        pExcl    := IniRead(configFile, section, "Exclusivity", "")
        pIcon    := IniRead(configFile, section, "IconFile", "")

        if (pSpatial = "" && pSpeaker = "" && pFormat = "" && pExcl = "")
            continue

        if (pSpatial = currentSpatial
         && pSpeaker = currentSpeakerConfig
         && pFormat  = currentDefaultFormat
         && pExcl    = currentExclusivity) {
            if (pIcon != "" && FileExist(pIcon))
                SafeTraySetIcon(pIcon)

            break
        }
    }
}

CheckStartupPreset() {
    global defaultPresetEnabled, defaultPresetSlot
    if (defaultPresetEnabled && defaultPresetSlot > 0) {
        LoadPreset(defaultPresetSlot)
    }
}

; ----------------
; Startup
; ----------------

ToggleStartup(*) {
    global startupEnabled

    if (startupEnabled) {
        try FileDelete A_Startup "\Spatial Audio Switcher.lnk"
        startupEnabled := false
    } else {
        FileCreateShortcut A_ScriptFullPath, A_Startup "\Spatial Audio Switcher.lnk"
        startupEnabled := true
    }

    UpdateStartupMenu()
}

UpdateStartupMenu() {
    global startupEnabled, Tray

    if (startupEnabled) {
        try Tray.Check("Start with &Windows")
    } else {
        try Tray.Uncheck("Start with &Windows")
    }
}

Restart(*) {
    SaveCurrentSettings()
    Reload
}

Exit(*) {
    ExitApp
}

; ----------------
; Menu Creation
; ----------------

Tray := A_TrayMenu
Tray.Delete()

SafeTraySetIcon("Icons\icon.ico")
A_IconTip := "Spatial Audio Switcher"

SpatialMenu := Menu()
Select := Menu()
Settings := Menu()
Configuration := Menu()
DefaultFormat := Menu()
Exclusivity := Menu()
SpatialApps := Menu()
PresetsMenu := Menu()
VolumeMenu := Menu()
OutputDevicesMenu := Menu()

; Construct Output Devices Sub-Menu
PopulateOutputDevicesMenu()

; Construct Volume Control Sub-Menu
VolumeMenu.Add("Mute / Unmute", ToggleMasterMute)
SafeMenuIcon(VolumeMenu, "Mute / Unmute", "Icons\volume-mixer.ico")
VolumeMenu.Add()
VolumeMenu.Add("100%", (*) => SetMasterVolume(100))
VolumeMenu.Add("80%", (*) => SetMasterVolume(80))
VolumeMenu.Add("60%", (*) => SetMasterVolume(60))
VolumeMenu.Add("40%", (*) => SetMasterVolume(40))
VolumeMenu.Add("20%", (*) => SetMasterVolume(20))
VolumeMenu.Add()
VolumeMenu.Add("Volume Up (+5%)", (*) => AdjustMasterVolume(5))
VolumeMenu.Add("Volume Down (-5%)", (*) => AdjustMasterVolume(-5))
VolumeMenu.Add()
VolumeMenu.Add("Open Windows Volume Mixer", Volume)
SafeMenuIcon(VolumeMenu, "Open Windows Volume Mixer", "Icons\volume-mixer.ico")

; Main Tray Menu
Tray.Add("Disabled", Empty)

Tray.Add("&Disable Spatial Audio", Disable)
SafeMenuIcon(Tray, "&Disable Spatial Audio", "Icons\disable.ico")
Tray.Disable("&Disable Spatial Audio")

Tray.Add()

Tray.Add("&Spatial Audio", Select)
SafeMenuIcon(Tray, "&Spatial Audio", "Icons\spatial-audio.ico")

Select.Add("Dolby Atm&os for Headphones", DolbyAtmosEnable)
SafeMenuIcon(Select, "Dolby Atm&os for Headphones", "Icons\dolby.ico")

Select.Add("Dolby Atmos for Home Theater", DolbyAtmosHTEnable)
SafeMenuIcon(Select, "Dolby Atmos for Home Theater", "Icons\dolby.ico")

Select.Add("DTS Headphone:&X", DTSEnable)
SafeMenuIcon(Select, "DTS Headphone:&X", "Icons\dts.ico")

Select.Add("DTS:X for Home Theater", DTSXHTEnable)
SafeMenuIcon(Select, "DTS:X for Home Theater", "Icons\dts.ico")

Select.Add("Windows &Sonic for Headphones", SonicEnable)
SafeMenuIcon(Select, "Windows &Sonic for Headphones", "Icons\sonic.ico")

Tray.Add("Playback &Device Switcher", OutputDevicesMenu)
SafeMenuIcon(Tray, "Playback &Device Switcher", "Icons\output-device.ico")

Tray.Add("&Audio Settings", Settings)
SafeMenuIcon(Tray, "&Audio Settings", "Icons\audio-settings.ico")

Settings.Add("&Advanced", Advanced)
SafeMenuIcon(Settings, "&Advanced", "Icons\as-svv.ico")

Settings.Add("&Modern", Modern)
SafeMenuIcon(Settings, "&Modern", "Icons\as-set.ico")

Settings.Add("&Traditional", Traditional)
SafeMenuIcon(Settings, "&Traditional", "Icons\as-spe.ico")

Tray.Add("Speaker &Configuration", Configuration)
SafeMenuIcon(Tray, "Speaker &Configuration", "Icons\speaker-configuration.ico")

Configuration.Add("&Stereo", Stereo)
SafeMenuIcon(Configuration, "&Stereo", "Icons\sc-s.ico")

Configuration.Add("&Quadraphonic", Quadraphonic)
SafeMenuIcon(Configuration, "&Quadraphonic", "Icons\sc-q.ico")

Configuration.Add("&5.1", FivePointOne)
SafeMenuIcon(Configuration, "&5.1", "Icons\sc-5.1.ico")

Configuration.Add("&7.1", SevenPointOne)
SafeMenuIcon(Configuration, "&7.1", "Icons\sc-7.1.ico")

Tray.Add("Default &Format", DefaultFormat)
SafeMenuIcon(Tray, "Default &Format", "Icons\default-format.ico")

for formatName, data in DefaultFormats {
    DefaultFormat.Add(formatName, GetDefaultFormatCallback(formatName))
    SafeMenuIcon(DefaultFormat, formatName, "Icons\df.ico")
}

Tray.Add("&Exclusivity", Exclusivity)
SafeMenuIcon(Tray, "&Exclusivity", "Icons\exclusivity.ico")

Exclusivity.Add("&Exclusive", SetExclusive)
SafeMenuIcon(Exclusivity, "&Exclusive", "Icons\exclusivity.ico")

Exclusivity.Add("&Not Exclusive", SetNonExclusive)
SafeMenuIcon(Exclusivity, "&Not Exclusive", "Icons\exclusivity.ico")

Tray.Add("&Presets", PresetsMenu)
SafeMenuIcon(Tray, "&Presets", "Icons\preset.ico")

Tray.Add()

; Utility Features Section (Tray Menu)
Tray.Add("Show/Hide Taskbar Auto-Hide", ToggleTaskbar)
SafeMenuIcon(Tray, "Show/Hide Taskbar Auto-Hide", "Icons\taskbar.ico")

Tray.Add("Shows/Hide Desktop Icons Triple-Click", ToggleDesktopIcons)
SafeMenuIcon(Tray, "Shows/Hide Desktop Icons Triple-Click", "Icons\showhide.ico")
UpdateDesktopIconsMenu()

Tray.Add()

; Attach Volume Control to Bottom of Tray Menu
Tray.Add("&Volume Control", VolumeMenu)
SafeMenuIcon(Tray, "&Volume Control", "Icons\volume-mixer.ico")

Tray.Add()

Tray.Add("Start with &Windows", ToggleStartup)
SafeMenuIcon(Tray, "Start with &Windows", "Icons\startup.ico")
UpdateStartupMenu()

Tray.Add("&Reload", Restart)
SafeMenuIcon(Tray, "&Reload", "Icons\reload.ico")

Tray.Add("E&xit", Exit)
SafeMenuIcon(Tray, "E&xit", "Icons\exit.ico")

Tray.Add()

Tray.Add("About", ShowAbout)
SafeMenuIcon(Tray, "About", "Icons\about.ico")

Tray.Add("Shortcuts", ShowShortcuts)
SafeMenuIcon(Tray, "Shortcuts", "Icons\shortcuts.ico")

Tray.Add("Donate", (*) => Run("https://www.paypal.com/donate?hosted_button_id=ZJGYBNSCSDFBG"))
SafeMenuIcon(Tray, "Donate", "Icons\donate.ico")

; Quick Spatial Audio Menu (Left-Click)
SpatialMenu.Add("&Disable Spatial Audio", Disable)
SafeMenuIcon(SpatialMenu, "&Disable Spatial Audio", "Icons\disable.ico")
SpatialMenu.Disable("&Disable Spatial Audio")

SpatialMenu.Add()

SpatialMenu.Add("Dolby Atm&os for Headphones", DolbyAtmosEnable)
SafeMenuIcon(SpatialMenu, "Dolby Atm&os for Headphones", "Icons\dolby.ico")

SpatialMenu.Add("Dolby Atmos for Home Theater", DolbyAtmosHTEnable)
SafeMenuIcon(SpatialMenu, "Dolby Atmos for Home Theater", "Icons\dolby.ico")

SpatialMenu.Add("DTS Headphone:&X", DTSEnable)
SafeMenuIcon(SpatialMenu, "DTS Headphone:&X", "Icons\dts.ico")

SpatialMenu.Add("DTS:X for Home Theater", DTSXHTEnable)
SafeMenuIcon(SpatialMenu, "DTS:X for Home Theater", "Icons\dts.ico")

SpatialMenu.Add("Windows &Sonic for Headphones", SonicEnable)
SafeMenuIcon(SpatialMenu, "Windows &Sonic for Headphones", "Icons\sonic.ico")

SpatialMenu.Add()

SpatialMenu.Add("&Presets", PresetsMenu)
SafeMenuIcon(SpatialMenu, "&Presets", "Icons\preset.ico")

SpatialMenu.Add("Speaker &Configuration", Configuration)
SafeMenuIcon(SpatialMenu, "Speaker &Configuration", "Icons\speaker-configuration.ico")

SpatialMenu.Add("&Applications", SpatialApps)
SafeMenuIcon(SpatialMenu, "&Applications", "Icons\spatial-audio.ico")

SpatialApps.Add("&Dolby Access", DolbyAccess)
SafeMenuIcon(SpatialApps, "&Dolby Access", "Icons\dolby.ico")

SpatialApps.Add("DTS Sound &Unbound", DTSSoundUnbound)
SafeMenuIcon(SpatialApps, "DTS Sound &Unbound", "Icons\dts.ico")

SpatialMenu.Add("&Sound", Traditional)
SafeMenuIcon(SpatialMenu, "&Sound", "Icons\as-spe.ico")

SpatialMenu.Add()

; Attach Volume Control to Bottom of Quick Spatial Menu
SpatialMenu.Add("&Volume Control", VolumeMenu)
SafeMenuIcon(SpatialMenu, "&Volume Control", "Icons\volume-mixer.ico")

Tray.Add()
Tray.Add("Spatial Audio Switcher", Spatial)
Tray.Default := "Spatial Audio Switcher"
Tray.Disable("Spatial Audio Switcher")
Tray.ClickCount := 1

; ----------------
; Hotkeys
; ----------------

#!s::SpatialMenu.Show()
#!t::ToggleTaskbar()

^!1::LoadPreset(1)
^!2::LoadPreset(2)
^!3::LoadPreset(3)
^!4::LoadPreset(4)
^!5::LoadPreset(5)

; ----------------
; Initialization
; ----------------

RestoreSavedSettings()
UpdatePresetsMenu()
CheckStartupPreset()
ApplyPresetIconForCurrentSettings()
UpdateTaskbarMenu()

; END

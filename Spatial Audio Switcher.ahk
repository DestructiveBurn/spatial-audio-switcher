#Requires AutoHotkey v2.0

; ============================================================
; Spatial Audio Switcher
; Updated by DestructiveBurn
; v1.06
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

; Load saved desktop icon triple-click setting.
if FileExist(configFile) {
    tripleClickEnabled := IniRead(configFile, "DesktopIcons", "TripleClickEnabled", "0") = "1"
}

; Load startup state.
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
; About GUI
; ----------------

ShowAbout(*) {
    version := "v1.06"
    date := "2026-08-01"
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

    [ChangeLog v1.05]
    • Changes & Addons
      - Added Presets system (up to 5 presets).
      - Each preset stores Spatial, Speaker Configuration, Default Format, and Exclusivity.
      - Presets can be saved, loaded, and deleted from the tray menu.
      - SoundVolumeCommandLine updated through the DB site packaged version.

    [ChangeLog v1.06]
    • Changes & Addons
      - Improved preset switching reliability.
      - Speaker configuration changes now run synchronously and retry once.
      - Added Ctrl + Alt + 1 through Ctrl + Alt + 5 preset shortcuts.
      - Added Shortcuts window to the tray menu.
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
    • Left-click tray icon:
      Opens the quick Spatial Audio menu.

    • Right-click tray icon:
      Opens the full Spatial Audio Switcher menu.

    Keyboard Shortcuts
    • Windows + Alt + S:
      Opens the quick Spatial Audio menu.

    Preset Shortcuts
    • Ctrl + Alt + 1:
      Load Preset 1

    • Ctrl + Alt + 2:
      Load Preset 2

    • Ctrl + Alt + 3:
      Load Preset 3

    • Ctrl + Alt + 4:
      Load Preset 4

    • Ctrl + Alt + 5:
      Load Preset 5

    Optional Desktop Icon Toggle
    • Triple-click desktop:
      Shows or hides desktop icons when enabled in the tray menu.
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

    savedSpatial       := IniRead(configFile, "AudioSettings", "Spatial", "")
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
            SafeTraySetIcon("Icons\dolby.ico")
            UpdateStatusItem("Dolby Atmos for Headphones", "Icons\dolby.ico")
            try Tray.Enable("&Disable Spatial Audio")
            try SpatialMenu.Enable("&Disable Spatial Audio")
            currentSpatial := "Dolby Atmos"

        case "Dolby Atmos HT":
            RunSvcl("/SetSpatial `"DefaultRenderDevice`" `"Dolby Atmos for home theater`"", 150, 1)
            SafeTraySetIcon("Icons\dolby.ico")
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

    ; Reliability improvement:
    ; Speaker config changes can occasionally fail when switching quickly.
    ; RunWait makes it synchronous, and retrying once helps when Windows/audio driver lags.
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

Disable(*)          => ApplySpatialSetting("")
DolbyAtmosEnable(*) => ApplySpatialSetting("Dolby Atmos")
DolbyAtmosHTEnable(*) => ApplySpatialSetting("Dolby Atmos HT")
DTSEnable(*)        => ApplySpatialSetting("DTS")
DTSXHTEnable(*)     => ApplySpatialSetting("DTS:X HT")
SonicEnable(*)      => ApplySpatialSetting("Windows Sonic")

Stereo(*)           => ApplySpeakerConfig("Stereo")
Quadraphonic(*)     => ApplySpeakerConfig("Quadraphonic")
FivePointOne(*)     => ApplySpeakerConfig("5.1")
SevenPointOne(*)    => ApplySpeakerConfig("7.1")

df1644(*)           => ApplyDefaultFormat("16 Bit, 44100 Hz")
df1648(*)           => ApplyDefaultFormat("16 Bit, 48000 Hz")
df1696(*)           => ApplyDefaultFormat("16 Bit, 96000 Hz")
df16192(*)          => ApplyDefaultFormat("16 Bit, 192000 Hz")
df2444(*)           => ApplyDefaultFormat("24 Bit, 44100 Hz")
df2448(*)           => ApplyDefaultFormat("24 Bit, 48000 Hz")
df2496(*)           => ApplyDefaultFormat("24 Bit, 96000 Hz")
df24192(*)          => ApplyDefaultFormat("24 Bit, 192000 Hz")

SetExclusive(*)     => ApplyExclusivity("Exclusive")
SetNonExclusive(*)  => ApplyExclusivity("Not Exclusive")

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
    SpatialMenu.Show()
}

; ----------------
; Presets
; ----------------

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

    if (presetSpatial = "" && presetSpeaker = "") {
        return
    }

    presetFormat   := IniRead(configFile, section, "DefaultFormat", "16 Bit, 44100 Hz")
    presetExcl     := IniRead(configFile, section, "Exclusivity", "Not Exclusive")
    presetIconFile := IniRead(configFile, section, "IconFile", "")

    ; Apply in this order:
    ; 1. Spatial audio
    ; 2. Speaker configuration
    ; 3. Default format
    ; 4. Exclusivity
    ;
    ; Speaker configuration uses RunWait and a retry to reduce missed changes.
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

SavePreset1(*)   => SavePreset(1)
SavePreset2(*)   => SavePreset(2)
SavePreset3(*)   => SavePreset(3)
SavePreset4(*)   => SavePreset(4)
SavePreset5(*)   => SavePreset(5)

LoadPreset1(*)   => LoadPreset(1)
LoadPreset2(*)   => LoadPreset(2)
LoadPreset3(*)   => LoadPreset(3)
LoadPreset4(*)   => LoadPreset(4)
LoadPreset5(*)   => LoadPreset(5)

DeletePreset1(*) => DeletePreset(1)
DeletePreset2(*) => DeletePreset(2)
DeletePreset3(*) => DeletePreset(3)
DeletePreset4(*) => DeletePreset(4)
DeletePreset5(*) => DeletePreset(5)

UpdatePresetsMenu() {
    global PresetsMenu, configFile

    if !IsObject(PresetsMenu)
        return

    Loop 5 {
        section := "Preset" A_Index
        hasData := false

        if FileExist(configFile) {
            s  := IniRead(configFile, section, "Spatial", "")
            sp := IniRead(configFile, section, "SpeakerConfig", "")
            df := IniRead(configFile, section, "DefaultFormat", "")
            ex := IniRead(configFile, section, "Exclusivity", "")

            if (s != "" || sp != "" || df != "" || ex != "")
                hasData := true
        }

        loadItemName := "Load Preset " A_Index
        deleteItemName := "Delete Preset " A_Index

        if (hasData) {
            try PresetsMenu.Enable(loadItemName)
            try PresetsMenu.Enable(deleteItemName)
        } else {
            try PresetsMenu.Disable(loadItemName)
            try PresetsMenu.Disable(deleteItemName)
        }
    }
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

; Main tray menu.
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

AddPresetMenuItems()

Tray.Add()
Tray.Add("&Volume Mixer", Volume)
SafeMenuIcon(Tray, "&Volume Mixer", "Icons\volume-mixer.ico")

Tray.Add()

Tray.Add("Shows/Hide Desktop Icons Triple-Click", ToggleDesktopIcons)
SafeMenuIcon(Tray, "Shows/Hide Desktop Icons Triple-Click", "Icons\showhide.ico")
UpdateDesktopIconsMenu()

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

; Simple left-click tray menu.
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

Tray.Add()
Tray.Add("Spatial Audio Switcher", Spatial)
Tray.Default := "Spatial Audio Switcher"
Tray.Disable("Spatial Audio Switcher")
Tray.ClickCount := 1

; ----------------
; Menu Helper Builders
; ----------------

AddPresetMenuItems() {
    global PresetsMenu

    Loop 5 {
        slot := A_Index

        PresetsMenu.Add("Save Preset " slot, GetSavePresetCallback(slot))
        SafeMenuIcon(PresetsMenu, "Save Preset " slot, "Icons\preset.ico")

        PresetsMenu.Add("Load Preset " slot, GetLoadPresetCallback(slot))
        SafeMenuIcon(PresetsMenu, "Load Preset " slot, "Icons\preset.ico")

        PresetsMenu.Add("Delete Preset " slot, GetDeletePresetCallback(slot))
        SafeMenuIcon(PresetsMenu, "Delete Preset " slot, "Icons\preset.ico")

        if (slot < 5)
            PresetsMenu.Add()
    }
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

; ----------------
; Hotkeys
; ----------------

; Opens quick Spatial Audio menu.
#!s::SpatialMenu.Show()

; Preset shortcuts.
^!1::LoadPreset(1)
^!2::LoadPreset(2)
^!3::LoadPreset(3)
^!4::LoadPreset(4)
^!5::LoadPreset(5)

; ----------------
; Startup Restore
; ----------------

RestoreSavedSettings()
ApplyPresetIconForCurrentSettings()
UpdatePresetsMenu()

; END

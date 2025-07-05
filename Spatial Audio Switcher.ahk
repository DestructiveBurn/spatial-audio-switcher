#Requires AutoHotkey v2.0

/*----------------
About GUI Function
----------------*/

ShowAbout(*)
{
    ; Version info
    version := "v1.03"
    date := "2025-07-04"
    author := "DestructiveBurn"
    website := "https://github.com/DestructiveBurn/spatial-audio-switcher/"
    github := "https://github.com/Tremontaine/spatial-audio-switcher"

    ; Create compact GUI
    aboutGui := Gui("+AlwaysOnTop -SysMenu -Caption +Border", "About Spatial Audio Switcher")
    aboutGui.BackColor := "2D2D2D"
    aboutGui.SetFont("cF5F5F5 s10", "Segoe UI")
    
    ; Title and version with date
    aboutGui.Add("Text", "x10 y10 w380 Center", "Spatial Audio Switcher " version " (" date ")")
    aboutGui.Add("Text", "x10 y+2 w380 Center", "Updated by " author)
    aboutGui.Add("Text", "x10 y+10 w380 0x10") ; Horizontal line

    ;-----ChangeLog-----
    ; Update List - now with proper left alignment
    changelog := "
    (LTrim
    [ChangeLog v1.02]
    • Spatial Audio Formats:
      - Added Dolby Atmos for Home Theater support.
      - Added DTS:X for Home Theater support.

    • Speaker Configurations:
      - Added Quadraphonic (4.0) speaker setup.

    • User Interface:
      - Added "Start with Windows" option.
	  - Added bunch of icons in the UI.
      - Added developer website link.
      - Added link to original source code.
    
    • Show/Hide Desktop Icons:
      - As an added bonus I have added the ability to show/hide icons when you double-click on the desktop.
    
	[ChangeLog v1.03]
    • Changes & Addons
      - Changed Show/Hide from double-click to triple-click.
	  - Added donate link under about.
    )"
    
    aboutGui.Add("Text", "x20 y+10 w360", changelog) ; Left-aligned with margin
    ;-----ChangeLog-----
    
    aboutGui.Add("Text", "x10 y+10 w380 0x10") ; Horizontal line
    
    ; Links section with icons and "Here" links
    ; First link row
    aboutGui.Add("Picture", "x20 y+10 w16 h16", "Icons\DB.ico")
    aboutGui.Add("Text", "x+5 yp+3", "DB Updates: ")
    linkHere1 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere1.OnEvent("Click", (*) => Run(website))
    
    ; Second link row
    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\gh.ico")
    aboutGui.Add("Text", "x+5 yp+3", "Original Source: ")
    linkHere2 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere2.OnEvent("Click", (*) => Run(github))
    
    ; Third link row (SoundVolumeCommandLine)
    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\nirsoft.ico")
    aboutGui.Add("Text", "x+5 yp+3", "SoundVolumeCommandLine: ")
    linkHere3 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere3.OnEvent("Click", (*) => Run("https://www.nirsoft.net/utils/sound_volume_command_line.html"))
    
    ; Fourth link row (SoundVolumeView)
    aboutGui.Add("Picture", "x20 y+5 w16 h16", "Icons\nirsoft.ico")
    aboutGui.Add("Text", "x+5 yp+3", "SoundVolumeView: ")
    linkHere4 := aboutGui.Add("Text", "x+0 yp c0099FF", "Here")
    linkHere4.OnEvent("Click", (*) => Run("https://www.nirsoft.net/utils/sound_volume_view.html"))
    
    aboutGui.Add("Text", "x10 y+10 w380 0x10") ; Horizontal line
    
    ; Close button
    btnClose := aboutGui.Add("Button", "x150 y+10 w100 h30", "Close")
    btnClose.OnEvent("Click", (*) => aboutGui.Destroy())
    
    aboutGui.Show("AutoSize")
}

/*----------------
Show/Hide Function
----------------*/

; Global Variables
	global desktopIconsVisible := true
	global tripleClickEnabled := false  ; Changed from doubleClickEnabled to tripleClickEnabled
	global configFile := "SpatialAudioSwitcher.ini"

; Load saved state from INI file
	if FileExist(configFile) {
		tripleClickEnabled := IniRead(configFile, "DesktopIcons", "TripleClickEnabled", "0")  ; Changed key name
		tripleClickEnabled := (tripleClickEnabled = "1")
	}

; Desktop Icons Toggle
	ToggleDesktopIcons(*) {
		global tripleClickEnabled, configFile
		tripleClickEnabled := !tripleClickEnabled
		; Save state to INI file
		IniWrite(tripleClickEnabled ? "1" : "0", configFile, "DesktopIcons", "TripleClickEnabled")  ; Changed key name
		UpdateDesktopIconsMenu()
	}

; Update menu checkmark
	UpdateDesktopIconsMenu() {
		global tripleClickEnabled
		if (tripleClickEnabled) {
			Tray.Check("Shows/Hide Desktop Icons Triple-Click")  ; Updated text
		} else {
			Tray.Uncheck("Shows/Hide Desktop Icons Triple-Click")  ; Updated text
		}
	}

; Triple-click hotkey
	#HotIf WinActive("ahk_class Progman") && tripleClickEnabled
	~LButton::
	{
		static clickCount := 0
		static lastClickTime := 0
    
		currentTime := A_TickCount
		timeSinceLastClick := currentTime - lastClickTime
    
		if (timeSinceLastClick > 400) {  ; Reset if too much time between clicks
			clickCount := 1
		} else {
			clickCount += 1
		}
    
		lastClickTime := currentTime
    
		if (clickCount = 3) {  ; Triple-click detected
			clickCount := 0  ; Reset counter
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

/*----------------
Menu
----------------*/

Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"`"", , "Hide"
Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x3 0x3 0x3", , "Hide"
Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 44100", , "Hide"
Run "Resources\svcl.exe /SetAllowExclusive `"DefaultRenderDevice`" 0", , "Hide"


; delete AutoHotkey's default tray items.
	Tray := A_TrayMenu
	TraySetIcon "Icons\icon.ico"
	Tray.Delete

; formats, it will open with a left click to the tray icon.
	SpatialMenu := Menu()

; Tooltip text, which is displayed when the mouse hovers over the tray icon.
	A_IconTip := "Spatial Audio Switcher"

; Create submenus.

	; Create sub-menu Spatial Audio
		Select := Menu()
		
	; Create sub-menu Audio Settings
		Settings := Menu()
		
	; Create sub-menu Speaker Configuration
		Configuration := Menu()
		
	; Create sub-menu Default Format
		DefaultFormat := Menu()
		
	; Create sub-menu Exclusivity
		Exclusivity := Menu()

	; Create sub-menu Spatial Audio Apps Tray Menu
		SpatialApps := Menu()	

/*----------------
Define functions.
----------------*/

	; Empty Function.
		Empty(*)
		{
		}

	; Call the simple tray menu.
		Spatial(*)
		{
			SpatialMenu.Show
		}

	; Disable spatial audio.
		Disable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"`"", , "Hide"
			TraySetIcon "Icons\icon.ico"
			Tray.Rename "1&", "Disabled"
			Tray.SetIcon "Disabled", ""
			Tray.Add "Disabled", Empty
			Tray.Disable "&Disable Spatial Audio"
			SpatialMenu.Disable "&Disable Spatial Audio"
		}
	
	; Enable Dolby Atmos for Headphones.
		DolbyAtmosEnable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"Dolby Atmos`"", , "Hide"
			TraySetIcon "Icons\dolby.ico"
			Tray.Enable "&Disable Spatial Audio"
			SpatialMenu.Enable "&Disable Spatial Audio"
			Tray.Enable "1&"
			Tray.Rename "1&", "Dolby Atm&os for Headphones"
			Tray.SetIcon "Dolby Atm&os for Headphones", "Icons\dolby.ico"
			Tray.Add "Dolby Atm&os for Headphones", DolbyAccess
		}
		
	; Run Dolby Access.
		DolbyAccess(*)
		{
			Run "explorer.exe shell:appsFolder\DolbyLaboratories.DolbyAccess_rz1tebttyb220!App"
		}

	; Enable Dolby Atmos for Home Theater
		DolbyAtmosHTEnable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"Dolby Atmos for home theater`"", , "Hide"
			TraySetIcon "Icons\dolby.ico"  ; You'll need to create/add this icon
			Tray.Enable "&Disable Spatial Audio"
			SpatialMenu.Enable "&Disable Spatial Audio"
			Tray.Enable "1&"
			Tray.Rename "1&", "Dolby Atm&os for Home Theater"
			Tray.SetIcon "Dolby Atm&os for Home Theater", "Icons\dolby.ico"
			Tray.Add "Dolby Atm&os for Home Theater", DolbyAccess
		}

	; Enable DTS Headphone:X.
		DTSEnable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"DTS`"", , "Hide"
			TraySetIcon "Icons\dts.ico"
			Tray.Enable "&Disable Spatial Audio"
			SpatialMenu.Enable "&Disable Spatial Audio"
			Tray.Enable "1&"
			Tray.Rename "1&", "DTS Headphone:&X"
			Tray.SetIcon "DTS Headphone:&X", "Icons\dts.ico"
			Tray.Add "DTS Headphone:&X", DTSSoundUnbound
		}

	; Run DTS Sound Unbound.
		DTSSoundUnbound(*)
		{
			Run "explorer.exe shell:appsFolder\DTSInc.DTSSoundUnbound_t5j2fzbtdg37r!App"
		}

	; Enable DTS:X for Home Theater
		DTSXHTEnable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"DTS:X for home theater`"", , "Hide"
			TraySetIcon "Icons\dts.ico"  ; You'll need to create/add this icon
			Tray.Enable "&Disable Spatial Audio"
			SpatialMenu.Enable "&Disable Spatial Audio"
			Tray.Enable "1&"
			Tray.Rename "1&", "DTS:&X for Home Theater"
			Tray.SetIcon "DTS:&X for Home Theater", "Icons\dts.ico"
			Tray.Add "DTS:&X for Home Theater", DTSSoundUnbound
		}
	
	; Enable Windows Sonic for Headphones.
		SonicEnable(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"{b53d940c-b846-4831-9f76-d102b9b725a0}`"", , "Hide"
			TraySetIcon "Icons\sonic.ico"
			Tray.Enable "&Disable Spatial Audio"
			SpatialMenu.Enable "&Disable Spatial Audio"
			Tray.Enable "1&"
			Tray.Rename "1&", "Windows Sonic for Headphones"
			Tray.SetIcon "Windows Sonic for Headphones", "Icons\sonic.ico"
			Tray.Add "Windows Sonic for Headphones", Empty
		}
		
	; Run SoundVolumeView, our advanced sound device manager.
		Advanced(*)
		{
			Run "Resources\SoundVolumeView.exe"
		}
		
	; Open Windows Sound Settings.
		Modern(*)
		{
			Run "ms-settings:sound"
		}

	; Open Windows Traditional Sound Settings.
		Traditional(*)
		{
			Run "control mmsys.cpl sounds"
		}
	
	; Open Windows Application Volume Mixer.		
		Volume(*)
		{
			Run "ms-settings:apps-volume"
		}
		
	; Allow applications to take exclusive control of the default device.
		Exclusive(*)
		{
			Run "Resources\svcl.exe /SetAllowExclusive `"DefaultRenderDevice`" 1", , "Hide"
			Exclusivity.Check "&Exclusive"
			Exclusivity.Uncheck "&Not Exclusive"
		}
		
	; Do not allow applications to take exclusive control of default device.
		NonExclusive(*)
		{
			Run "Resources\svcl.exe /SetAllowExclusive `"DefaultRenderDevice`" 0", , "Hide"
			Exclusivity.Uncheck "&Exclusive"
			Exclusivity.Check "&Not Exclusive"
		}

	; Default Stereo: FL | FR = 0x3
		Stereo(*)
		{
			Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x3 0x3 0x3", , "Hide"
			Configuration.Check "&Stereo"
			Configuration.Uncheck "&Quadraphonic"
			Configuration.Uncheck "&5.1"
			Configuration.Uncheck "&7.1"
		}
		
	; Set to Quadraphonic: FL | FR | RL | RR = 0x33
		Quadraphonic(*)
		{
			Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x33 0x33 0x33", , "Hide"
			Configuration.Uncheck "&Stereo"
			Configuration.Check "&Quadraphonic"
			Configuration.Uncheck "&5.1"
			Configuration.Uncheck "&7.1"
		}

	; Set to 5.1: FL | FC | FR | SL | SR | Sub = 0x3f
		FivePointOne(*)
		{
			Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x3f 0x3f 0x3f", , "Hide"
			Configuration.Uncheck "&Stereo"
			Configuration.Uncheck "&Quadraphonic"
			Configuration.Check "&5.1"
			Configuration.Uncheck "&7.1"
		}
	
	; Set to 7.1: FL | FC | FR | SL | SR | RL | RR | Sub = 0x63f
		SevenPointOne(*)
		{
			Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x63f 0x63f 0x63f", , "Hide"
			Configuration.Uncheck "&Stereo"
			Configuration.Uncheck "&Quadraphonic"
			Configuration.Uncheck "&5.1"
			Configuration.Check "&7.1"
		}

	; Default to 16 bit, 44100 Hz.
		df1644(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 44100", , "Hide"
			DefaultFormat.Check "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 16 bit, 48000 Hz.
		df1648(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 48000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Check "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 16 bit, 96000 Hz.
		df1696(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 96000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Check "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 16 bit, 192000 Hz.
		df16192(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 192000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Check "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 24 bit, 44100 Hz.
		df2444(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 24 44100", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Check "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
	
	; Default to 24 bit, 48000 Hz.
		df2448(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 24 48000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Check "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 24 bit, 96000 Hz.
		df2496(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 24 96000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Check "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"
		}
		
	; Default to 24 bit, 192000 Hz.
		df24192(*)
		{
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 24 192000", , "Hide"
			DefaultFormat.Uncheck "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Check "24 Bit, 192000 Hz"
		}

	; Startup Checker
		startupEnabled := false
		if (FileExist(A_Startup "\Spatial Audio Switcher.lnk")) {
		    startupEnabled := true
		}

	; Function to create/remove startup shortcut
		ToggleStartup(*) {
		    global startupEnabled
		    if (startupEnabled) {
		        FileDelete A_Startup "\Spatial Audio Switcher.lnk"
		        startupEnabled := false
		    } else {
		        FileCreateShortcut A_ScriptFullPath, A_Startup "\Spatial Audio Switcher.lnk"
		        startupEnabled := true
		    }
		    UpdateStartupMenu()
		}

	; Function to update menu checkmark
		UpdateStartupMenu() {
		    global startupEnabled
		    if (startupEnabled) {
		        Tray.Check("Start with &Windows")
		    } else {
		        Tray.Uncheck("Start with &Windows")
		    }
		}

	; Reload Spatial Audio Switcher (Loads to default settings.
		Restart(*)
		{
			Reload
		}
		
	; Exit Spatial Audio Switcher.
		Exit(*)
		{
			Run "Resources\svcl.exe /SetSpatial `"DefaultRenderDevice`" `"`"", , "Hide"
			Run "Resources\svcl.exe /SetSpeakersConfig `"DefaultRenderDevice`" 0x3 0x3 0x3", , "Hide"
			Run "Resources\svcl.exe /SetDefaultFormat `"DefaultRenderDevice`" 16 44100", , "Hide"
			Run "Resources\svcl.exe /SetAllowExclusive `"DefaultRenderDevice`" 0", , "Hide"
			Sleep 0
			ExitApp
		}

/*----------------
Populate Menus
----------------*/

	; Open tray menu with right-click on the tray icon.
	
		; Show current state of spatial audio and change accordingly.
			Tray.Add "Disabled", Empty

		; Option to disable spatial audio. Shall be greyed-out
			Tray.Add "&Disable Spatial Audio", Disable
			Tray.SetIcon "&Disable Spatial Audio", "Icons\disable.ico"
			Tray.Disable "&Disable Spatial Audio"

		; Seperator.
			Tray.Add
		
		; Select submenu.
			Tray.Add "&Spatial Audio", Select
			Tray.SetIcon "&Spatial Audio", "Icons\spatial-audio.ico"
			Select.Add "Dolby Atm&os for Headphones", DolbyAtmosEnable
			Select.SetIcon "Dolby Atm&os for Headphones", "Icons\dolby.ico"
			Select.Add "Dolby Atmos for Home Theater", DolbyAtmosHTEnable
			Select.SetIcon "Dolby Atmos for Home Theater", "Icons\dolby.ico"
			Select.Add "DTS Headphone:&X", DTSEnable
			Select.SetIcon "DTS Headphone:&X", "Icons\dts.ico"
			Select.Add "DTS:X for Home Theater", DTSXHTEnable
			Select.SetIcon "DTS:X for Home Theater", "Icons\dts.ico"
			Select.Add "Windows &Sonic for Headphones", SonicEnable
			Select.SetIcon "Windows &Sonic for Headphones", "Icons\sonic.ico"

		; Settings submenu.
			Tray.Add "&Audio Settings", Settings
			Tray.SetIcon "&Audio Settings", "Icons\audio-settings.ico"	
			Settings.Add "&Advanced", Advanced
			Settings.SetIcon "&Advanced", "Icons\as-svv.ico"
			Settings.Add "&Modern", Modern
			Settings.SetIcon "&Modern", "Icons\as-set.ico"
			Settings.Add "&Traditional", Traditional
			Settings.SetIcon "&Traditional", "Icons\as-spe.ico"

        ; Configuration submenu.
			Tray.Add "Speaker &Configuration", Configuration
			Tray.SetIcon "Speaker &Configuration", "Icons\speaker-configuration.ico"
			Configuration.Add "&Stereo", Stereo
			Configuration.SetIcon "&Stereo", "Icons\sc-s.ico"
			Configuration.Add "&Quadraphonic", Quadraphonic
			Configuration.SetIcon "&Quadraphonic", "Icons\sc-q.ico"
			Configuration.Add "&5.1", FivePointOne
			Configuration.SetIcon "&5.1", "Icons\sc-5.1.ico"
			Configuration.Add "&7.1", SevenPointOne
			Configuration.SetIcon "&7.1", "Icons\sc-7.1.ico"

		; Default Format submenu.
			Tray.Add "Default &Format", DefaultFormat
			Tray.SetIcon "Default &Format", "Icons\default-format.ico"
			DefaultFormat.Add "16 Bit, 44100 Hz", df1644
			DefaultFormat.SetIcon "16 Bit, 44100 Hz", "Icons\df.ico"
			DefaultFormat.Add "16 Bit, 48000 Hz", df1648
			DefaultFormat.SetIcon "16 Bit, 48000 Hz", "Icons\df.ico"
			DefaultFormat.Add "16 Bit, 96000 Hz", df1696
			DefaultFormat.SetIcon "16 Bit, 96000 Hz", "Icons\df.ico"
			DefaultFormat.Add "16 Bit, 192000 Hz", df16192
			DefaultFormat.SetIcon "16 Bit, 192000 Hz", "Icons\df.ico"
			DefaultFormat.Add "24 Bit, 44100 Hz", df2444
			DefaultFormat.SetIcon "24 Bit, 44100 Hz", "Icons\df.ico"
			DefaultFormat.Add "24 Bit, 48000 Hz", df2448
			DefaultFormat.SetIcon "24 Bit, 48000 Hz", "Icons\df.ico"
			DefaultFormat.Add "24 Bit, 96000 Hz", df2496
			DefaultFormat.SetIcon "24 Bit, 96000 Hz", "Icons\df.ico"
			DefaultFormat.Add "24 Bit, 192000 Hz", df24192
			DefaultFormat.SetIcon "24 Bit, 192000 Hz", "Icons\df.ico"

		; Exclusivity submenu
			Tray.Add "&Exclusivity", Exclusivity
			Tray.SetIcon "&Exclusivity", "Icons\exclusivity.ico"
			Exclusivity.Add "&Exclusive", Exclusive
			Exclusivity.SetIcon "&Exclusive", "Icons\exclusivity.ico"
			Exclusivity.Add "&Not Exclusive", NonExclusive
			Exclusivity.SetIcon "&Not Exclusive", "Icons\exclusivity.ico"

		; Application Volume Mixer.
			Tray.Add "&Volume Mixer", Volume
			Tray.SetIcon "&Volume Mixer", "Icons\volume-mixer.ico"
		
		; Seperator.
			Tray.Add
			
		; Toggle Show/Hide Desktop Icons
			Tray.Add("Shows/Hide Desktop Icons Triple-Click", ToggleDesktopIcons)  ; Updated text
			Tray.SetIcon "Shows/Hide Desktop Icons Triple-Click", "Icons\showhide.ico"
			UpdateDesktopIconsMenu()  ; Set initial state

		; Seperator.
			Tray.Add

		; Add Startup Toggle To The Menu
			Tray.Add("Start with &Windows", ToggleStartup)
			Tray.SetIcon "Start with &Windows", "Icons\startup.ico"
			if (startupEnabled) {
				Tray.Check("Start with &Windows")
			}
		
			; Update The Startup Menu Item Initially
				UpdateStartupMenu()		

		; Reload Spatial Audio Switcher (Reset all settings to their default)
			Tray.Add "&Reload", Restart
			Tray.SetIcon "&Reload", "Icons\reload.ico"
		
		; Quit Spatial Audio Switcher (Reset all settings to their default)
			Tray.Add "E&xit", Exit
			Tray.SetIcon "E&xit", "Icons\exit.ico"

		; About Menu
			Tray.Add("About", ShowAbout)
			Tray.SetIcon "About", "Icons\about.ico"

		; Donate Link
			Tray.Add("Donate", (*) => Run("https://www.paypal.com/donate?hosted_button_id=ZJGYBNSCSDFBG"))
			Tray.SetIcon "Donate", "Icons\donate.ico"

	; Simple tray menu. (Open with a left click on the tray icon)
		
		; Option to disable spatial audio. Shall be greyed-out
			SpatialMenu.Add "&Disable Spatial Audio", Disable
			SpatialMenu.SetIcon "&Disable Spatial Audio", "Icons\disable.ico"
			SpatialMenu.Disable "&Disable Spatial Audio"
	
		; Seperator.
			SpatialMenu.Add
		
		; Selection between the spatial audio formats.
			SpatialMenu.Add "Dolby Atm&os for Headphones", DolbyAtmosEnable
			SpatialMenu.SetIcon "Dolby Atm&os for Headphones", "Icons\dolby.ico"
			SpatialMenu.Add "Dolby Atmos for Home Theater", DolbyAtmosHTEnable
			SpatialMenu.SetIcon "Dolby Atmos for Home Theater", "Icons\dolby.ico"
			SpatialMenu.Add "DTS Headphone:&X", DTSEnable
			SpatialMenu.SetIcon "DTS Headphone:&X", "Icons\dts.ico"
			SpatialMenu.Add "DTS:X for Home Theater", DTSXHTEnable
			SpatialMenu.SetIcon "DTS:X for Home Theater", "Icons\dts.ico"
			SpatialMenu.Add "Windows &Sonic for Headphones", SonicEnable
			SpatialMenu.SetIcon "Windows &Sonic for Headphones", "Icons\sonic.ico"

		; Seperator
			SpatialMenu.Add
		
		; Speaker configuration.
			SpatialMenu.Add "Speaker &Configuration", Configuration
			SpatialMenu.SetIcon "Speaker &Configuration", "Icons\speaker-configuration.ico"
		
		; Shortcuts to spatial audio applications.
			SpatialMenu.Add "&Applications", SpatialApps
			SpatialMenu.SetIcon "&Applications", "Icons\spatial-audio.ico"
			
			
			SpatialApps.Add "&Dolby Access", DolbyAccess
			SpatialApps.SetIcon "&Dolby Access", "Icons\dolby.ico"
			SpatialApps.Add "DTS Sound &Unbound", DTSSoundUnbound
			SpatialApps.SetIcon "DTS Sound &Unbound", "Icons\dts.ico"

			SpatialMenu.Add "&Sound", Traditional
			SpatialMenu.SetIcon "&Sound", "Icons\as-spe.ico"

		; Make tray menu show default settings.
			Exclusivity.Uncheck "&Exclusive"
			Exclusivity.Check "&Not Exclusive"
			Configuration.Check "&Stereo"
			Configuration.Uncheck "&Quadraphonic"
			Configuration.Uncheck "&5.1"
			Configuration.Uncheck "&7.1"
			DefaultFormat.Check "16 Bit, 44100 Hz"
			DefaultFormat.Uncheck "16 Bit, 48000 Hz"
			DefaultFormat.Uncheck "16 Bit, 96000 Hz"
			DefaultFormat.Uncheck "16 Bit, 192000 Hz"
			DefaultFormat.Uncheck "24 Bit, 44100 Hz"
			DefaultFormat.Uncheck "24 Bit, 48000 Hz"
			DefaultFormat.Uncheck "24 Bit, 96000 Hz"
			DefaultFormat.Uncheck "24 Bit, 192000 Hz"

		; Make simple tray menu the default.
			Tray.Add
			Tray.Add "Spatial Audio Switcher", Spatial 
			Tray.Default := "Spatial Audio Switcher"
			Tray.Disable "Spatial Audio Switcher"
			Tray.ClickCount := 1

		; Windows + Alt + S shortcut can be used to open
			#!s::SpatialMenu.Show
		;
; END
;

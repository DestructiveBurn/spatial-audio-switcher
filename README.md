# Spatial Audio Switcher

<div align="center">
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-2.webp" alt="Spatial Audio Switcher Logo" width="150px" height="150px">
</div>

**Project Maintainer**: [DestructiveBurn](http://destructiveburn.com/destructiveburn)  
**Tools Used**: [Nirsoft SoundVolumeCommandLine](https://www.nirsoft.net/utils/sound_volume_command_line.html) & [Nirsoft SoundVolumeView](https://www.nirsoft.net/utils/sound_volume_view.html)  
**Donate**: If you wish to support the work I've done, you can do so here: [Paypal](https://www.paypal.com/donate?hosted_button_id=ZJGYBNSCSDFBG)  
**DB Main Site Source**: [Spatial Audio Switcher](https://destructiveburn.com/spatial-audio-switcher/)  
**Contact DB**: [DB Chat](https://destructiveburn.com/chat/)  

<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-1.webp" alt="Spatial Audio Switcher Logo" width="auto" height="400px">
</div>

## ℹ️ What is Spatial Audio Switcher?
Spatial Audio Switcher is a lightweight Windows tray utility that lets you quickly switch spatial audio modes such as Dolby Atmos, DTS, Windows Sonic, and other audio configurations. It also provides quick access to speaker configuration, default audio format, exclusivity settings, audio presets, and Windows sound tools.

It runs from the system tray and allows you to change default audio device settings, save and load presets, open Windows sound panels, manage exclusive mode, and quickly toggle supported spatial audio options without digging through Windows settings. Designed with AutoHotkey v2.0, it uses third-party NirSoft tools such as SoundVolumeCommandLine to apply audio changes through command-line functions and SoundVolumeView to provide advanced viewing and management of Windows sound devices.

## ✨ Features

### 🎧 Spatial Audio
- Dolby Atmos for Headphones
- Dolby Atmos for Home Theatre
- DTS Headphone:X
- DTS:X for Home Theatre
- Windows Sonic for Headphones
- 
### 🖥️ Playback Device Switcher
- Opens Windows Sound Panel.
It’s the same as Sound but less confusing to some.

### ⚙️ Audio Settings
- **Advanced**: Opens SoundVolumeView by NirSoft
- **Modern**: Opens System Sound settings
- **Traditional**: Opens classic Sound Window

### 🔊 Speaker Configuration
- **Stereo**: FL | FR
- **Quadraphonic**: FL | FR | RL | RR
- **5.1 Surround**: FL | FC | FR | SL | SR | Sub
- **7.1 Surround**: FL | FC | FR | SL | SR | RL | RR | Sub

*Note: Quickly change your sound configuration if your system supports surround sound.*

### 📊 Default Format (Sample Rate)
| Bit Depth | Sample Rates       |
|-----------|--------------------|
| 16 Bit    | 44100 Hz, 48000 Hz, 96000 Hz, 192000 Hz |
| 24 Bit    | 44100 Hz, 48000 Hz, 96000 Hz, 192000 Hz |

### 🎛️ Exclusivity
- **Exclusive**: Allows applications to take exclusive control
- **Not Exclusive**: Prevents exclusive control

*Note: Some audio applications request exclusive mode for higher quality playback, but this prevents other apps from playing sounds simultaneously.*

### 💾 Presets
- Allows you to set up and save your own custom sound settings.
- Sound settings can easily be switched by keyboard shortcuts by pressing Ctrl + Alt +1 to 5.
- You can enable default switching on startup to your favourite preset.
- Preset names can be customized.

### 🔊 Volume Control
- You can Mute/Unmute
- Change the volume to the fixed options.
- Open Windows Volume Mixer

### 🖥️ Show/Hide Taskbar Auto-Hide
- Quickly show/hide your desktop’s taskbar.
- Can be easily switched by keyboard shortcuts by pressing Win + Alt +T

### 🖥️ Show/Hide Desktop Icons
Triple-click on the desktop to toggle icon visibility.

### 🚀 Start With Windows
Adds a shortcut to:  
`C:\Users\USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

### 🔄 Other Functions
- **Reload**: Reset all settings to default
- **Exit**: Close the application
- **About**: Version information and changelog
- **Shortcuts**: Displays key combinations to quickly open, adjust or apply.

### 🪟 Preview
- You can open this menu by left-clicking on the tray icon or using the Windows + Alt + S shortcut.
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-3.webp" alt="Spatial Audio Switcher Logo" width="350px" height="auto">
</div>

- This one is opened by right-clicking on the tray icon.
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-4.webp" alt="Spatial Audio Switcher Logo" width="350px" height="auto">
</div>

## 📥 Installation
1. Download the Spatial Audio Switcher zip
2. Extract the Spatial Audio Switcher folder from the zip
3. Download SoundVolumeCommandLine & SoundVolumeView
4. Both SoundVolumeCommandLine & SoundVolumeView files go into the Resources directory. (SoundVolumeView.exe & svcl.exe)
5. Place the folder in a permanent location (portable tool)
6. Click on Spatial Audio Switcher.exe
7. Check the taskbar tray location for the icon.

## 🛠️ Requirements
- AutoHotkey v2.0+
- Windows 10/11
- [Nirsoft SoundVolumeCommandLine](https://www.nirsoft.net/utils/sound_volume_command_line.html)
- [Nirsoft SoundVolumeView](https://www.nirsoft.net/utils/sound_volume_view.html)


## 🎨 Icon Credits
All icons used in this project are attributed to their respective creators:

| Feature            | Icon Source |
|--------------------|-------------|
| about.ico					| [Flaticon - Flaticon – About](https://www.flaticon.com/free-icon/about_9967632) |
| as-set.ico				| [Flaticon - Flaticon – Gear](https://www.flaticon.com/free-icon/gear_1790071) |
| as-svv.ico				| [Flaticon - Flaticon – Sound Volume View](https://www.nirsoft.net/utils/sound_volume_view.html) |
| audio-settings.ico		| [Flaticon - Flaticon – Settings](https://www.flaticon.com/free-icon/settings_9215341) |
| default-format.ico		| [Flaticon - Flaticon – Music Wave](https://www.flaticon.com/free-icon/music-wave_4020749) |
| df.ico					| [Flaticon - Flaticon – Music Wave](https://www.flaticon.com/free-icon/music-wave_4020749) |
| disable.ico				| [Flaticon - Flaticon – Power Button](https://www.flaticon.com/free-icon/power-button_3292455) |
| donate.ico				| [Flaticon - Flaticon – PayPal Logo](https://www.flaticon.com/free-icon/logo_11378189) |
| exclusivity.ico			| [Flaticon - Flaticon – Song](https://www.flaticon.com/free-icon/song_1540646) |
| exit.ico					| [Flaticon - Flaticon – Cancel](https://www.flaticon.com/free-icon/cancel_16799002) |
| gh.ico					| [Flaticon - Flaticon – GitHub](https://www.flaticon.com/free-icon/github_270798) |
| output-device.ico			| [Flaticon - Flaticon – Switches](https://www.flaticon.com/free-icon/switches_8423240) |
| reload.ico				| [Flaticon - Flaticon – Refresh](https://www.flaticon.com/free-icon/refresh_1082454) |
| shortcuts.ico				| [Flaticon - Flaticon – Electric Keyboard](https://www.flaticon.com/free-icon/electric-keyboard_6328553) |
| showhide.ico				| [Flaticon - Flaticon – LCD](https://www.flaticon.com/free-icon/lcd_9753891) |
| spatial-audio.ico			| [Flaticon - Flaticon – Audio Waves](https://www.flaticon.com/free-icon/audio-waves_5580131) |
| speaker-configuration.ico	| [Flaticon - laticon – Surround Sound](https://www.flaticon.com/free-icon/surround-sound_15091931) |
| startup.ico				| [Flaticon - Flaticon – Startup](https://www.flaticon.com/free-icon/startup_9119213) |
| taskbar.ico				| [Flaticon - Flaticon – Window](https://www.flaticon.com/free-icon/window_16782200) |
| volume-mixer.ico			| [Flaticon - Flaticon – Setting](https://www.flaticon.com/free-icon/setting_9215358) |

## ℹ️ About GUI
On all versions from v1.02, there will be a Changelog in that version of the Spatial Audio Switcher.exe. To see the main changelog, scroll down this page to see the full extent of the updates done below.  On the Spatial Audio Switcher, click on "About" to see the current changelog of that version and "Shortcuts" to see the main shortcuts you can add.
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-5.webp" alt="Spatial Audio Switcher Logo" width="auto" height="400px">
</div>


## 🔒 VirusTotal Verification (False Positives)
<details>
<summary><strong>⚠️ Important Security Note</strong></summary>

When compiling the AHK script to EXE, some antivirus engines may flag the output due to:

1. The nature of AutoHotkey's compiler (used by both legitimate and malicious software)
2. The program's ability to modify system audio settings
3. Common false positives with script-based utilities

**Key Points:**
- Windows Defender typically doesn't flag the compiled EXE
- Detection varies based on the compiled filename and compiler version
- You can verify safety by:
  - Reviewing the source code.
  - Compiling it yourself with [AutoHotkey v2+](https://www.autohotkey.com/)
  - Scanning with your preferred antivirus

I guarantee the code is clean - I wouldn't invest time improving unsafe software. These false positives are an unfortunate reality of script-based tools.
</details>

## VirusTotal

I've been working with the Spatial Audio Switcher.ahk, and when I compile it to an .exe using AutoHotKey Dash, I've noticed that some antivirus programs are incorrectly flagging the executables. While I haven't seen this issue with Windows Defender, there are definitely some false positives on VirusTotal. Changing the name during compilation alters the results on that site. I can assure you the code is clean. If you're curious, you can download AutoHotKey Dash and compile the Spatial Audio Switcher.ahk yourself to check what VirusTotal says.

I suspect that since this is a script-based tool builder, some users may have employed it for unusual purposes. Who knows? If it weren't safe, I wouldn't be dedicating my time to modding this application.



## ℹ️ Can't run or blocked from running?
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher-v1.08/Spatial-Audio-Switcher-v1.08-6.webp" alt="Spatial Audio Switcher Logo" width="auto" height="400px">
</div>

If you cannot launch Spatial Audio Switcher or the application will not start with Windows, the problem is most likely "Smart App Control" blocking it from running.
The reason is that AutoHotkey scripts or custom executables aren't signed with a trusted digital certificate; SAC marks them as "untrusted from the internet" and silently prevents them from executing automatically at boot, or throws that pop-up when triggered manually.

**How to fix**
1. Right-click "Spatial Audio Switcher.exe" and go to "Properties".
2. On the General Tab at the bottom, you'll see "Security". Check Unblock.
After that, the problem will be resolved. It might be possible that it will happen on all versions after this, so keep note of it. To double-check if the startup shortcut works again, you can go here:

**Startup Apps**
1. Press: Win + R and then type in: shell:startup
Or navigate to: C:\Users\YOUR USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
2. Click on Spatial Audio Switcher. If it launches, then it will start with Windows again. If you see Smart App Control again, be sure you unchecked the "Security" on the Spatial Audio Switcher.exe



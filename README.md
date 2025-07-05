
# Spatial Audio Switcher

<div align="center">
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher/logo.png" alt="Spatial Audio Switcher Logo" width="150px" height="150px">
</div>

A simple taskbar tray application created with AutoHotkey v2.0+ provides quick access to various audio settings.

**Original Author**: Tremontaine  
**Modified by**: [DestructiveBurn](http://destructiveburn.com/destructiveburn)  
**Tools Used**: [Nirsoft SoundVolumeCommandLine](https://www.nirsoft.net/utils/sound_volume_command_line.html) & [Nirsoft SoundVolumeView](https://www.nirsoft.net/utils/sound_volume_view.html)  
**Donate**: If you wish to support the work I've done, you can do so here: [Paypal](https://www.paypal.com/donate?hosted_button_id=ZJGYBNSCSDFBG)

## ✨ Features

### 🎧 Spatial Audio
- Dolby Atmos for Headphones
- Dolby Atmos for Home Theater
- DTS Headphone:X
- DTS:X for Home Theater
- Windows Sonic for Headphones

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

### 🔒 Exclusivity
- **Exclusive**: Allows applications to take exclusive control
- **Not Exclusive**: Prevents exclusive control

*Note: Some audio applications request exclusive mode for higher quality playback, but this prevents other apps from playing sounds simultaneously.*

### 🎚️ Volume Mixer
Quickly adjust individual application volumes.

### 🖥️ Show/Hide Desktop Icons
Double-click on the desktop to toggle icon visibility.

### 🚀 Start With Windows
Adds a shortcut to:  
`C:\Users\USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

### 🔄 Other Functions
- **Reload**: Reset all settings to default
- **Exit**: Close the application
- **About**: Version information and changelog

### 🖼️ Preview
- You can open this menu by left-clicking on the tray icon or using this shortcut Windows + Alt + S shortcut.
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher/1.png" alt="Spatial Audio Switcher Logo" width="350px" height="auto">
</div>

- This one is opened by right-clicking on the tray icon.
<div>
  <img src="https://destructiveburn.com/images/GitHub/Spatial-Audio-Switcher/2.png" alt="Spatial Audio Switcher Logo" width="350px" height="auto">
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
| Spatial Audio      | [Flaticon - Waves](https://www.flaticon.com/free-icon/waves_13123770) |
| Audio Settings     | [Flaticon - Settings](https://www.flaticon.com/free-icon/settings_9215341) |
| Speaker Config     | [Flaticon - Surround Sound](https://www.flaticon.com/free-icon/surround-sound_15091931) |
| Default Format     | [Flaticon - Music Wave](https://www.flaticon.com/free-icon/music-wave_4020749) |
| Exclusivity        | [Flaticon - Song](https://www.flaticon.com/free-icon/song_1540646) |
| Volume Mixer       | [Flaticon - Setting](https://www.flaticon.com/free-icon/setting_9215358) |
| GitHub             | [Flaticon - GitHub](https://www.flaticon.com/free-icon/github_733553) |
| Power              | [Flaticon - Power Button](https://www.flaticon.com/free-icon/power-button_3292455) |
| Monitor            | [Flaticon - LCD](https://www.flaticon.com/free-icon/lcd_9753891) |


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

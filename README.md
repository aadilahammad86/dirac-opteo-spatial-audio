# Dirac Opteo Acoustic EQ & 3D Spatial Audio Engine

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-blue.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Audio Engine](https://img.shields.io/badge/Audio%20Engine-Equalizer%20APO%20%2B%20HeSuVi-brightgreen.svg)](#)

An all-in-one system-wide audio DSP package that delivers **Dirac Opteo-style acoustic tuning** and **Binaural 3D Spatial Audio** (replacing Windows Sonic) to **any earphones or headphones** (wired 3.5mm, USB DAC, or Bluetooth) on **Windows** and **Linux**.

---

## 🎧 What This Does

* **Dirac Opteo 7-Band Parametric EQ:** Corrects earphone acoustic anomalies, adds controlled sub-bass punch (32 Hz), cleans lower-mid boxiness (280 Hz), brings vocals forward with pinna gain correction (3100 Hz), eliminates harsh sibilance (6200 Hz), and expands high-frequency air (11500 Hz).
* **3D Binaural Spatial Audio:** Uses 14-channel Head-Related Impulse Response (HRIR) convolution to simulate physical 3D surround soundstage directly inside your headphones.
* **Universal Compatibility:** Works with any earphones (wired 3.5mm, Type-C, Bluetooth) and across all PC sound (Spotify, YouTube, VLC, Netflix, and PC games).

---

## 📁 Repository Structure

```
dirac-opteo-spatial-audio/
│
├── install.bat                     <-- 1-Click All-in-One Installer (Right-click -> Run as Administrator)
├── Setup-DiracAudio.ps1            <-- PowerShell automated setup script
├── Uninstall-DiracAudio.ps1        <-- Clean uninstaller / restorer script
├── Enable-Startup.ps1              <-- Registers automatic silent startup on Windows logon
├── Disable-Startup.ps1             <-- Removes startup task/shortcut cleanly
├── Startup-Watcher.ps1             <-- Background startup verifier & HeSuVi tray launcher
├── Startup-Launcher.vbs            <-- Invisible launcher (no black console flash on login)
├── README.md                       <-- Documentation & setup guide
├── LICENSE                         <-- MIT License
│
├── installers/                     <-- Offline installation binaries
│   ├── EqualizerAPO-x64-1.4.2.exe  (Equalizer APO 64-bit engine)
│   └── HeSuVi_2.0.0.1.exe          (HeSuVi Spatial Audio virtualizer)
│
├── config/                         <-- Configuration profiles
│   ├── dirac_opteo.txt             (The 7-band Dirac Opteo EQ curve)
│   ├── dirac_spatial.wav           (48 kHz 3D Spatial HRIR convolution profile)
│   ├── dirac_spatial_44.wav        (44.1 kHz 3D Spatial HRIR convolution profile)
│   ├── config.txt                  (Master Equalizer APO config that links both)
│   └── dirac_opteo_easyeffects.json (Linux PipeWire EasyEffects preset)
│
└── linux/
    └── setup_linux.sh              (Bash script for EasyEffects deployment)
```

---

## 🚀 Windows Installation (1-Click)

1. Clone or download this repository.
2. Right-click **`install.bat`** and select **Run as Administrator**.
3. Follow the on-screen prompts:
   * If Equalizer APO is not installed, the installer will launch. Select your audio playback devices in the Configurator and restart your PC.
   * If HeSuVi is not installed, the installer will launch and extract the components.
   * The script automatically deploys the `dirac_opteo.txt` EQ curve, 48 kHz/44.1 kHz `dirac_spatial.wav` HRIR profiles, configures the master pipeline, and registers the **automatic Windows startup task**.
4. **Turn Windows Sonic OFF:**
   * Right-click the Speaker icon in your taskbar -> Sound settings.
   * Under your headphone properties, verify **Spatial audio** is set to **Off** (HeSuVi handles 7.1 virtualization directly in 64-bit floating point).

---

## ⚡ Windows Startup Integration

The package includes silent, flicker-free background startup integration:

* **Automatic Watcher:** On logon, `Startup-Watcher.ps1` runs invisibly via `Startup-Launcher.vbs` (0-millisecond window style, no flashing command prompt).
* **Self-Healing Pipeline:** If a Windows Update or audio driver reset overwrites Equalizer APO's `config.txt`, the watcher automatically restores the `dirac_opteo.txt` and `HeSuVi\hesuvi.txt` include directives.
* **HeSuVi Tray Access:** Launches HeSuVi minimized in the system tray so 7.1 surround controls and volume are instantly accessible.
* **Management Scripts:**
  * To enable anytime: Run `powershell -ExecutionPolicy Bypass -File .\Enable-Startup.ps1`
  * To disable anytime: Run `powershell -ExecutionPolicy Bypass -File .\Disable-Startup.ps1`

## 🐧 Linux Installation (PipeWire + EasyEffects)

1. Make the script executable and run:
   ```bash
   chmod +x linux/setup_linux.sh
   ./linux/setup_linux.sh
   ```
2. Open **EasyEffects**:
   * Navigate to **Presets** -> **Output** -> select **`dirac_opteo_easyeffects`** -> click **Load**.
   * In the **Convolver** plugin, select `dirac_spatial.wav` for 3D spatialization.

---

## 📊 Acoustic Specifications

| Band | Type | Frequency (Fc) | Gain | Q Factor | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Preamp** | Digital Gain | — | **-4.5 dB** | — | Digital headroom protection |
| **Band 1** | Peaking (PK) | **32 Hz** | **+4.5 dB** | 1.00 | Sub-bass tactile punch & rumble |
| **Band 2** | Low-Shelf (LSC) | **105 Hz** | **+3.0 dB** | 0.71 | Mid-bass warmth without mud |
| **Band 3** | Peaking (PK) | **280 Hz** | **-1.8 dB** | 1.20 | Removes boxy/muddy lower-mids |
| **Band 4** | Peaking (PK) | **1100 Hz** | **+1.0 dB** | 1.50 | Core vocal body & richness |
| **Band 5** | Peaking (PK) | **3100 Hz** | **+2.5 dB** | 1.40 | Presence & pinna gain correction |
| **Band 6** | Peaking (PK) | **6200 Hz** | **-2.2 dB** | 2.20 | Sibilance & harshness attenuation |
| **Band 7** | High-Shelf (HSC) | **11500 Hz** | **+3.2 dB** | 0.71 | High-frequency air & transparency |

---

## 📜 Credits & License

* Dirac Opteo acoustic profile tuning by [aadilahammad86](https://github.com/aadilahammad86).
* Built on [Equalizer APO](https://sourceforge.net/projects/equalizerapo/) by Jonas Thedering (GPL).
* Spatial Audio Virtualization via [HeSuVi](https://sourceforge.net/projects/hesuvi/) by Matt Greene.
* Licensed under the [MIT License](LICENSE).

# KDecoder for Mac

> A lightweight macOS menu bar app that fixes broken Korean file names caused by encoding issues.

---

## 📌 Overview

When transferring files between Windows and macOS, Korean file names can become garbled due to **Unicode normalization differences** (NFC vs NFD). **KDecoder** automatically decodes and normalizes these broken file names with a simple drag & drop.

---

## ✨ Features

- 🖱️ **Drag & Drop** — Drop files directly onto the app window to fix their names instantly
- 📂 **Manual File Selection** — Pick files manually using the built-in file picker
- 🖥️ **Menu Bar App** — Lives quietly in your menu bar, always ready when you need it
- 💾 **Save to Desktop** — Optionally save renamed files to the Desktop instead of in-place
- ⚡ **Batch Processing** — Handle multiple files at once
- 🔁 **Conflict Handling** — Automatically appends `_copy1`, `_copy2`, etc. when a file with the same name already exists
- 🔒 **Sandboxed & Privacy-Friendly** — Uses macOS security-scoped bookmarks for folder access

---

## 🚀 How to Use

### Basic Usage

1. **Launch KDecoder** — The app appears in your menu bar (top-right of screen)
2. **Click the menu bar icon** to open the app window
3. **Drag & drop** garbled-named files onto the drop zone
4. The file names are fixed automatically ✅

### Manual File Selection

- Click the **"직접 선택 (Select Files)"** button at the bottom of the window
- Choose the files you want to fix
- Done!

### Save to Desktop Option

- Toggle the **"바탕화면에 유지 (Save to Desktop)"** checkbox
- When enabled, fixed files are copied to your Desktop instead of being renamed in place

### First Launch (Folder Access)

On first launch, KDecoder will ask for permission to access your files. Grant access to the folder containing your files when prompted.

---

## 📸 Screenshots

<!-- Add screenshots here -->
<!-- Example:
![Main Window](screenshots/main.png)
![Drop Zone](screenshots/drop.png)
-->

> *Screenshots coming soon*

---

## 🛠️ Requirements

- macOS 26.0 or later
- Apple Silicon or Intel Mac

---

## 🏗️ Build from Source

```bash
git clone https://github.com/adgk2349/Korean_File_Name_Decoder_For_Mac.git
cd Korean_File_Name_Decoder_For_Mac
open KDecoder.xcodeproj
```

Then build and run in Xcode (⌘R).

---

## 💝 Support

If KDecoder has been helpful, consider supporting the project!

<!-- Add your donation/sponsor link below -->
<!-- 
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=flat&logo=buy-me-a-coffee&logoColor=black)](YOUR_LINK_HERE)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?style=flat&logo=github)](YOUR_LINK_HERE)
[![Toss](https://img.shields.io/badge/Toss-0064FF?style=flat&logo=toss&logoColor=white)](YOUR_LINK_HERE)
-->

> 💬 후원 링크를 위 주석 안에 추가해주세요!

---

## 📄 License

MIT License © 2026 [adgk2349](https://github.com/adgk2349)

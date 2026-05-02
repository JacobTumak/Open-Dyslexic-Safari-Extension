# OpenDyslexic for Safari

A Safari Web Extension for macOS that applies the [OpenDyslexic](https://github.com/antijingoist/opendyslexic) font to every webpage, making the web easier to read for people with dyslexia.

Toggle it on or off per site from the toolbar — font size, weight, and style are all preserved.

---

## Features

- Replaces all HTML text fonts with OpenDyslexic (bold, italic, and bold-italic variants included)
- Per-site toggle — remembers your preference for each domain
- Takes effect instantly, no page reload required
- Works offline — fonts are bundled with the extension, no external requests
- Includes a link to download OpenDyslexic for system-wide use in other apps
- Dark mode support in the popup

---

## Requirements

- macOS 11 (Big Sur) or later
- [Xcode](https://apps.apple.com/us/app/xcode/id497799835) (free, from the Mac App Store)
- A free Apple ID (no paid developer account needed)

---

## Installation

**1. Clone the repo**
```bash
git clone https://github.com/JacobTumak/OpenDyslexic.git
cd OpenDyslexic
```

**2. Run the setup script**

This downloads the OpenDyslexic fonts, generates the extension source tree, and creates the Xcode project.
```bash
bash setup.sh
```

**3. Open the Xcode project**
```bash
open OpenDyslexic/OpenDyslexic.xcodeproj
```

**4. Configure signing**

In Xcode, click the `.xcodeproj` in the sidebar, then for each target (**OpenDyslexic** and **OpenDyslexic Extension**):
- Select the **Signing & Capabilities** tab
- Set **Team** to your Apple ID
- Check **Automatically manage signing**

**5. Build and run**

Press **⌘R**. A small app window will appear with a button to open Safari's Extensions preferences.

**6. Enable in Safari**

Go to **Safari → Settings → Extensions** and check the box next to **OpenDyslexic**.

---

## Usage

Click the **OpenDyslexic icon** in the Safari toolbar on any webpage to open the popup. Use the toggle to turn the font on or off for that site. Your preference is saved automatically.

The **Download** button in the popup opens the OpenDyslexic releases page if you want to install the font system-wide for use in other apps.

---

## Project Structure

```
setup.sh                  # One-time scaffold script
extension/
  manifest.json           # Web Extension manifest (MV3)
  content.js              # Injects font CSS into every page
  background.js           # Service worker
  popup.html/css/js       # Toolbar popup UI
  fonts/                  # OpenDyslexic woff2 files (downloaded by setup.sh)
  images/                 # Toolbar icons
OpenDyslexic/             # Generated Xcode project (created by setup.sh)
```

> `extension/fonts/` and `OpenDyslexic/` are excluded from version control. Run `setup.sh` to regenerate them.

---

## Credits

- [OpenDyslexic](https://github.com/antijingoist/opendyslexic) font by Abbie Gonzalez — free and open source
- Built as a Safari Web Extension using Apple's `safari-web-extension-converter`

---

## License

The extension code in this repository is released under the [MIT License](LICENSE).
The OpenDyslexic font is licensed under the [SIL Open Font License](https://github.com/antijingoist/opendyslexic/blob/master/LICENSE.md) and is not included in this repository — it is downloaded at build time.

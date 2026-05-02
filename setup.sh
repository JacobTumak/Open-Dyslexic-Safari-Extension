#!/usr/bin/env bash
# setup.sh — Scaffold the OpenDyslexic Safari Web Extension project.
# Usage: bash setup.sh   (run once from the repo root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT="$SCRIPT_DIR/extension"
FONT_BASE="https://raw.githubusercontent.com/antijingoist/opendyslexic/main/compiled"

# ── Preflight ─────────────────────────────────────────────────────────────────
if ! command -v xcrun &>/dev/null; then
  echo "Error: xcrun not found. Install Xcode from the App Store first."
  exit 1
fi

echo "==> Creating extension source tree"
mkdir -p "$EXT/fonts" "$EXT/images"

# ── manifest.json ─────────────────────────────────────────────────────────────
cat > "$EXT/manifest.json" << 'EOF'
{
  "manifest_version": 3,
  "name": "OpenDyslexic",
  "version": "1.0",
  "description": "Apply the OpenDyslexic font to every webpage for easier reading.",
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "images/icon-16.png",
      "48": "images/icon-48.png",
      "128": "images/icon-128.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["content.js"],
      "run_at": "document_start"
    }
  ],
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["<all_urls>"],
  "icons": {
    "16": "images/icon-16.png",
    "48": "images/icon-48.png",
    "128": "images/icon-128.png"
  },
  "web_accessible_resources": [
    {
      "resources": ["fonts/*.woff2"],
      "matches": ["<all_urls>"]
    }
  ]
}
EOF

# ── content.js ────────────────────────────────────────────────────────────────
cat > "$EXT/content.js" << 'EOF'
(function () {
  'use strict';

  var STYLE_ID = 'opendyslexic-ext-style';

  function buildCSS() {
    var base = browser.runtime.getURL('fonts/');
    return [
      "@font-face {",
      "  font-family: 'OpenDyslexic';",
      "  src: url('" + base + "OpenDyslexic-Regular.woff2') format('woff2');",
      "  font-weight: normal; font-style: normal;",
      "}",
      "@font-face {",
      "  font-family: 'OpenDyslexic';",
      "  src: url('" + base + "OpenDyslexic-Bold.woff2') format('woff2');",
      "  font-weight: bold; font-style: normal;",
      "}",
      "@font-face {",
      "  font-family: 'OpenDyslexic';",
      "  src: url('" + base + "OpenDyslexic-Italic.woff2') format('woff2');",
      "  font-weight: normal; font-style: italic;",
      "}",
      "@font-face {",
      "  font-family: 'OpenDyslexic';",
      "  src: url('" + base + "OpenDyslexic-BoldItalic.woff2') format('woff2');",
      "  font-weight: bold; font-style: italic;",
      "}",
      "* { font-family: 'OpenDyslexic', sans-serif !important; }"
    ].join('\n');
  }

  function applyFont() {
    if (document.getElementById(STYLE_ID)) return;
    var style = document.createElement('style');
    style.id = STYLE_ID;
    style.textContent = buildCSS();
    (document.head || document.documentElement).appendChild(style);
  }

  function removeFont() {
    var el = document.getElementById(STYLE_ID);
    if (el) el.remove();
  }

  // Apply on load based on stored preference for this hostname
  browser.storage.local.get(location.hostname).then(function (result) {
    if (result[location.hostname] === true) applyFont();
  });

  // Listen for real-time toggle messages from the popup
  browser.runtime.onMessage.addListener(function (msg) {
    if (msg.type === 'OD_SET') {
      msg.enabled ? applyFont() : removeFont();
    }
  });
}());
EOF

# ── background.js ─────────────────────────────────────────────────────────────
cat > "$EXT/background.js" << 'EOF'
// Service worker.
// Per-site on/off state is written directly by popup.js via browser.storage.local.
EOF

# ── popup.html ────────────────────────────────────────────────────────────────
cat > "$EXT/popup.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>OpenDyslexic</title>
  <link rel="stylesheet" href="popup.css">
</head>
<body>
  <div class="header">
    <img src="images/icon-48.png" alt="" class="logo">
    <span class="title">OpenDyslexic</span>
  </div>

  <div class="site-row">
    <div>
      <div class="label">This site</div>
      <div class="hostname" id="hostname">—</div>
    </div>
    <label class="switch">
      <input type="checkbox" id="toggle">
      <span class="knob"></span>
    </label>
  </div>

  <div class="divider"></div>

  <div class="download-row">
    <div>
      <div class="label">System-wide font</div>
      <div class="sub">Use OpenDyslexic in any app</div>
    </div>
    <a href="#" id="dl-link" class="dl-btn">Download</a>
  </div>

  <script src="popup.js"></script>
</body>
</html>
EOF

# ── popup.css ─────────────────────────────────────────────────────────────────
cat > "$EXT/popup.css" << 'EOF'
* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  width: 280px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
  font-size: 13px;
  background: #fff;
  color: #1c1c1e;
}

@media (prefers-color-scheme: dark) {
  body        { background: #1c1c1e; color: #f2f2f7; }
  .header     { border-bottom-color: #3a3a3c; }
  .divider    { background: #3a3a3c; }
  .label      { color: #636366; }
  .sub        { color: #636366; }
  .dl-btn     { background: #2c2c2e; color: #c39ef0; }
  .dl-btn:hover { background: #3a3a3c; }
}

/* ── Header ── */
.header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px;
  border-bottom: 1px solid #e5e5ea;
}

.logo  { width: 28px; height: 28px; border-radius: 6px; }
.title { font-size: 15px; font-weight: 600; }

/* ── Site row ── */
.site-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
}

.label {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #8e8e93;
  margin-bottom: 3px;
}

.hostname {
  font-size: 14px;
  font-weight: 500;
  max-width: 170px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ── Toggle switch ── */
.switch          { position: relative; width: 44px; height: 26px; flex-shrink: 0; }
.switch input    { display: none; }

.knob {
  position: absolute;
  inset: 0;
  background: #e5e5ea;
  border-radius: 13px;
  cursor: pointer;
  transition: background .2s;
}

.knob::before {
  content: '';
  position: absolute;
  width: 22px; height: 22px;
  left: 2px; top: 2px;
  background: #fff;
  border-radius: 50%;
  box-shadow: 0 1px 3px rgba(0,0,0,.25);
  transition: transform .2s;
}

.switch input:checked + .knob              { background: #4a147c; }
.switch input:checked + .knob::before     { transform: translateX(18px); }
.switch input:disabled + .knob            { opacity: .4; cursor: default; }

/* ── Divider ── */
.divider { height: 1px; background: #e5e5ea; margin: 0 16px; }

/* ── Download row ── */
.download-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px 14px;
}

.sub { font-size: 12px; color: #8e8e93; margin-top: 2px; }

.dl-btn {
  text-decoration: none;
  font-size: 12px;
  font-weight: 500;
  color: #4a147c;
  background: #f2eef8;
  padding: 5px 10px;
  border-radius: 6px;
  white-space: nowrap;
  transition: background .15s;
}
.dl-btn:hover { background: #e5daf5; }
EOF

# ── popup.js ──────────────────────────────────────────────────────────────────
cat > "$EXT/popup.js" << 'EOF'
(async function () {
  var toggle     = document.getElementById('toggle');
  var hostnameEl = document.getElementById('hostname');
  var dlLink     = document.getElementById('dl-link');

  var tabs = await browser.tabs.query({ active: true, currentWindow: true });
  var tab  = tabs[0];

  var hostname = '';
  try { hostname = new URL(tab.url).hostname; } catch (_) {}

  hostnameEl.textContent = hostname || 'this page';

  if (hostname) {
    var stored = await browser.storage.local.get(hostname);
    toggle.checked = stored[hostname] === true;

    toggle.addEventListener('change', async function () {
      var enabled = toggle.checked;
      await browser.storage.local.set({ [hostname]: enabled });
      try {
        await browser.tabs.sendMessage(tab.id, { type: 'OD_SET', enabled: enabled });
      } catch (_) {
        // Content script not yet injected — preference will apply on next page load.
      }
    });
  } else {
    toggle.disabled = true;
  }

  dlLink.addEventListener('click', function (e) {
    e.preventDefault();
    browser.tabs.create({ url: 'https://github.com/antijingoist/opendyslexic/releases' });
    window.close();
  });
}());
EOF

# ── Placeholder icons (pure Python stdlib — no Pillow needed) ─────────────────
echo "==> Generating placeholder icons"
python3 << 'PYEOF'
import struct, zlib

def chunk(ctype, data):
    c = ctype + data
    return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)

def make_png(size, r, g, b):
    ihdr = struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0)
    raw  = b''.join(b'\x00' + bytes([r, g, b]) * size for _ in range(size))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', ihdr)
            + chunk(b'IDAT', zlib.compress(raw))
            + chunk(b'IEND', b''))

for size, path in [
    (16,  'extension/images/icon-16.png'),
    (48,  'extension/images/icon-48.png'),
    (128, 'extension/images/icon-128.png'),
]:
    with open(path, 'wb') as f:
        f.write(make_png(size, 74, 20, 140))   # #4a147c — deep purple

print("    Icons written.")
PYEOF

# ── Download OpenDyslexic fonts ────────────────────────────────────────────────
echo "==> Downloading OpenDyslexic fonts"

for font in "OpenDyslexic-Regular" "OpenDyslexic-Bold" "OpenDyslexic-Italic" "OpenDyslexic-BoldItalic"; do
  printf "    %s.woff2 ... " "$font"
  curl -fsSL "$FONT_BASE/$font.woff2" -o "$EXT/fonts/$font.woff2"
  echo "ok"
done

# Fallback: some versions of the repo use a hyphen in "Bold-Italic"
if [ ! -s "$EXT/fonts/OpenDyslexic-BoldItalic.woff2" ]; then
  printf "    Trying OpenDyslexic-Bold-Italic.woff2 ... "
  curl -fsSL "$FONT_BASE/OpenDyslexic-Bold-Italic.woff2" \
    -o "$EXT/fonts/OpenDyslexic-BoldItalic.woff2" && echo "ok" \
    || echo "not found — bold-italic will fall back to regular"
fi

# ── Generate Xcode project via safari-web-extension-converter ─────────────────
echo "==> Running safari-web-extension-converter"
xcrun safari-web-extension-converter \
  --project-location "$SCRIPT_DIR" \
  --app-name         "OpenDyslexic" \
  --bundle-identifier "com.opendyslexic.safari" \
  --swift \
  --macos-only \
  --no-open \
  "$EXT"

echo ""
echo "All done. Next steps:"
echo ""
echo "  1. open \"$SCRIPT_DIR/OpenDyslexic/OpenDyslexic.xcodeproj\""
echo "  2. In Xcode: select the OpenDyslexic scheme → Run (⌘R)"
echo "  3. In Safari: Settings → Extensions → enable OpenDyslexic"
echo "  4. Click the toolbar icon on any site to toggle the font on/off."
echo ""
echo "  Note: placeholder icons are solid purple."
echo "  Replace extension/images/icon-{16,48,128}.png with real artwork,"
echo "  then re-run the Xcode project to pick them up."
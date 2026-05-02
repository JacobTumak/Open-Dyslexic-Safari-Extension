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

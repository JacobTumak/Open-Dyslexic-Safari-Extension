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

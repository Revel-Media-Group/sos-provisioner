import puppeteer from "puppeteer-extra";
import StealthPlugin from "puppeteer-extra-plugin-stealth";

puppeteer.use(StealthPlugin());

(async () => {
  const browser = await puppeteer.launch({
    headless: false,
    args: [
      "--class chromium.signageos",
      "--disable-web-security",
      "--disable-site-isolation-trials",
      "--disable-features=UseChromeOSDirectVideoDecoder",
      "--enable-features=AcceleratedVideoDecodeLinuxGL",
      "--disable-background-media-suspend",
      "--force-renderer-accessibility",
      "--kiosk",
      "--noerrdialogs",
      "--disable-features=TranslateUI",
      "--disable-popup-blocking",
      "--no-sandbox",
      "--user-data-dir=/var/lib/chromium",
      "--enable-logging=stderr",
      "--disable-gpu-driver-bug-workarounds",
      "--disable-gpu-process-crash-limit",
      "--disable-sync",
      "--disable-background-networking",
      "--disable-background-timer-throttling",
      "--disable-backgrounding-occluded-windows",
      "--disable-component-update",
      "--disable-crash-reporter",
      "--disable-renderer-accessibility",
      "--disable-dev-shm-usage",
      "--no-default-browser-check",
      "--disable-pinch",
      "--disable-logging",
    ],
  });
  const page = await browser.newPage();

  await page.goto("file:///usr/share/signageos/client/index.html");
  await page.keyboard.press("a");
})();

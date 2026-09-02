# AR OS reference catalog

## Archive summary

- Source: `Archive-original.zip`, preserved byte-for-byte from the upload.
- Contents: 49 JPEG concept screenshots plus macOS metadata entries.
- Image range: `IMG_1887.jpg` through `IMG_1936.jpg`; `IMG_1899.jpg` is not in
  the supplied archive.
- Typical dimensions: approximately 2336 × 1320, landscape.
- Machine-readable dimensions and SHA-256 checksums: `inventory.json`.
- Overview sheets: `contact-sheets/all-references.jpg`,
  `contact-sheets/setup-sequence.jpg`, `contact-sheets/desktop-apps.jpg`, and
  `contact-sheets/lock-login.jpg`.

The images are presentation renders and screenshots, not separable source UI
assets. They are therefore used as the visual source of truth while controls,
text, layout, effects, icons, and windows are rebuilt natively and responsively.

## Screen inventory

| File | Screen/state | Implementation consequence |
| --- | --- | --- |
| IMG_1887.jpg | Dark purple AR OS boot splash with centered logo and spinner | Branded Plymouth theme; logo and progress centered on a quiet gradient |
| IMG_1888.jpg | Lavender boot/setup transition with small lower-center progress | OOBE and installer launch over the ribbon wallpaper; restrained progress state |
| IMG_1889.jpg | Compact AR OS 3 language-selection dialog | Calamares starts at locale; AR Setup uses compact glass controls |
| IMG_1890.jpg | Large tilted “Welcome to arOS setup” window | Installer welcome copy and spacious single-action composition |
| IMG_1891.jpg | Edition card grid: Pro, Home, Gaming, Education, Enterprise, Business, Basic, Lite | Card-grid language reused; real build intentionally has one open edition |
| IMG_1892.jpg | Activation screen with empty key field and Skip | Activation omitted because locking a Linux install behind a fake key is not valid behavior |
| IMG_1893.jpg | Activation screen with filled product key | No product keys stored or reproduced |
| IMG_1894.jpg | Destination disk selection | Calamares partitioner; no destructive option preselected |
| IMG_1895.jpg | “Are you ready?” destructive confirmation | Calamares summary and explicit final confirmation |
| IMG_1896.jpg | Installing AR OS 3 with progress bar | Real unpack/configure/initramfs/bootloader progress |
| IMG_1897.jpg | Smaller install progress/finishing state | Branded Calamares execution and finish pages |
| IMG_1898.jpg | Post-install Welcome with left setup navigation | AR Setup sidebar, banner, progress states, and responsive content panel |
| IMG_1900.jpg | “Let’s transfer your data” | OOBE explains new setup; migration provider remains a future extension |
| IMG_1901.jpg | Preferences with language/region dropdown rows | Region and keyboard pages use real locale values |
| IMG_1902.jpg | Create an account with circular avatar choices | Installer creates the Unix account; OOBE configures display name/avatar presentation |
| IMG_1903.jpg | Wallpaper/computer-name setup and wallpaper thumbnails | Appearance page and wallpaper vectors; hostname remains system-controlled |
| IMG_1904.jpg | Sign in to AbdiRPC/cloud services | No mandatory cloud account; local-first account behavior |
| IMG_1905.jpg | Location services page | Opt-in location preference with future GeoClue/portal policy boundary |
| IMG_1906.jpg | Time-zone page with world map | Real `systemd-timedated` time-zone selection |
| IMG_1907.jpg | Light/dark “Look” selection with wallpaper previews | Shared light/dark tokens and preview cards |
| IMG_1908.jpg | Protect AR OS automatically with three update/security choices | Signed update policy and automatic-security-update preference |
| IMG_1909.jpg | Express settings summary | Privacy page uses explicit choices instead of bundled dark patterns |
| IMG_1910.jpg | Setup completion/ready page | AR Setup finish state |
| IMG_1911.jpg | “Thank you” completion dialog with wallpaper preview | Final confirmation and transition to desktop |
| IMG_1912.jpg | Lavender welcome/loading transition | First-session launch transition and branded wallpaper |
| IMG_1913.jpg | “Welcome to arOS” text over wallpaper | First-run completion language |
| IMG_1914.jpg | Clean desktop: centered capsule top bar and compact centered dock | Separate KWin surfaces for wallpaper, bar, and dock |
| IMG_1915.jpg | Close view of circular lightning AR logo | New scalable AR logo variants and circular gradient treatment |
| IMG_1916.jpg | Full launcher with greeting, search, seven-column app grid, dock | Native XDG application model, search, responsive grid, glass overlay |
| IMG_1917.jpg | Perspective close-up of launcher icon grid | Round colorful icons, generous cell spacing, labels beneath |
| IMG_1918.jpg | AR Files home with sidebar, recent previews, pinned folders, toolbar | Real filesystem grid/list, sidebar locations, actions, search-ready layout |
| IMG_1919.jpg | Tall quick/system menu at upper right | Quick Controls window with toggles, status, sliders, notifications, and power |
| IMG_1920.jpg | Settings home with recent cards, wallpapers, Bluetooth, storage, category grid | AR Settings dashboard and reusable setting cards backed by real services |
| IMG_1921.jpg | Expanded top-bar assistant prompt | Search bar retains room for extensible providers; no fake assistant backend |
| IMG_1922.jpg | Compact prompt with microphone/send affordances | Capsule proportions and top-bar action rhythm |
| IMG_1923.jpg | Aqua glass productivity/document window over desktop | AR client-side glass window chrome and translucent app surfaces |
| IMG_1924.jpg | Enlarged assistant command/result panel | Notification/action panels use strong glass and clear primary action |
| IMG_1925.jpg | Blue translucent communications window | Window material adapts to accent/content while preserving shared chrome |
| IMG_1926.jpg | Desktop crop emphasizing split search/status capsules | Top bar is composed of logo, search capsule, and status capsule |
| IMG_1927.jpg | Media notification beneath top bar | Freedesktop notifications preserved in notification center; banner extension planned |
| IMG_1928.jpg | Reminder card under top bar with action | Notification actions are exported and invokable |
| IMG_1929.jpg | Pink presentation/document editing window | Third-party apps coexist through Wayland/XWayland; AR chrome applies to AR apps |
| IMG_1930.jpg | “Customize arOS!” glass title card | Appearance/OOBE hero treatment and large-radius luminous outline |
| IMG_1931.jpg | Dark widget dashboard inside luminous desktop frame | Desktop widget cards and dark/night appearance direction |
| IMG_1932.jpg | Alternate city desktop with large date and left widgets | Night wallpaper, clock card, and future widget placement model |
| IMG_1933.jpg | Lock screen with date/time and stacked notifications | AR lock/login night palette; notification privacy remains configurable work |
| IMG_1934.jpg | Login with avatar and empty password field | SDDM theme and AR Lock center composition |
| IMG_1935.jpg | Login with entered password and bottom power actions | PAM password flow and sleep/restart/power controls |
| IMG_1936.jpg | Authentication progress / “Please wait” | Auth transition state; PAM controls the result |

## Extracted visual tokens

| Token family | Reference reading | Implemented value/direction |
| --- | --- | --- |
| Background | Pale lavender ribbon; dark violet/city alternative | New `ar-ribbon.svg` and `ar-night.svg` vector wallpapers |
| Primary accent | Electric violet with magenta/blue shifts | `#8d4cff`, `#ff59c7`, `#3c8cff` |
| Surface | Milky translucent white or deep translucent violet | Centralized light/dark surface tokens; KWin blur underneath |
| Corners | Small controls ~12 px, cards ~18 px, windows ~28 px, capsules fully rounded | `radiusSmall`, `radius`, `radiusLarge`, `radiusPill` |
| Chrome | Thin luminous inner/outer borders, soft colored shadow | One-pixel hairline plus translucent nested highlight and KWin composition |
| Type | Neutral modern sans, high-contrast large headings, restrained labels | Inter/Noto Sans stack; 28–38 px hero, 13–15 px content, 10–12 px metadata |
| Motion | Soft fades, hover lift, capsule toggle movement | 90–360 ms cubic/opacity transitions |
| Layout | Centered floating elements, generous negative space, compact dock | Independent centered surfaces and responsive grids |
| Icons | Circular saturated gradient tiles with simple white glyphs | Programmatic `ARIcon` component and theme-derived colors |

## Functional translation rules

1. Never show a setting that only changes a local visual variable when it claims
   to control hardware or a Linux service.
2. Never embed these JPEGs as windows, settings pages, launcher screens, or fake
   controls.
3. Preserve distinctive hierarchy and proportions, not the perspective tilt or
   camera blur of presentation renders.
4. Safety-critical installer behavior belongs to Calamares even when that means
   a more conventional partition screen.
5. Concept-only cloud, activation, assistant, and product-edition behavior stays
   absent until a real, licensed, privacy-reviewed service exists.


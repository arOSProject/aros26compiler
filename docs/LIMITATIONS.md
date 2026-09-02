# Developer-preview limitations

This repository implements a substantial native first pass, but it is not yet a
production distribution release.

- The native Qt project and ISO require compilation in the documented Debian 13
  build environment. The creation environment lacked Qt/CMake and could only run
  repository/static validation.
- Third-party windows use KWin's available decoration unless they draw their own;
  AR applications have native AR client-side chrome. A production AR KDecoration
  plugin is still needed for complete visual consistency.
- Background blur depends on KWin's blur effect and GPU support. The translucent
  fallback remains readable but is not a shader-identical reproduction.
- AR Lock uses real PAM authentication but is not yet a compositor-owned secure
  KScreenLocker plugin. See the security document before calling it a hard lock.
- AR Files supports core operations but still needs copy progress, conflict
  resolution, Trash restore UI, thumbnails, archive actions, permissions UI,
  network mounts, and removable-drive eject UI.
- AR Search scans installed applications and a bounded part of the home tree.
  A production release should add an indexed file provider, ranking, recent
  activity, calculators, web opt-in, and provider permission controls.
- AR Software uses a curated Flatpak catalog and the real Flatpak installer. A
  complete store still needs AppStream/Flathub metadata, screenshots, progress,
  permissions review, uninstall, rollback, and parental/admin policies.
- AR Updater delegates visible transaction handling to PackageKit in AR Terminal.
  Native PackageKit D-Bus progress and offline reboot updates remain to add.
- OOBE records location and diagnostics preferences locally; it does not upload
  telemetry. Fine-grained GeoClue portal policy and crash-report consent UI need
  completion before network diagnostics exist.
- Calamares is AR-branded, but the concept's unique angled presentation is not
  forced onto the safety-critical partitioner. The post-install AR Setup matches
  the cataloged sidebar flow more closely.
- Multi-monitor bar/dock placement currently follows the primary screen. Output-
  per-screen surfaces and panel migration require additional KWin integration.
- Accessibility needs screen-reader labels, keyboard navigation review, reduced
  motion, high contrast, magnification, switch input, and localization QA.
- Touch gestures, overview/workspace UI, clipboard history, screenshot markup,
  captive portal UI, VPN editor, advanced display layout, printer settings, and
  account management need dedicated AR front ends; upstream services remain
  available underneath.

These are implementation boundaries, not fake buttons. Existing controls call
real services; unfinished areas are kept explicit so later work can strengthen
the operating system without misleading users.

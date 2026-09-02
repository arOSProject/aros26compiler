# AR OS architecture

## System layers

| Layer | Choice | Responsibility |
| --- | --- | --- |
| Distribution | Debian 13 stable | Kernel, drivers, signed repositories, security updates, package manager |
| Session | SDDM + `ar-os.desktop` | Login and direct launch into the AR OS Wayland session |
| Compositor | KWin 6 Wayland | Composition, protocols, outputs, input, workspaces, XWayland, effects |
| Desktop | AR Shell | Wallpaper, top bar, dock, launcher, search, status, notifications |
| Native UI | Qt 6 / Qt Quick / QML | Responsive glass components and applications |
| System bridge | C++ / QtDBus / PAM | Service state, actions, filesystem, auth, notifications, app discovery |
| Installer | Calamares | Locale, keyboard, partitioning, users, bootloader, install confirmation |
| Image | Debian live-build | Reproducible rootfs assembly and hybrid x86-64 UEFI ISO |

Debian 13 was selected because it is the current stable production release and
has a supported amd64 lifecycle through 2030. The live image uses Debian's
`live-build` package, the same family of tooling used for Debian Live systems.

Authoritative upstream references:

- <https://www.debian.org/releases/trixie/>
- <https://packages.debian.org/trixie/live-build>
- <https://develop.kde.org/docs/plasma/kwin/>
- <https://doc.qt.io/qt-6/cmake-build-qml-application.html>
- <https://calamares.io/docs/users-guide/>

## Session lifecycle

1. SDDM starts the `AR OS` Wayland session.
2. `/usr/libexec/ar-os/ar-session` sets AR OS/XDG variables and starts
   `kwin_wayland --xwayland`.
3. KWin starts `ar-session-child` using `--exit-with-session`.
4. The child imports the Wayland environment into D-Bus/systemd user services,
   starts the polkit agent and desktop portal, then starts AR Shell.
5. AR Shell registers `org.freedesktop.Notifications` and creates separate
   compositor windows for the desktop, bar, dock, launcher, and quick controls.
6. The `arshell` KWin script assigns bottom/above/task-switcher roles using
   window captions. The shell process is the session lifetime process.
7. AR Setup opens when its completion record does not exist.

AR Shell is deliberately not a compositor. Reusing KWin avoids reimplementing
critical Wayland protocols, multi-monitor layout, input methods, accessibility
foundations, XWayland, workspaces, damage tracking, and GPU presentation.

## C++ service boundary

`SystemBridge` exposes narrow operations to QML:

- NetworkManager through `nmcli` for radio state and active SSID.
- BlueZ through `bluetoothctl` for adapter power.
- PipeWire/WirePlumber through `wpctl` for sink volume.
- kernel backlight through `brightnessctl`.
- XDG desktop discovery and launch from trusted desktop entries.
- file listing and mutation using Qt filesystem APIs.
- Flatpak installation and PackageKit update workflows in a visible terminal.
- system information from `/etc/os-release`, `/proc`, and Qt.
- power operations through `systemctl`/logind.
- locale/time-zone/account updates through polkit-visible system tools.

AR Search is a provider registry, not one hard-coded query function. Built-in
providers implement XDG applications, settings, and bounded home-directory file
search. Additional compiled providers implement the same `SearchProvider`
interface and register with `SearchRegistry`, retaining a single ranked result
shape and action boundary.

QML does not receive an arbitrary shell-evaluation method. `launchCommand()`
uses a fixed map, and Flatpak IDs and locale/time-zone values are validated.
This keeps styling code from becoming an accidental command-execution surface.

`NotificationServer` owns the freedesktop notifications D-Bus name when Plasma
Shell is absent and exports `Notify`, `CloseNotification`, capabilities, action
signals, and close signals.

`AuthController` uses PAM's `login` service for the current user. Password bytes
are zeroed after the PAM call.

## Application model

All AR applications share one compiled runtime but are invoked through separate
commands (`ar-files`, `ar-settings`, and so on). This avoids duplicated service
code while preserving normal Linux desktop entries, processes, windows, and
launch behavior. It is comparable to a multi-call native toolkit binary, not a
single simulated desktop canvas.

AR Terminal launches Konsole with an AR profile. A mature terminal emulator is
a security boundary with PTY, Unicode, escape-sequence, clipboard, and process
semantics; wrapping it is more correct than a partial QML terminal.

## Visual system

`qml/components` defines palette, type hierarchy, spacing, radii, animation,
glass surfaces, buttons, icons, toggles, navigation, settings cards, and native
client-side window chrome. AR apps never import reference screenshots. Wallpaper
art is a new vector implementation of the lavender ribbon language visible in
the supplied concepts.

KWin's blur and background-contrast effects operate behind translucent AR
windows. When effects are unavailable, panels retain sufficient alpha, borders,
and contrast to remain usable.

## Packaging boundary

`ar-os-desktop` contains AR-owned binaries, shell, apps, themes, and session
configuration. Upstream packages remain upstream packages. AR OS does not fork
or overwrite KWin, Qt, NetworkManager, or systemd. A future AR package archive
should publish only AR-owned packages plus explicit, reviewable overrides.

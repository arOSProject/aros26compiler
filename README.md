# AR OS

AR OS is a real, native Linux desktop implementation of the AR OS 3 visual
concept by AbdiRPC4789. The project owner has permission to use the supplied
AR OS / Miracle OS concept assets and the AR OS name. The original reference
archive is preserved under `reference/`, and its 49 images are cataloged in
[`reference/REFERENCE_CATALOG.md`](reference/REFERENCE_CATALOG.md).

This repository is not a web mockup or Electron simulation. It builds a Qt 6
and QML desktop stack for KWin Wayland, packages it as a Debian package, and
contains a Debian live-build configuration for a bootable x86-64 UEFI ISO.

## What works in this developer preview

- AR Desktop, floating top bar, dock, launcher, app/file search, quick controls,
  power menu, and notification center.
- Freedesktop notification service implementation with action and close signals.
- Real application discovery from XDG `.desktop` files.
- AR Files browsing the real filesystem, opening files, creating folders,
  renaming, moving to Trash, and accepting external file drops.
- AR Settings wired to NetworkManager, BlueZ, PipeWire/WirePlumber,
  `brightnessctl`, systemd/logind-compatible power actions, appearance, and
  PackageKit.
- AR Software wired to system Flatpak/Flathub and AR Updater wired to PackageKit.
- AR Terminal as a styled Konsole profile, retaining a mature terminal emulator
  rather than shipping an unsafe partial emulator.
- AR Setup/OOBE for locale, keyboard preference, user display name, appearance,
  time zone, location preference, privacy, and update policy.
- PAM-backed AR lock UI and a matching SDDM login theme.
- KWin script for desktop/top-bar/dock/launcher window roles.
- Branded Plymouth boot, SDDM login, Calamares installer, Debian package, live
  image, QEMU/UEFI, test, and CI entry points.

## Base and architecture decision

AR OS targets **Debian 13 (trixie) stable**. Debian 13 is the current Debian
stable release, supports amd64, and has a five-year lifecycle. KWin 6 supplies
the compositor, Wayland protocols, XWayland compatibility, window management,
effects, input, workspaces, and display handling. AR Shell replaces Plasma
Shell: users log into an `AROS` session and see AR OS directly.

Qt 6.5+ and QML provide the reusable glass design system and responsive native
applications. C++ owns system boundaries, desktop entry parsing, file I/O,
PAM, D-Bus notifications, and service adapters. Calamares owns disk changes so
installation has a reviewed partitioner and explicit confirmation instead of
custom destructive code.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for details.

## Build the desktop

Use a clean Debian 13 development environment:

```bash
sudo apt update
sudo apt install build-essential cmake ninja-build pkg-config \
  qt6-base-dev qt6-declarative-dev qt6-wayland-dev libpam0g-dev \
  libgl1-mesa-dev
./scripts/build.sh
```

Run one app under an existing Wayland desktop:

```bash
./build/ar-app --component settings
./build/ar-app --component files
./build/ar-app --component oobe
```

Install the compiled stack into a disposable VM or development machine:

```bash
sudo cmake --install build
```

Select **AR OS** from SDDM on the next login.

## Build the package and ISO

The ISO build is intended for a Debian 13 amd64 VM/container with at least
20 GB free disk space. Building an image does not write to any target disk.

```bash
sudo apt install live-build devscripts debhelper \
  build-essential cmake ninja-build pkg-config qt6-base-dev \
  qt6-declarative-dev qt6-wayland-dev libpam0g-dev
./scripts/build-package.sh
sudo ./scripts/build-iso.sh
```

Output:

- `AR-OS-0.1.0-amd64.iso`
- `AR-OS-0.1.0-amd64.iso.sha256`

The live image boots into AR OS and exposes **Install AR OS** on the desktop.
Calamares starts with no partitioning choice selected. Erasing, replacing, or
shrinking a disk requires direct user selection and the installer summary.

## Run in QEMU

```bash
sudo apt install qemu-system-x86 qemu-utils ovmf
./scripts/run-qemu.sh
```

The runner creates a separate 40 GB `ar-os-test.qcow2`, uses OVMF UEFI, and
enables KVM only when `/dev/kvm` is available. Nothing outside that test image
is offered to the guest as an install disk.

## Validate

```bash
./scripts/validate.sh
```

When the Qt toolchain is installed, `scripts/build.sh` compiles, runs Qt unit
tests, and lets CMake invoke QML cache generation. The repository validator also
checks all reference files, QML structure, native integration points, shell
syntax, ISO safety defaults, and the rule that screenshots are never embedded
as fake UI.

## Documentation

- [Build and release](docs/BUILDING.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Installation](docs/INSTALLING.md)
- [Security and Secure Boot plan](docs/SECURITY.md)
- [Hardware and compatibility](docs/HARDWARE.md)
- [Current limitations](docs/LIMITATIONS.md)
- [Reference catalog](reference/REFERENCE_CATALOG.md)

## Licensing and provenance

Original code and programmatic assets in this repository are intended for
GPL-3.0-or-later distribution. The supplied concept reference images remain
separate design-source material used with the project owner's permission; they
are not silently relicensed by this repository. See [`LICENSES.md`](LICENSES.md).

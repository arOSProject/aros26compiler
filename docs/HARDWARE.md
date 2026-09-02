# Hardware and compatibility

AR OS inherits Debian 13's kernel and Mesa hardware support. The live image
includes common firmware packages, Vulkan drivers, PipeWire, NetworkManager,
BlueZ, UPower, UDisks, fwupd, and KScreen.

## Expected support

- Intel and AMD x86-64 CPUs.
- Intel and AMD GPUs through kernel DRM and Mesa.
- NVIDIA GPUs through Nouveau in the live environment.
- Common Intel, Atheros, Realtek, and other firmware-covered Wi-Fi adapters.
- Ethernet, Bluetooth, USB storage, cameras exposed through portals, keyboards,
  mice, touchpads, laptop batteries, backlights, and external displays.
- HiDPI and fractional scaling through KWin/KScreen.
- X11-only applications through XWayland.
- Audio, microphones, Bluetooth audio, and per-app routing through PipeWire and
  WirePlumber.

## NVIDIA

The image does not silently install the proprietary NVIDIA driver. The Debian
`contrib`, `non-free`, and `non-free-firmware` components are configured so a
user may install the appropriate tested Debian driver after installation.
Production documentation must map GPU generations to supported driver branches,
test Secure Boot module signing, and retain a recovery boot using Nouveau.

## Gaming and Windows compatibility

- Steam is offered through the Flatpak catalog.
- Proton is managed by Steam per game.
- Wine 64-bit support is included in the live-build package set.
- Bottles is offered through Flatpak for isolated Wine prefixes.
- Game controllers use normal Linux input/hid drivers.

No proprietary game service is required to boot or use AR OS.

## Required release test matrix

Test at minimum Intel iGPU, AMD APU/GPU, Nouveau and proprietary NVIDIA, two
HiDPI laptops, multi-monitor mixed refresh/scaling, suspend/resume, docking,
Bluetooth audio, USB audio, Wi-Fi roaming, Ethernet/VPN, touchpad gestures,
touchscreen, encrypted install, UEFI firmware updates, and low-storage behavior.


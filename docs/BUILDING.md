# Build and release

## Development build

The supported build host is Debian 13 amd64. Qt 6.5 or newer is required.

```bash
sudo apt update
sudo apt install build-essential cmake ninja-build pkg-config \
  qt6-base-dev qt6-declarative-dev qt6-wayland-dev libpam0g-dev
AR_BUILD_TYPE=Debug ./scripts/build.sh
```

For release optimization:

```bash
AR_BUILD_TYPE=Release AR_BUILD_DIR="$PWD/build-release" ./scripts/build.sh
```

CMake enables automoc, the QML cache compiler, compile commands, Qt unit tests,
and install rules. `scripts/validate.sh` remains useful when only repository
tools are installed.

## Debian package

```bash
sudo apt install devscripts debhelper dh-sequence-cmake
./scripts/build-package.sh
```

The package appears beside the repository as
`ar-os-desktop_0.1.0_amd64.deb`. Package dependencies intentionally name the
service providers AR OS integrates with.

## Live ISO

Install live-build and run the image builder as root inside an isolated Debian
13 build VM or container:

```bash
sudo apt install live-build
sudo ./scripts/build-iso.sh
```

The builder:

1. Builds `ar-os-desktop` unless `AR_SKIP_PACKAGE_BUILD=1`.
2. Places that `.deb` in live-build's `packages.chroot`.
3. Purges previous live-build state.
4. Configures Debian trixie amd64, UEFI/BIOS hybrid boot, installer support,
   firmware areas, and live boot parameters.
5. Assembles the root filesystem and ISO.
6. Renames the image and writes SHA-256 metadata.

The package list includes free firmware plus Debian's separate non-free firmware
area for common Wi-Fi and GPU hardware. It includes Wine, Flatpak, and the Steam
Flatpak catalog entry; proprietary applications are not mandatory base packages.

## CI

`.github/workflows/build.yml` performs validation and native compilation on a
Debian 13 container. ISO creation is a manual job because it is privileged,
large, and network-heavy. Release automation should publish the ISO, checksum,
source commit, package manifest, and SBOM together.

## Reproducibility

The project is near-reproducible rather than bit-for-bit reproducible today:

- source and configuration are versioned;
- Debian repository metadata and package versions are not yet pinned to a
  snapshot timestamp;
- the ISO records the current Debian point-update packages;
- release CI should set `SOURCE_DATE_EPOCH` from the source commit;
- future releases should use `snapshot.debian.org` or an AR-controlled snapshot,
  record all package hashes, and publish an in-toto/SLSA provenance statement.

## Local validation status

The ChatGPT Work build environment used to create this repository did not
provide CMake, Qt development packages, or the Linux capabilities required by
APT's `_apt` helper. Repository, shell, asset, and structural tests were run
there; the native compile and ISO build are designed for and must be completed
in the documented Debian 13 environment. CI treats compilation as mandatory.

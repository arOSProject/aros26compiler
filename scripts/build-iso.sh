#!/bin/sh
set -eu

project_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
iso_dir="$project_dir/iso"

if [ "$(id -u)" -ne 0 ]; then
    echo "build-iso.sh must run as root inside a Debian 13 build VM or container." >&2
    exit 1
fi

if ! command -v lb >/dev/null 2>&1; then
    echo "live-build is required. Install it with: apt install live-build" >&2
    exit 1
fi

if [ "${AR_SKIP_PACKAGE_BUILD:-0}" != "1" ]; then
    "$project_dir/scripts/build-package.sh"
fi

package="$(find "$project_dir/.." -maxdepth 1 -name 'ar-os-desktop_*_amd64.deb' -print -quit)"
if [ -z "$package" ]; then
    echo "No ar-os-desktop amd64 package was found next to the repository." >&2
    exit 1
fi

mkdir -p "$iso_dir/config/packages.chroot"
cp "$package" "$iso_dir/config/packages.chroot/"
cd "$iso_dir"
lb clean --purge
./auto/config
lb build

image="$(find . -maxdepth 1 -name 'live-image-amd64*.iso' -print -quit)"
if [ -n "$image" ]; then
    cp -L "$image" "$project_dir/AR-OS-0.1.0-amd64.iso"
    (cd "$project_dir" && sha256sum "AR-OS-0.1.0-amd64.iso" > "AR-OS-0.1.0-amd64.iso.sha256")
fi





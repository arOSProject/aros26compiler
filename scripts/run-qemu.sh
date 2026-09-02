#!/bin/sh
set -eu

project_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
iso="${1:-$project_dir/AR-OS-0.1.0-amd64.iso}"
disk="${AR_QEMU_DISK:-$project_dir/ar-os-test.qcow2}"
memory="${AR_QEMU_MEMORY:-4096}"
cpus="${AR_QEMU_CPUS:-4}"

if [ ! -f "$iso" ]; then
    echo "ISO not found: $iso" >&2
    exit 1
fi

if [ ! -f "$disk" ]; then
    qemu-img create -f qcow2 "$disk" 40G
fi

accel="tcg"
cpu="max"
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    accel="kvm"
    cpu="host"
fi

ovmf_code="/usr/share/OVMF/OVMF_CODE_4M.fd"
ovmf_vars_template="/usr/share/OVMF/OVMF_VARS_4M.fd"
ovmf_vars="$project_dir/ar-os-OVMF_VARS.fd"

if [ ! -f "$ovmf_code" ]; then
    echo "OVMF UEFI firmware was not found. Install the ovmf package." >&2
    exit 1
fi
if [ ! -f "$ovmf_vars" ]; then
    cp "$ovmf_vars_template" "$ovmf_vars"
fi

exec qemu-system-x86_64 \
    -name "AR OS" \
    -machine q35,accel="$accel" \
    -cpu "$cpu" \
    -smp "$cpus" \
    -m "$memory" \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -device virtio-keyboard-pci \
    -device virtio-mouse-pci \
    -device ich9-intel-hda \
    -device hda-duplex \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -drive if=pflash,format=raw,readonly=on,file="$ovmf_code" \
    -drive if=pflash,format=raw,file="$ovmf_vars" \
    -drive file="$disk",if=virtio,format=qcow2 \
    -drive file="$iso",media=cdrom,readonly=on


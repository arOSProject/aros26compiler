# Installing AR OS

## Try the live environment

Verify the ISO checksum, write it to a USB drive using a trusted image writer,
and boot the entry labeled for UEFI. The live environment logs into AR OS and
does not touch internal disks merely by booting.

The desktop shortcut **Install AR OS** launches Calamares. Close it to continue
using the live session without installing.

## Installer mapping from the concept

The concept archive shows language, edition, activation, destination, install,
and a second setup sequence. The real implementation maps those screens as
follows:

| Concept | Real AR OS behavior |
| --- | --- |
| Language | Calamares locale page |
| Edition | One open AR OS edition; no artificial product split |
| Activation | Removed; AR OS does not lock a local Linux installation behind a key |
| Destination | Calamares partition page with no preselected destructive action |
| Ready/install | Calamares summary and explicit install confirmation |
| Progress | Calamares unpack, configuration, initramfs, and bootloader modules |
| Region/keyboard/account | Calamares for install-critical values; AR Setup refines preferences |
| Wallpaper/look/location/privacy | Native AR Setup after first login |

## Disk safety

`initialPartitioningChoice` is `none`. The installer exposes alongside, replace,
erase, and manual options but never chooses one automatically. Review the target
disk model, partitions, encryption, bootloader location, and summary before
selecting Install. Keep backups of anything valuable.

The QEMU runner offers only its dedicated qcow2 disk to the guest and is the
recommended first installation test.

## Encryption

Automated LUKS partitioning is available. For release images, test encrypted
UEFI installs, resume/swap choices, recovery passphrases, and initramfs keyboard
layout before recommending encryption to general users.

## After installation

The first AR OS login opens AR Setup. System changes that require privilege show
a polkit authentication dialog. The live user's automatic login configuration
belongs only to the live image; Calamares configures the installed SDDM user and
AR OS does not enable automatic login by default.


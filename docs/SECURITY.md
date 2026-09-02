# Security design and Secure Boot plan

## Current posture

- Debian signed repositories provide the base, kernel, firmware, and security
  updates.
- AR visual code runs as the logged-in user.
- SDDM handles initial login; AR Lock validates credentials through PAM.
- Protected actions use existing polkit-enabled tools. There is no blanket AR
  polkit rule and no passwordless administrator path.
- OOBE performs one authenticated call to `ar-system-helper`; the helper derives
  the source account from `PKEXEC_UID`, reads only that account's fixed OOBE
  path, validates every value, and exposes no arbitrary command or file path.
- The QML bridge has fixed launch targets and validates structured values; it
  does not expose an arbitrary shell method.
- Flatpak is the default third-party app architecture and applications remain
  subject to portal permissions.
- Destructive disk actions exist only in Calamares and require explicit choices.
- Notification bodies are displayed as text rather than evaluated content.

## Known lock-screen boundary

The current AR Lock process performs real PAM authentication, but it is not yet
embedded as a KWin/KScreenLocker security extension. A user able to terminate
their own lock process could bypass this developer-preview lock UI. Release
images must integrate the design with KScreenLocker or an equivalent
compositor-owned layer and add inhibition, VT-switch, crash-restart, and input
capture tests. The SDDM login boundary is unaffected.

## Secure Boot

Developer ISOs are unsigned. Production Secure Boot requires:

1. A protected offline root signing key and separate online build/signing key.
2. A Microsoft UEFI CA-signed shim, or documented owner-key enrollment for
   non-Microsoft distribution.
3. Signed shim, GRUB, Linux kernel, and any out-of-tree kernel modules.
4. Measured build inputs, reproducible package metadata, and auditable signing
   logs.
5. Kernel lockdown under Secure Boot and module signature enforcement.
6. A signed revocation/update strategy for compromised boot components.
7. Firmware/UEFI, install, update, rollback, and recovery tests on real hardware.

Do not distribute a developer key in the repository or claim Secure Boot merely
because an ISO boots in UEFI mode.

## Updates

PackageKit fronts signed Debian and future AR repositories. A production AR
repository should use short-lived online metadata keys backed by an offline
root, publish expiration metadata, stage rollouts, and support rollback/recovery.
Flatpak remotes use their own signed metadata.

## Crash and debug logging

Qt messages and process failures enter the user journal. Coredumps are governed
by systemd-coredump. Release builds should install split debug symbols in a
separate repository, scrub secrets from diagnostics, obtain consent before any
upload, and define retention limits. AR Setup currently stores diagnostics
preference locally and performs no upload.

## Recovery

Planned release recovery includes a live ISO repair path, previous-kernel boot
entries, Btrfs snapshot integration if Btrfs becomes a supported install option,
package rollback guidance, and a user-data-safe reinstall path. The current
default filesystem is ext4 for conservative installer behavior.

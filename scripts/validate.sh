#!/bin/sh
set -eu

project_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

find "$project_dir/scripts" "$project_dir/iso/auto" "$project_dir/iso/config/hooks" \
    -type f \( -name '*.sh' -o -name 'ar-*' -o -name '*.hook.chroot' \) \
    -exec sh -n {} \;
python3 "$project_dir/tests/validate_repository.py" "$project_dir"

if command -v qmllint6 >/dev/null 2>&1; then
    find "$project_dir/qml" -name '*.qml' -print0 | xargs -0 qmllint6
elif command -v qmllint >/dev/null 2>&1; then
    find "$project_dir/qml" -name '*.qml' -print0 | xargs -0 qmllint
else
    echo "qmllint is not installed; structural QML checks completed instead."
fi


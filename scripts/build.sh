#!/bin/sh
set -eu

project_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
build_dir="${AR_BUILD_DIR:-$project_dir/build}"
build_type="${AR_BUILD_TYPE:-Debug}"

cmake -S "$project_dir" -B "$build_dir" -GNinja \
    -DCMAKE_BUILD_TYPE="$build_type" \
    -DBUILD_TESTING=ON
cmake --build "$build_dir" --parallel
ctest --test-dir "$build_dir" --output-on-failure


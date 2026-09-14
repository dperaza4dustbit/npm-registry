#!/usr/bin/env bash
set -euo pipefail

: "${MANIFEST_PATH:?MANIFEST_PATH required}"
: "${OUT_DIR:?OUT_DIR required}"
: "${WORK_DIR:?WORK_DIR required}"

VERSION="$(jq -r .version "${MANIFEST_PATH}")"
SOURCE_URL="$(jq -r .source.url "${MANIFEST_PATH}")"
SOURCE_REF="$(jq -r .source.ref "${MANIFEST_PATH}")"
MAIN_TGZ_REL="$(jq -r '.outputs[] | select(.type == "npm-package") | .path' "${MANIFEST_PATH}")"

path_under_out() {
    local rel="$1"
    echo "${OUT_DIR}/${rel#out/}"
}

main_tgz="$(path_under_out "${MAIN_TGZ_REL}")"

assert_tgz_has_member() {
    local tgz="$1" member="$2"
    tar -xOf "${tgz}" "${member}" >/dev/null 2>&1 || {
        echo "[build.entrypoint] ${tgz} missing ${member}" >&2
        tar tf "${tgz}" >&2 || true
        exit 1
    }
}

# Clone source at tag
git clone --depth 1 --branch "${SOURCE_REF}" "${SOURCE_URL}" "${WORK_DIR}/src"
cd "${WORK_DIR}/src"

# Patch package.json version to match expected version
# The upstream tag v3.3.2 has package.json with version 3.1.1
jq --arg version "${VERSION}" '.version = $version' package.json > package.json.tmp
mv package.json.tmp package.json

echo "[build.entrypoint] Patched package.json version to ${VERSION}"

# Pack from source
npm pack --quiet

# Move tarball to output
tarball="$(ls node-fetch-*.tgz)"
mkdir -p "$(dirname "${main_tgz}")"
mv "${tarball}" "${main_tgz}"

echo "[build.entrypoint] Created ${main_tgz}"

# Assert required members
assert_tgz_has_member "${main_tgz}" "package/package.json"
assert_tgz_has_member "${main_tgz}" "package/src/index.js"

# Verify packed version matches manifest
packed_version="$(tar -xOf "${main_tgz}" package/package.json | jq -r .version)"
if [[ "${packed_version}" != "${VERSION}" ]]; then
    echo "[build.entrypoint] ERROR: packed version ${packed_version} != manifest ${VERSION}" >&2
    exit 1
fi

echo "[build.entrypoint] Verified packed version: ${packed_version}"

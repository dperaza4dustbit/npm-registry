#!/usr/bin/env bash
set -euo pipefail

: "${MANIFEST_PATH:?MANIFEST_PATH required}"
: "${OUT_DIR:?OUT_DIR required}"
: "${WORK_DIR:?WORK_DIR required}"

VERSION="$(jq -r .version "${MANIFEST_PATH}")"
SOURCE_URL="$(jq -r .source.url "${MANIFEST_PATH}")"
SOURCE_REF="$(jq -r .source.ref "${MANIFEST_PATH}")"
MAIN_TGZ_REL="$(jq -r '.outputs[] | select(.type == "npm-package") | .path' "${MANIFEST_PATH}")"
main_tgz="${OUT_DIR}/${MAIN_TGZ_REL#out/}"

assert_tgz_has_member() {
    local tgz="$1" member="$2"
    tar -xOf "${tgz}" "${member}" >/dev/null 2>&1 || {
        echo "[build.entrypoint] ${tgz} missing ${member}" >&2
        tar tf "${tgz}" >&2 || true
        exit 1
    }
}

echo "[build.entrypoint] Cloning ${SOURCE_URL} at ${SOURCE_REF}..."
git clone --depth 1 --branch "${SOURCE_REF}" "${SOURCE_URL}" "${WORK_DIR}/src"

cd "${WORK_DIR}/src"

echo "[build.entrypoint] Installing dependencies (ignore scripts)..."
npm install --ignore-scripts

echo "[build.entrypoint] Running build..."
npm run build

echo "[build.entrypoint] Packing..."
npm pack --quiet

packed_tgz="$(ls uuid-*.tgz | head -n1)"
mv "${packed_tgz}" "${main_tgz}"

echo "[build.entrypoint] Verifying tarball..."
assert_tgz_has_member "${main_tgz}" "package/package.json"
assert_tgz_has_member "${main_tgz}" "package/dist-node/index.js"
assert_tgz_has_member "${main_tgz}" "package/dist-node/bin/uuid"

packed_version="$(tar -xOf "${main_tgz}" package/package.json | jq -r .version)"
if [[ "${packed_version}" != "${VERSION}" ]]; then
    echo "[build.entrypoint] Version mismatch: expected ${VERSION}, got ${packed_version}" >&2
    exit 1
fi

echo "[build.entrypoint] Built ${main_tgz}"
ls -lh "${main_tgz}"

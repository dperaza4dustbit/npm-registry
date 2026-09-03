#!/usr/bin/env bash
set -euo pipefail

: "${MANIFEST_PATH:?MANIFEST_PATH required}"
: "${OUT_DIR:?OUT_DIR required}"

VERSION="$(jq -r .version "${MANIFEST_PATH}")"
MAIN_TGZ="$(jq -r '.outputs[] | select(.type == "npm-package") | .path' "${MANIFEST_PATH}")"

path_under_out() {
    local rel="$1"
    echo "${OUT_DIR}/${rel#out/}"
}

MAIN_PATH="$(path_under_out "${MAIN_TGZ}")"

tgz_has_member() {
    local tgz="$1" member="$2"
    tar -xOf "${tgz}" "${member}" >/dev/null 2>&1
}

dump_tgz_listing() {
    local tgz="$1"
    echo "Tarball listing (${tgz}):" >&2
    tar tf "${tgz}" >&2 || true
}

echo "[verify.smoke] Checking main tarball exists..."
[[ -f "${MAIN_PATH}" ]] || {
    echo "[verify.smoke] Main tarball not found: ${MAIN_PATH}" >&2
    exit 1
}

echo "[verify.smoke] Checking required members..."
for member in "package/package.json" "package/dist-node/index.js" "package/dist-node/bin/uuid"; do
    if ! tgz_has_member "${MAIN_PATH}" "${member}"; then
        echo "[verify.smoke] Missing required member: ${member}" >&2
        dump_tgz_listing "${MAIN_PATH}"
        exit 1
    fi
done

echo "[verify.smoke] Verifying package metadata..."
tmpdir="$(mktemp -d)"
tar -xzf "${MAIN_PATH}" -C "${tmpdir}"

pkg_name="$(jq -r .name "${tmpdir}/package/package.json")"
pkg_version="$(jq -r .version "${tmpdir}/package/package.json")"

if [[ "${pkg_name}" != "uuid" ]]; then
    echo "[verify.smoke] Name mismatch: expected uuid, got ${pkg_name}" >&2
    rm -rf "${tmpdir}"
    exit 1
fi

if [[ "${pkg_version}" != "${VERSION}" ]]; then
    echo "[verify.smoke] Version mismatch: expected ${VERSION}, got ${pkg_version}" >&2
    rm -rf "${tmpdir}"
    exit 1
fi

echo "[verify.smoke] Checking main entry syntax..."
if ! node --check "${tmpdir}/package/dist-node/index.js"; then
    echo "[verify.smoke] Syntax check failed for main entry" >&2
    rm -rf "${tmpdir}"
    exit 1
fi

echo "[verify.smoke] Checking CLI entry syntax..."
if ! node --check "${tmpdir}/package/dist-node/bin/uuid"; then
    echo "[verify.smoke] Syntax check failed for CLI entry" >&2
    rm -rf "${tmpdir}"
    exit 1
fi

rm -rf "${tmpdir}"

echo "[verify.smoke] All checks passed"

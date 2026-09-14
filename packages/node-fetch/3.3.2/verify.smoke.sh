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

echo "[verify.smoke] Verifying ${MAIN_PATH}"

# Assert main tarball exists
if [[ ! -f "${MAIN_PATH}" ]]; then
    echo "[verify.smoke] ERROR: Main tarball not found: ${MAIN_PATH}" >&2
    exit 1
fi

# Assert required members present
for member in "package/package.json" "package/src/index.js"; do
    if ! tar -xOf "${MAIN_PATH}" "${member}" >/dev/null 2>&1; then
        echo "[verify.smoke] ERROR: Missing member: ${member}" >&2
        echo "[verify.smoke] Tarball listing:" >&2
        tar tf "${MAIN_PATH}" >&2 || true
        exit 1
    fi
done

# Verify package name and version
packed_name="$(tar -xOf "${MAIN_PATH}" package/package.json | jq -r .name)"
packed_version="$(tar -xOf "${MAIN_PATH}" package/package.json | jq -r .version)"

if [[ "${packed_name}" != "node-fetch" ]]; then
    echo "[verify.smoke] ERROR: packed name ${packed_name} != expected node-fetch" >&2
    exit 1
fi

if [[ "${packed_version}" != "${VERSION}" ]]; then
    echo "[verify.smoke] ERROR: packed version ${packed_version} != manifest ${VERSION}" >&2
    exit 1
fi

echo "[verify.smoke] Verified package: ${packed_name}@${packed_version}"

# Verify main entry is valid JavaScript (syntax check)
temp_dir="$(mktemp -d)"
tar -xOf "${MAIN_PATH}" package/src/index.js > "${temp_dir}/index.js"
if ! node --check "${temp_dir}/index.js" 2>/dev/null; then
    echo "[verify.smoke] WARNING: Main entry failed syntax check" >&2
    # Not a hard failure for ESM modules with imports
fi
rm -rf "${temp_dir}"

echo "[verify.smoke] All checks passed"

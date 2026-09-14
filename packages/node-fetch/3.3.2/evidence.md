# node-fetch@3.3.2 Recipe Evidence

## Package Identity

- **Name:** node-fetch
- **Version:** 3.3.2
- **Tier:** A (Pure JavaScript, no native dependencies)

## Source Verification

- **Repository:** https://github.com/node-fetch/node-fetch.git
- **Tag:** v3.3.2 (lightweight tag)
- **Commit:** 8b3320d2a7c07bce4afc6b2bf6c3bbddda85b01f
- **Registry Tarball Integrity:** sha512-dRB78srN/l6gqWulah9SrxeYnxeddIG30+GOqK/9OlLVyLg3HPnr6SqOWTWOXKRwC2eGYCkZ59NNuSgvSrpgOA==

## Version Mismatch Issue

**Critical Finding:** The upstream git tag `v3.3.2` contains a `package.json` with version `3.1.1` instead of the expected `3.3.2`.

This was confirmed by the fact collector:
- `classification.reason_code`: PACK_NAME_VERSION_MISMATCH
- `classification.reason`: "packed node-fetch@3.1.1 != expected node-fetch@3.3.2"

### Resolution Approach

The recipe applies a **version patch** before packing:

```bash
jq --arg version "${VERSION}" '.version = $version' package.json > package.json.tmp
mv package.json.tmp package.json
```

This ensures the packed tarball has the correct version (3.3.2) that matches the npm registry.

### Why This Requires Human Review

1. **Source Integrity:** The version mismatch suggests the upstream maintainers may have tagged v3.3.2 without updating package.json, which is unusual.
   
2. **Verification Gap:** We cannot cryptographically verify the build provenance beyond tag→commit association.

3. **Patching Approach:** While technically sound, modifying source files before packing should be reviewed to ensure it aligns with Calunga policy.

4. **Alternative Approaches:**
   - Use a different source ref (if one exists with correct version)
   - Contact upstream to fix the tag
   - Use the remediated stream with a fork

## Upstream Package Characteristics

Based on facts collected:

- **Runtime:** ESM (ES Modules)
- **Main Entry:** src/index.js
- **Build Step:** None required (`has_build_step: false`)
- **Lifecycle Scripts:** None (`has_lifecycle_scripts: false`)
- **Native Indicators:** None (`has_native_indicators: false`)
- **Platform Optional Deps:** None (`has_platform_optional_deps: false`)
- **CLI:** No
- **Package Directory:** . (repository root)

## Build Strategy

**Type:** Pack-only with version patch

1. Clone repository at tag v3.3.2
2. Patch package.json version field to 3.3.2
3. Run `npm pack --quiet`
4. Verify packed tarball contains expected members and version

## Factory Contract

- **Install Command:** Not needed (pack-only)
- **Node Environment:** production (default)
- **Blockers:** None
- **Package Directory:** . (root)

## Smoke Test Coverage

- Main tarball exists at expected path
- Required members present: `package/package.json`, `package/src/index.js`
- Packed name matches "node-fetch"
- Packed version matches manifest version (3.3.2)
- Main entry passes Node.js syntax check (with ESM tolerance)

## Could Not Verify

1. npm provenance attestation present but not cryptographically verified
2. Source association is tag_only (tag→commit only); tarball build provenance not verified

## Recommendation

**Status:** needs_human

The recipe is technically complete and should produce a valid tarball, but the version mismatch warrants human review before merging to the main npm-registry repository.
Kitchen will push this recipe to a fork and create a manual PR for review.

Assisted-by: Claude

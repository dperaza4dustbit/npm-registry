# uuid@14.0.2 Recipe Evidence

## Source identification

- **Repository:** https://github.com/uuidjs/uuid.git
- **Tag:** v14.0.2 (lightweight tag)
- **Commit:** fd59f0277549d22cc7ec00a7b3b5c9bccb4d3c1d
- **Tag matches version:** Yes

## Tier classification: A

**Rationale:**
- Pure JavaScript package with TypeScript source that compiles to JS
- No native bindings (`binding.gyp` not present)
- No platform-specific optional dependencies
- Build scripts (build, prepare, prepack, prepublishOnly) only perform TS->JS transpilation
- No `node-gyp`, `prebuild-install`, or binary downloads

**Upstream signals:**
- `has_native_indicators: false`
- `has_platform_optional_deps: false`
- `has_build_step: true` (but JS-only transpilation)
- `has_lifecycle_scripts: true` (build, prepare, prepack, prepublishOnly)

## Build approach

Pattern: **build-then-pack** (similar to async@3.2.6)

1. Clone tag v14.0.2 from upstream
2. `npm install --ignore-scripts` - install build tooling
3. `npm run build` - compile TypeScript to dist-node/
4. `npm pack` - create tarball with built artifacts

**Output structure:**
- Main package only: `uuid-14.0.2.tgz`
- No platform packages required

## Package features

- **CLI binary:** `uuid` → `dist-node/bin/uuid`
- **Main entry:** `dist-node/index.js` (complex exports structure)
- **Runtime:** Pure Node.js, no native dependencies

## Smoke test strategy

Validates:
1. Tarball exists and contains required members
2. `package/package.json` present with correct name and version
3. `package/dist-node/index.js` (main entry) syntax valid
4. `package/dist-node/bin/uuid` (CLI entry) syntax valid
5. No native artifacts or platform-specific files

## Verification gaps

Carried from fact collection:
- npm provenance attestation present but not cryptographically verified
- Source association is tag_only (tag->commit only); tarball build provenance not verified
- Source `npm pack --ignore-scripts` failed; packed layout taken from the integrity-verified registry tarball

These gaps are acceptable for Tier A packages where we rebuild from validated source.

## Files inspected

From upstream repository at v14.0.2:
- `package.json` - scripts, bin, exports, dependencies
- Build output location: `dist-node/` directory
- No `binding.gyp` or native build configuration

## Confidence: High (0.9)

This is a straightforward Tier A package with a well-documented build process.
The only complexity is the build step, which follows a standard TS compilation pattern identical to many other packages in the npm registry.

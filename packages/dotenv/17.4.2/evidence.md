# dotenv@17.4.2 Recipe Evidence

## Package Identity

- **Name:** dotenv
- **Version:** 17.4.2
- **Registry:** https://registry.npmjs.org
- **Upstream:** https://github.com/motdotla/dotenv

## Source Resolution

- **Repository:** https://github.com/motdotla/dotenv.git
- **Tag:** v17.4.2 (annotated)
- **Commit SHA:** f116f70310abab44fbfddbaeb833698b5bf84a9b
- **Package Directory:** `.` (repository root)
- **Resolution Method:** tag_only (tag->commit verification)

## Tier Classification: A

**Rationale:** Pure JavaScript package with no build step, no native dependencies, and no platform-specific optional dependencies.

### Supporting Evidence

1. **No build step required** (`facts.upstream.has_build_step: false`)
2. **No native indicators** (`facts.upstream.has_native_indicators: false`)
3. **No platform optional dependencies** (`facts.upstream.has_platform_optional_deps: false`)
4. **No lifecycle scripts** (`facts.upstream.has_lifecycle_scripts: false`)
5. **No binding.gyp or native addons**

## Build Approach

**Pattern:** Pack-only (Tier A minimal)

1. Clone repository at commit `f116f70310abab44fbfddbaeb833698b5bf84a9b`
2. Verify commit SHA matches expected value
3. Run `npm pack --quiet --ignore-scripts` from repository root
4. Move packed tarball to output directory
5. Verify tarball contents and version

### Key Files Verified

- `package/package.json` - Package metadata
- `package/lib/main.js` - Main entry point
- `package/config.js` - Configuration entry point

## Factory Requirements

- **Node.js:** ✓ (npm-builder provides Node 20 LTS)
- **Git:** ✓ (for source checkout)
- **npm:** ✓ (for packing)
- **Build tools:** Not required (pure JS)
- **Special dependencies:** None

## Smoke Test Strategy

1. Verify tarball exists and contains required members
2. Validate package name and version in tarball metadata
3. Install package locally (no registry access)
4. Test core API (`dotenv.config`, `dotenv.parse`)
5. Syntax check on main entry point (`node --check`)

## Upstream Characteristics

- **Main entry:** Complex exports (conditional/multiple entry points)
- **CLI:** No binary provided
- **Dependencies:** Minimal runtime dependencies
- **Install scripts:** None

## Confidence Assessment

**Status:** drafted (production-ready)

**Confidence:** 0.95

**Justification:**
- Clear Tier A classification with no ambiguity
- Standard pack-only pattern matching canonical lodash example
- All factory facts available with no blockers
- Well-understood package structure from upstream
- Simple pure-JS package with stable API

## Verification Gaps

The following could not be cryptographically verified:

1. npm provenance attestation present but not cryptographically verified
2. Source association is tag_only (tag->commit only); tarball build provenance not verified

These gaps are documented in the result JSON per agent requirements.

## Notes

- Recipe follows the pack-only pattern from `packages/lodash/4.18.1/`
- No `tl-install.js` required (Tier A)
- Shell scripts require executable permissions (chmod +x)

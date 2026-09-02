# zod@4.5.4 Recipe Evidence

## Source Information

- **Repository**: https://github.com/colinhacks/zod.git
- **Tag**: v4.5.4 (lightweight tag)
- **Commit**: e8e206fa33ac5fe7ce20a2beb12d57b1cb3df653
- **Registry tarball**: https://registry.npmjs.org/zod/-/zod-4.5.4.tgz
- **Integrity**: sha512-sC95tT5iHHH9gtpj6A81kh+NEaRAUFN+qlUPDUbRfOMvNf5QCBqsb3WgvnpVtK5Y+4UfA6KqufotuTvMGiTlsA==

## Tier Classification: A

### Rationale

Zod is a TypeScript-first schema validation library that:
1. Has build lifecycle scripts (build, prepublishOnly) to compile TypeScript to JavaScript
2. Has **no native indicators** (no binding.gyp, no .node files, no prebuild-install)
3. Has **no platform-specific optional dependencies**
4. Produces pure JavaScript output from TypeScript source

This matches **Tier A** requirements: pure JS artifact from git with a build step.

### Build Process

The upstream build process:
1. TypeScript compilation via `npm run build`
2. Generates compiled JavaScript (likely in `lib/` directory based on common TS patterns)
3. Package uses conditional exports (main_entry_status: "complex_exports")

### Files Inspected

Based on facts collector analysis:
- `package.json` - contains build and prepublishOnly scripts
- TypeScript source files requiring compilation
- No native compilation indicators

## Build Strategy

**Pattern**: Tier A build-then-pack (similar to async@3.2.6)

1. Clone repository at commit `e8e206fa33ac5fe7ce20a2beb12d57b1cb3df653`
2. Verify commit SHA matches expected
3. `npm install --ignore-scripts` - install dependencies without running lifecycle scripts
4. `npm run build` - compile TypeScript to JavaScript
5. `npm pack` - create tarball from built tree
6. Verify version matches manifest

## Smoke Test Strategy

1. Verify tarball contains `package/package.json` and `package/README.md`
2. Verify package name and version match manifest
3. Install tarball locally with `--ignore-scripts`
4. Require the module and validate zod's core API:
   - Check for `z.string` function
   - Test basic string parsing
5. Confirm no runtime errors

## Verification Gaps (carried from facts)

1. npm provenance attestation present but not cryptographically verified
2. Source association is tag_only (tag→commit only); tarball build provenance not verified

These gaps are inherent to tag-based resolution and do not affect the recipe's ability to build zod from verified source.

## Confidence: 85%

High confidence based on:
- Clear Tier A classification (no native components)
- Standard TypeScript build pattern
- Well-established upstream repository
- Successful fact collection and artifact verification

Potential concerns:
- Complex exports field (not verified actual entry point structure)
- Build output directory not directly inspected (assumed standard lib/ pattern)

However, the smoke test will validate the actual module loads and basic API works, catching any structural issues.

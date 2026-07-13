# npm-registry Tekton

## Pipeline

`build-pipeline.yaml` defines pipeline **`build-npm`** (Phase 1 — PR build to Quay OCI).

```text
init → clone-repository → lint-manifests → identify-packages → build-npm-package
```

Built tarballs are pushed as an OCI artifact to
`$(output-image).npm` (e.g. `.../calunga-npm-registry-main:on-pr-<sha>.npm`, 5d TTL).
Pipeline `IMAGE_URL` / `IMAGE_DIGEST` come from the trusted **`build-npm-package`**
task (same pattern as Python `build-wheels`), not an inline pipeline step.

`calunga-npm-registry-main-pull-request.yaml` triggers on PRs to `main`.

## Bootstrap checklist

Konflux **Application / Component / ECP / integration test** for `calunga-npm-registry-main`
are GitOps-managed in
[`konflux-release-data`](../../konflux-release-data/tenants-config/cluster/kflux-prd-rh03/tenants/calunga-tenant/npm/).

Plumbing (`npm-builder`, `task-build-npm-package`) stays UI-managed under `calunga-v2`.

1. Merge `konflux-release-data` PR; wait for Argo sync to `calunga-tenant`.
2. If you previously created `calunga-npm-registry-main` in the UI, remove the duplicate.
3. **Task bundle digest** — after `task-build-npm-package` is on Quay (UI component), update
   `task-build-npm-package-bundle` in this PipelineRun.
4. **Builder image** — keep `builder-image` in the PipelineRun in sync with Quay `npm-builder`.

## Viewing OCI artifacts

PR builds push tarballs to a **private** Quay repo (`calunga-npm-registry-main`).
Do **not** expect to browse it at `quay.io/redhat-user-workloads/calunga-tenant/calunga-npm-registry-main`
unless a Quay admin has granted your user Read on that repo.

This repo is GitOps-managed (`ImageRepository` in `konflux-release-data`), unlike plumbing
components such as `task-build-npm-package` (UI-created under `calunga-v2`), where the creator
is often on the Quay repo ACL automatically.

**Inspect builds in Konflux UI:**

1. Application / Component **`calunga-npm-registry-main`**
2. Open the PipelineRun → **Results** → `IMAGE_URL`, `IMAGE_DIGEST`
3. For local pull: Component page → **Registry login information** → use the Konflux image
   proxy login (not a direct `quay.io` URL). See
   [Accessing private image repositories](https://konflux-ci.dev/docs/building/accessing-private-images/).

CI already runs each recipe's `verify.smoke.sh` before push; manual pull is optional audit.

## Pulp Stage (deferred)

The build task still supports optional `publish-to-pulp` when a stage npm repo exists.
No ExternalSecret or Vault wiring is required for Phase 1 Quay-only output.

## No packages in this PR

With no changes under `packages/`, `identify-packages` returns `no-packages` and
`build-npm-package` pushes an empty `.npm` OCI artifact (`.keep` only) and emits
`IMAGE_URL` / `IMAGE_DIGEST` for Snapshot / EC.

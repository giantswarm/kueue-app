# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-05-18

### Changed

- Bump upstream Kueue chart from `v0.14.1` to `v0.17.3`.
- Default `enableCertManager` to `true` so Giant Swarm clusters use the
  cert-manager that ships in the standard workload-cluster bundle without any
  user configuration. Set to `false` on clusters without cert-manager.
- Set `internalCertManagement.enable: false` automatically when
  `enableCertManager: true` so the visibility server consumes the
  cert-manager-issued certs instead of trying to self-sign into the read-only
  secret mount (refs kubernetes-sigs/kueue#11133).
- Switch `managerConfig` to `config.kueue.x-k8s.io/v1beta2`.
- Add `ray.io/rayservice` to the default integration frameworks.
- Add `certManager.issuerRef` to allow reusing an existing cert-manager `Issuer`/`ClusterIssuer`.
- Add `controllerManager.manager.logLevel` for zap log verbosity.
- Add KueueViz backend `auth` (TokenReview mode), resource/securityContext defaults, and `ingress.enabled` toggle on both backend and frontend.
- KueueViz backend now defaults `KUEUEVIZ_ALLOWED_ORIGINS` to `https://frontend.kueueviz.local`.

### Added

- New RBAC roles for leaderworkerset, rayservice, sparkapplication, clusterprofiles editor/viewer.
- New `visibility/apiservice_v1beta2.yaml` template.
- New `certmanager/issuer.yaml` and `kueueviz/frontend-configmap.yaml` templates.
- Pinned the upstream ref in `vendir.yml` to a specific tag for reproducible syncs.

## [0.1.1] - 2026-02-04

### Changed

- Update icon URL in chart annotations

## [0.1.1] - 2026-02-02

### Changed

- Updated Chart annotations for OCI repositories.

## [0.1.0] - 2025-10-16

### Added

- Upstream version
- changed: `app.giantswarm.io` label group was changed to `application.giantswarm.io`

[Unreleased]: https://github.com/giantswarm/kueue-app/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/giantswarm/kueue-app/compare/v0.2.0...v0.2.0
[0.2.0]: https://github.com/giantswarm/kueue-app/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/giantswarm/kueue-app/compare/v0.1.1...v0.1.1
[0.1.1]: https://github.com/giantswarm/kueue-app/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/kueue-app/releases/tag/v0.1.0

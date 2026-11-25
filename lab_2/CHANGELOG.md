# Changelog

## 1.0.1 (2) — 2026-11-25

- About shows the version as `1.0.1 (2)` with the build mode, environment and hosts.
- Release built with `--obfuscate --split-debug-info`; symbols archived for this version.

## 1.0.0 (1) — 2026-11-25

- Countries catalogue from REST Countries: search by name, region filter, offline cache with a stale banner, detail with Google Maps link.
- My trips on MockAPI.io: create, edit, delete with confirmation; form with validators, date pickers and unsaved-changes guard.
- Sign in with the token in secure storage, settings (dark mode, default region, profile photo) that survive a restart.
- `USE_FAKES=true` runs the whole app offline.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.7.1...dart_husky-v1.8.0) (2026-08-21)


### Features

* upgrade flutter sdk to 3.47.1 ([#20](https://github.com/moulibheemaneti/dart_husky/issues/20)) ([10ffb2f](https://github.com/moulibheemaneti/dart_husky/commit/10ffb2faa9eab440dc4d4a29e2e0751e53bd0255))

## [1.7.1](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.7.0...dart_husky-v1.7.1) (2026-07-18)


### Bug Fixes

* **ci:** update renovate github action to v46.1.19 ([#17](https://github.com/moulibheemaneti/dart_husky/issues/17)) ([609219b](https://github.com/moulibheemaneti/dart_husky/commit/609219b046469cf902a3a34e645aa4b404b5a629))

## [1.7.0](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.6.0...dart_husky-v1.7.0) (2026-07-14)


### Features

* upgrade flutter sdk to 3.44.6 ([#15](https://github.com/moulibheemaneti/dart_husky/issues/15)) ([febd013](https://github.com/moulibheemaneti/dart_husky/commit/febd013963a177326b9b717a08883b4999830534))

## [1.6.0](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.5.0...dart_husky-v1.6.0) (2026-06-25)


### Features

* upgrade flutter sdk to 3.44.4 ([#13](https://github.com/moulibheemaneti/dart_husky/issues/13)) ([e082dd5](https://github.com/moulibheemaneti/dart_husky/commit/e082dd56ff05b162139057d957ca2ef265c1131b))

## [1.5.0](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.4.1...dart_husky-v1.5.0) (2026-06-23)


### Features

* add melos preset for running tests in monorepo workspaces ([#11](https://github.com/moulibheemaneti/dart_husky/issues/11)) ([568752d](https://github.com/moulibheemaneti/dart_husky/commit/568752d6674815f10783c9e000bc11008fd3a5a4))
  - **Melos Preset**: Added `melos` preset for shell commands. When `preset: melos` is set, dart_husky runs tests in a melos workspace via `melos exec`. The `staged_only` flag controls scope: `true` runs tests only in packages with staged files; `false` runs all packages. Uses `melos list --json` for package discovery (works with both `melos.yaml` and `melos:` in `pubspec.yaml`). Auto-detects `fvm flutter test`, `flutter test`, or `dart test`.

## [1.4.1](https://github.com/moulibheemaneti/dart_husky/compare/dart_husky-v1.4.0...dart_husky-v1.4.1) (2026-06-21)


### Miscellaneous

* update flutter version to 3.44.2 ([#9](https://github.com/moulibheemaneti/dart_husky/issues/9)) ([b1e369c](https://github.com/moulibheemaneti/dart_husky/commit/b1e369c8d4ef1948b313208ab9c8188da2141393))

## [1.4.0](https://github.com/moulibheemaneti/dart_husky/compare/v1.2.2...dart_husky-v1.4.0) (2026-06-21)


### Bug Fixes

* correct package name from adaptive_navbar to dart_husky in ci config ([d8e1e14](https://github.com/moulibheemaneti/dart_husky/commit/d8e1e1487c0f54aec075f1bf799c65df64650647))


### CI

* automate publishing with release-please and renovate ([#6](https://github.com/moulibheemaneti/dart_husky/issues/6)) ([b26b4e8](https://github.com/moulibheemaneti/dart_husky/commit/b26b4e8aef35825e0579bea7eb2aa6491b218e12))

## [1.3.0](https://github.com/moulibheemaneti/dart_husky/compare/adaptive_navbar-v1.2.2...adaptive_navbar-v1.3.0) (2026-06-21)

### CI

* automate publishing with release-please and renovate ([#6](https://github.com/moulibheemaneti/dart_husky/issues/6)) ([b26b4e8](https://github.com/moulibheemaneti/dart_husky/commit/b26b4e8aef35825e0579bea7eb2aa6491b218e12))

## [1.2.2] - 2026-06-06

### Fixed
- **SDK Constraint**: Lowered the minimum SDK constraint from `>=3.12.0` to `>=3.0.0`, unblocking usage on current Dart stable releases ([#4](https://github.com/moulibheemaneti/dart_husky/issues/4)). Updated the README badge to match.

### Chore
- **Package Metadata**: Added `topics`, `homepage`, `issue_tracker`, and `screenshots` fields to `pubspec.yaml` for improved pub.dev discoverability.
- **Contributing Guide**: Added `CONTRIBUTING.md` documenting setup commands, active git hooks, and commit conventions.
- **Issue Templates**: Added YAML-based GitHub issue templates for bug reports and feature requests, plus a `config.yml` routing security reports to GitHub Security Advisories.
- **Pull Request Template**: Added `.github/pull_request_template.md` with a standard checklist.
- **Security Policy**: Added `SECURITY.md` describing the supported versions and private vulnerability reporting process.

## [1.2.1] - 2026-05-30

### CI
- **Dependabot Integration**: Configured Dependabot for weekly updates of packages within the `pub` ecosystem.
- **PR Title Validation**: Setup GitHub Actions workflow to validate PR titles against Conventional Commit patterns.

## [1.2.0] - 2026-05-30

### Added
- **Glob Pattern Filtering**: Integrated `glob` package to filter command execution. Hooks can be configured with a `glob` pattern (e.g., `glob: '**/*.dart'`), skipping execution if no staged files match the glob sequence.
- **Lowercase Commit Message Check**: Added the `only_small_case` configuration flag (enabled by default) to enforce fully lowercase formats for commit messages under the conventional preset.
- **Lazy Staged File Querying**: Optimized performance in `HookRunner` by retrieving staged files only when a command with `glob` pattern or `staged_only: true` is configured.

## [1.1.0] - 2026-05-30

### Added
- **Staged-Only Mode**: Added support for running hook commands on git staged files only. Configurable globally under `dart_husky: staged_only: true/false` or overridden at individual command levels. If files are staged, they are appended to the command execution; if no files are staged, the command is skipped.
- **Custom Commit-Msg Types**: Added `append` and `override` configuration to the `commit-msg` preset conventional validator, allowing users to append custom commit types or completely override the built-in list.
- **Verbose Output Toggle**: Introduced global `verbose` setting to enable/disable detailed execution logs.
- **Git Utilities**: Added `GitUtils` to retrieve currently staged files using `git diff --cached --name-only` dynamically.

## [1.0.1] - 2026-05-30

### Added
- **Example Usage**: Introduced a package usage example illustrating the declarative `dart_husky.yaml` setup.
- **New lint prefix support**: `bump` prefix is added to commit message validator.

### Documented
- **API Documentation**: Added comprehensive, high-quality Dartdoc comments to all public models, config configurations, validators, and classes to elevate package API clarity and maximize the pub.dev score.

## [1.0.0] - 2026-05-30

### Added
- **Pure-Dart CLI Tooling**: Lightweight, zero-dependency Git hooks manager designed specifically for Dart and Flutter projects.
- **Robust Hook Installer**: Installs custom lightweight shell scripts into `.git/hooks/` that automatically detect and support both global `dart` and `fvm dart` environments.
- **Declarative YAML Configuration**: Set up all your project's hook commands inside a single `dart_husky.yaml` file.
- **Sequential & Parallel Command Execution**: Speed up your development workflow by executing hook commands in parallel (`parallel: true`) or sequentially (default).
- **Built-in Conventional Commits Preset**: Out-of-the-box support for validating commit messages against the Conventional Commits specification (supports types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`).
- **Comprehensive CLI Interface**:
  - `dart run dart_husky install` — Installs or syncs all hooks configured in `dart_husky.yaml`.
  - `dart run dart_husky uninstall` — Safely removes all `dart_husky` managed Git hooks.
  - `dart run dart_husky run <hook-name>` — Manually run/test hook commands.
  - `dart run dart_husky list` — Display all configured hooks and their installation status.
- **Supported Hooks**: Native support for `pre-commit`, `commit-msg`, `pre-push`, `post-checkout`, and `pre-merge-commit`.
- **Platform Support**: Verified compatibility with macOS environments.

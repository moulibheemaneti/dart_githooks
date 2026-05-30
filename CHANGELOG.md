# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-05-30

### Addeds
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

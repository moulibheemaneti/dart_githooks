# Contributing to dart_husky

Thanks for taking the time to contribute! Please read this guide before opening an issue or pull request.

## Getting started

**Prerequisites:** Dart SDK ≥ 3.0.0 (or Flutter, or [FVM](https://fvm.app/)).

```sh
git clone https://github.com/moulibheemaneti/dart_husky.git
cd dart_husky
dart pub get
dart run dart_husky install   # activates the local git hooks
```

After `dart run dart_husky install` the following hooks run automatically on this repo:

| Hook | Commands |
|------|----------|
| `pre-commit` | `dart format --set-exit-if-changed .` (dart files only), `dart analyze` (dart files only), `dart test` |
| `commit-msg` | Conventional Commits validation (allowed types below) |

## Commit convention

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <subject starting with a lowercase letter>
```

Allowed types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`, `wip`, `release`.

Examples:

```
feat: add pre-push hook support
fix: handle missing dart_husky.yaml gracefully
docs: update staged-only mode example
```

## Running tests

```sh
dart test
```

## Making a change

1. Fork the repo and create a branch from `main`.
2. Make your changes and add or update tests as needed.
3. Run `dart format .` and `dart analyze` — both must pass cleanly.
4. Run `dart test` — all tests must pass.
5. Update `CHANGELOG.md` under the `[Unreleased]` section.
6. Open a pull request with a Conventional Commits title.

## Reporting issues

Use the issue templates — they ask for the specific information needed to reproduce or triage your report quickly. For security vulnerabilities, see [SECURITY.md](SECURITY.md).

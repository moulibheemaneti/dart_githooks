<div align="center">

<img src="doc/assets/logo.png" alt="dart_husky" width="80" />

# dart_husky

**Git hook manager for Dart & Flutter — no binaries, no fuss.**

[![pub version](https://img.shields.io/pub/v/dart_husky.svg?style=flat-square&color=0175C2&labelColor=1a1a2e)](https://pub.dev/packages/dart_husky)
[![pub points](https://img.shields.io/pub/points/dart_husky?style=flat-square&color=0175C2&labelColor=1a1a2e)](https://pub.dev/packages/dart_husky/score)
[![license](https://img.shields.io/badge/license-MIT-0175C2?style=flat-square&labelColor=1a1a2e)](LICENSE)
[![dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-0175C2?style=flat-square&labelColor=1a1a2e)](https://dart.dev)

Pure Dart. Zero external dependencies. Works with Flutter, FVM, or bare Dart SDK.  
Inspired by [husky](https://github.com/typicode/husky) and [lefthook](https://github.com/evilmartians/lefthook).

</div>

---

## Why dart_husky?

Most git hook tools require installing a separate binary (Go, Node.js, etc.). `dart_husky` is **pure Dart** — if your team has Dart, they have everything they need.

```
✦ Pure Dart — no Go, no Node, no extra installs
✦ YAML config — familiar, readable, version-controlled
✦ Built-in conventional commits validation
✦ Sequential or parallel command execution
✦ Staged-only mode — run commands on staged files only
✦ Glob filtering — skip commands when no matching files are staged
✦ Works with dart, flutter, and fvm
✦ Melos workspace support — run tests at package level via preset: melos
✦ Lowercase enforcement — optionally force lowercase commit messages
```

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  dart_husky: ^1.2.1
```

Install dependencies and set up hooks:

```sh
dart pub get
dart run dart_husky install
```

That's it. Your hooks are live.

---

## Configuration

Create `dart_husky.yaml` in your project root:

```yaml
dart_husky:
  verbose: true       # print detailed output (default: true)
  staged_only: false  # run on staged files only (default: false)

pre-commit:
  commands:
    format:
      run: dart format --set-exit-if-changed .
    analyze:
      run: dart analyze

commit-msg:
  commands:
    conventional:
      preset: conventional
```

---

## Supported Hooks

| Hook | Triggered when... |
|---|---|
| `pre-commit` | Before a commit is created |
| `commit-msg` | After you write a commit message |
| `pre-push` | Before pushing to remote |
| `post-checkout` | After switching branches |
| `pre-merge-commit` | Before a merge commit |

---

## Commands

```sh
# Install hooks defined in dart_husky.yaml
dart run dart_husky install

# Remove all installed hooks
dart run dart_husky uninstall

# Manually trigger a hook
dart run dart_husky run pre-commit

# List configured hooks and install status
dart run dart_husky list
```

---

## Conventional Commits

Enable built-in conventional commits validation with one line:

```yaml
commit-msg:
  commands:
    conventional:
      preset: conventional
```

Valid format:

```
<type>(<optional scope>): <subject>
```

| Type | When to use |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `chore` | Maintenance, deps, tooling |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `refactor` | Code change, no feature or fix |
| `test` | Adding or fixing tests |
| `build` | Build system changes |
| `ci` | CI configuration |
| `perf` | Performance improvement |
| `revert` | Revert a previous commit |

**Examples:**

```sh
git commit -m "feat(auth): add login screen"         ✅
git commit -m "fix: resolve null pointer exception"  ✅
git commit -m "feat!: breaking api change"           ✅
git commit -m "updated stuff"                        ❌
```

### Custom Commit Types

Append custom types on top of the built-in list:

```yaml
commit-msg:
  commands:
    conventional:
      preset: conventional
      types:
        append: [wip, release]
```

Or completely override the built-in types:

```yaml
commit-msg:
  commands:
    conventional:
      preset: conventional
      types:
        override: [feat, fix, hotfix, release]
```

---

### Lowercase Enforcement

Force all commit messages to be lowercase (default: `true`):

```yaml
commit-msg:
  commands:
    conventional:
      preset: conventional
      only_small_case: true  # default
```

To allow mixed case:

```yaml
commit-msg:
  commands:
    conventional:
      preset: conventional
      only_small_case: false
```

Applies to any preset, not just conventional commits.

## Staged-Only Mode

Run commands only on staged files instead of the entire project. Faster hooks for large codebases.

Enable globally for all commands:

```yaml
dart_husky:
  staged_only: true

pre-commit:
  commands:
    format:
      run: dart format --set-exit-if-changed .
    analyze:
      run: dart analyze
    test:
      run: dart test
      staged_only: false  # override — always run full test suite
```

Command-level `staged_only` always overrides the global setting. If no staged files are found, the command is skipped automatically.

---

## Melos Preset

If your project uses [melos](https://melos.invertase.dev/) for monorepo management, you can replace a `run` command with the `melos` preset to execute tests at the package level:

```yaml
pre-commit:
  commands:
    test:
      preset: melos              # no `run` field — preset handles everything
      staged_only: true          # optional — only packages with staged files
```

When `preset: melos` is set, the `run` field must be omitted (the parser rejects both).

### How it works

1. **Package discovery** — Runs `melos list --json --relative` to find all workspace packages. Supports both `melos.yaml` and `melos:` config key in `pubspec.yaml`.
2. **Test command auto-detection** — Picks the first available: `fvm flutter test` > `flutter test` > `dart test`.
3. **Execution** — Uses `melos exec` to run tests. The `staged_only` flag controls scope:

   | `staged_only` | Behavior |
   |---|---|
   | `true` | Runs tests only in packages containing staged files (`melos exec --scope=pkg1 --scope=pkg2 -- ...`) |
   | `false` | Runs tests in **all** packages (`melos exec -- ...`) |

Command-level `staged_only` overrides the global `dart_husky.staged_only` setting, just like regular `run` commands.

---

## Glob Filtering

Skip commands entirely when no staged files match a pattern:

```yaml
pre-commit:
  commands:
    format:
      run: dart format --set-exit-if-changed .
      glob: '**/*.dart'   # skip if no .dart files are staged
    analyze:
      run: dart analyze
      glob: '**/*.dart'
```

If you only staged `README.md`, both `format` and `analyze` are skipped — no unnecessary work.

---

## Parallel Execution

Speed up slow hooks by running commands simultaneously:

```yaml
pre-commit:
  parallel: true
  commands:
    format:
      run: dart format --set-exit-if-changed .
    analyze:
      run: dart analyze
    test:
      run: dart test
```

---

## How It Works

```
you run: git commit
         └── git checks .git/hooks/pre-commit
                  └── dart run dart_husky run pre-commit
                           └── reads dart_husky.yaml
                                    └── runs each command
                                             ├── all pass → commit created ✅
                                             └── any fail → commit blocked ❌
```

`dart_husky install` writes a small shell script into `.git/hooks/` for each configured hook. The script detects whether to use `dart` or `fvm dart` automatically.

---

## Contributing

Contributions are welcome! Please make sure your commits follow the conventional commits format — `dart_husky` will enforce it. 😄

---

<div align="center">

Made with 🎯 by [@moulibheemaneti](https://github.com/moulibheemaneti)  
MIT License

</div>

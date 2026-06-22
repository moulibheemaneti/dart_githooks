/// Represents the entire dart_husky.yaml config file
class GitHooksConfig {
  /// Global dart_husky settings
  final DartHuskyConfig globalConfig;

  /// Map of hook types to their configurations
  final Map<HookType, HookConfig> hooks;

  /// Creates a [GitHooksConfig] with the given hooks
  const GitHooksConfig({
    this.globalConfig = const DartHuskyConfig(),
    required this.hooks,
  });
}

/// Global dart_husky configuration — defined under the `dart_husky:` key
class DartHuskyConfig {
  /// Whether to print verbose output (default: true)
  final bool verbose;

  /// Whether to run commands on staged files only (default: false)
  final bool stagedOnly;

  /// Creates a [DartHuskyConfig] with the given settings
  const DartHuskyConfig({this.verbose = true, this.stagedOnly = false});
}

/// All supported git hook types
enum HookType {
  /// Runs before a commit is created
  preCommit('pre-commit'),

  /// Validates the commit message format
  commitMsg('commit-msg'),

  /// Runs before pushing to remote
  prePush('pre-push'),

  /// Runs after switching branches
  postCheckout('post-checkout'),

  /// Runs before a merge commit
  preMergeCommit('pre-merge-commit');

  /// The filename used in .git/hooks/
  final String scriptName;

  const HookType(this.scriptName);

  /// Returns the [HookType] matching the given string, or null if not found
  static HookType? fromString(String value) {
    for (final type in HookType.values) {
      if (type.scriptName == value) return type;
    }
    return null;
  }
}

/// Represents one hook block in the config (e.g. pre-commit:)
class HookConfig {
  /// Whether to run commands in parallel (default: false)
  final bool parallel;

  /// Named shell commands to execute for this hook
  final Map<String, CommandConfig> commands;

  /// Named commit-msg commands — only used for [HookType.commitMsg]
  final Map<String, CommitMsgCommandConfig> msgCommands;

  /// Creates a [HookConfig] with the given commands
  const HookConfig({
    this.parallel = false,
    this.commands = const {},
    this.msgCommands = const {},
  });
}

/// Represents one named shell command inside a hook
class CommandConfig {
  /// The shell command to execute — optional if [preset] is set
  final String? run;

  /// Optional glob pattern — only run if matching files are staged
  final String? glob;

  /// Override global staged_only for this command specifically
  /// If null, falls back to global dart_husky.staged_only
  final bool? stagedOnly;

  /// Named preset (e.g. 'melos') — replaces [run] when set
  /// Exactly one of [run] or [preset] must be provided
  final String? preset;

  /// Creates a [CommandConfig] with the given run command or preset
  const CommandConfig({this.run, this.glob, this.stagedOnly, this.preset});
}

/// Specific to commit-msg hook — uses a preset instead of a shell command
class CommitMsgCommandConfig {
  /// The validation preset to use (e.g. 'conventional')
  final String preset;

  /// Custom types to append to the built-in preset types
  final List<String> appendTypes;

  /// Custom types to override the built-in preset types entirely
  final List<String> overrideTypes;

  /// Whether to enforce lowercase commit messages (default: true)
  final bool onlySmallCase;

  /// Creates a [CommitMsgCommandConfig] with the given preset
  const CommitMsgCommandConfig({
    required this.preset,
    this.appendTypes = const [],
    this.overrideTypes = const [],
    this.onlySmallCase = true,
  });
}

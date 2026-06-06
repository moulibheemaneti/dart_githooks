# Security Policy

## Supported Versions

Only the latest minor release of `dart_husky` receives security fixes.

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| < 1.2   | :x:                |

## Reporting a Vulnerability

`dart_husky` is a local CLI tool that reads a YAML config file and executes
shell commands as Git hooks — it does not make network requests, handle
authentication, or store user data. That said, if you believe you've found a
vulnerability (for example, a path-traversal issue, unsafe shell execution, or
a problem in a transitive dependency exposed via this package), please
**do not open a public issue**.

Report it privately via GitHub Security Advisories:

➡️ [Report a vulnerability](https://github.com/moulibheemaneti/dart_husky/security/advisories/new)

You can expect:
- An acknowledgement within **7–14 days**.
- A status update within **30–45 days**.
- If accepted, a fix will land in the next patch release and you'll be credited in the release notes (unless you prefer to remain anonymous).
- If declined, you'll receive an explanation of why.

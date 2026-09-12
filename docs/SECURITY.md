# Security

Mutations are allowlisted, need explicit `USF_CONFIRM=YES`, log an audit event, and are constrained to module-owned state. The WebUI cannot run a shell command. Inputs never become paths outside the module state directory. Logs avoid app files, URIs, and user-data enumeration.

SHA-256 establishes artifact integrity only. A cryptographic signature binds an artifact to a signing identity; a trusted GitHub release is a separate distribution trust decision.

Dependency automation trusts only Dependabot-origin PRs from this repository. It does not execute PR code with write tokens, enables no automatic merge, and performs privileged-path policy checks. Existing first-party GitHub Actions use maintained major tags; future third-party actions require source review and immutable commit-SHA pinning. Scanner availability is explicitly reported rather than assumed.

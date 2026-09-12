# Threat model

Assets: user storage, app data, module configuration, release artifacts, and root authority. Trust boundaries: WebUI-to-bridge, bridge-to-engine, module-state filesystem, and release metadata-to-artifact.

Threats include malicious WebUI input, path traversal, tampered releases, stale diagnostics, and a compromised root process. Mitigations are fixed operation IDs, module-owned path limits, confirmation/preview/audit requirements, checksum validation, no listener, no arbitrary shell, and safe refusal for unknown/OEM-specific actions. Root compromise remains outside this module's ability to contain.

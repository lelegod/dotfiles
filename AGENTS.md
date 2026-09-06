# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "none"` in `configuration.nix` is intentional. Homebrew packages installed by hand, outside the Nix config, must survive a rebuild. Do not "tighten" this to `zap` or `uninstall` in the name of reproducibility: that deletes every brew and cask not listed in `configuration.nix`, including ones that were installed deliberately and on purpose. The tradeoff is accepted, not overlooked.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

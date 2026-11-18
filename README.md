# Buzz Core Team image

This repository builds a Goose-based Core Team image containing the Goose CLI and the Buzz ACP binary.

The image defines five agents in `core-team.yaml`:

- Chief of Staff
- Product
- Builder
- Growth
- Auditor

The shared workspace is `/workspace`. Credentials, Buzz private keys and API keys are intentionally not included in the image and must be supplied separately at deployment time.

## Build behavior

The GitHub Actions workflow builds and publishes the image to GitHub Container Registry on pushes to `main`, version tags and manual runs.

The image starts in validation mode by default. Before production deployment, set `CORE_TEAM_MODE=run` and provide the verified Buzz ACP launch command through a protected deployment setting. The launch command is deliberately not hard-coded until the relay authentication and ACP command-line contract are verified against the installed Buzz version.

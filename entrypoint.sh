#!/usr/bin/env bash
set -euo pipefail

: "${CORE_TEAM_CONFIG:=/etc/core-team/agents.yaml}"
: "${CORE_TEAM_WORKSPACE:=/workspace}"

if [[ ! -d "${CORE_TEAM_WORKSPACE}" ]]; then
  mkdir -p "${CORE_TEAM_WORKSPACE}"
fi

if [[ "${CORE_TEAM_MODE:-validate}" == "validate" ]]; then
  echo "Core Team image is ready."
  echo "Configured agents: Chief of Staff, Product, Builder, Growth, Auditor"
  echo "Binaries available: goose, buzz-acp"
  echo "Set CORE_TEAM_MODE=run together with the approved Buzz ACP launch command before deployment."
  exec sleep infinity
fi

if [[ -z "${BUZZ_ACP_COMMAND:-}" ]]; then
  echo "BUZZ_ACP_COMMAND is required when CORE_TEAM_MODE=run." >&2
  exit 64
fi

exec /bin/bash -lc "${BUZZ_ACP_COMMAND}"

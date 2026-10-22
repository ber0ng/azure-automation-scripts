#!/usr/bin/env bash
# shellcheck shell=bash
#
# Usage (from bash/scripts/*.sh):
#   # shellcheck source=../lib/common.sh
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Guard against being sourced twice
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

readonly EXIT_OK=0        # ran cleanly, nothing found
readonly EXIT_FINDINGS=1  # ran cleanly, found issues
readonly EXIT_ERROR=2     # script failed

DRY_RUN="${DRY_RUN:-false}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Logs go to stderr so stdout stays clean for report output / piping
_log() {
  local level="$1"
  shift
  printf '[%s] [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$*" >&2
}

log_debug() { if [[ "$LOG_LEVEL" == "DEBUG" ]]; then _log DEBUG "$@"; fi; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }

die() {
  log_error "$@"
  exit "$EXIT_ERROR"
}

# require_cmd jq curl az
require_cmd() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
  done
}

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "This script must run as root (use sudo)"
}

# Wrap anything that changes state: run rm -f "$file"
run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] $*"
  else
    "$@"
  fi
}

on_error() {
  log_error "Failed at line $1 (exit $2)"
}
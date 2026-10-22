#!/usr/bin/env bash
#
# _template.sh - one-line description of what this script does.
# Exit codes: 0 = clean, 1 = findings, 2 = error

set -o errexit -o nounset -o pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

trap 'on_error $LINENO $?' ERR

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -o, --output DIR   Report output directory (default: ./reports)
  -n, --dry-run      Show what would change without changing anything
  -v, --verbose      Enable debug logging
  -h, --help         Show this help
EOF
}

OUTPUT_DIR="./reports"

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -o|--output)  OUTPUT_DIR="${2:?--output needs a value}"; shift 2 ;;
      -n|--dry-run) DRY_RUN=true; shift ;;
      -v|--verbose) LOG_LEVEL=DEBUG; shift ;;
      -h|--help)    usage; exit "$EXIT_OK" ;;
      *)            log_error "Unknown option: $1"; usage; exit "$EXIT_ERROR" ;;
    esac
  done
}

main() {
  parse_args "$@"
  require_cmd date

  log_info "Starting (dry-run=$DRY_RUN, output=$OUTPUT_DIR)"
  mkdir -p "$OUTPUT_DIR"

  local findings=0

  # --- script logic goes here ---
  # Use `run <command>` for anything that changes state.
  # findings=$((findings + 1))

  if (( findings > 0 )); then
    log_warn "$findings finding(s)"
    exit "$EXIT_FINDINGS"
  fi

  log_info "No findings"
  exit "$EXIT_OK"
}

main "$@"
#!/usr/bin/env bash
set -eu

log_file="logs/types_check_results.log"

svelte-check --tsconfig ./tsconfig.client.json --output machine-verbose |
  line-apply ./scripts/typescript/format_svelte_check_error_report.js |
  tee "$log_file"

error_count=$(grep -E '^file://' "$log_file" --count)

if [ "$error_count" != 0 ]; then
  echo "$error_count errors. These logs have been copied in file://./$log_file"
  exit 1
fi

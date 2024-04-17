#!/usr/bin/env bash

# Do not set -e as `svelte-check` is likely to exit with a non-zero code that can be ignored
set -u

log_file="logs/types_check_results.log"

svelte-check --tsconfig ./tsconfig.client.json |
  tee "$log_file"

error_count=$(grep -E '^Error:' "$log_file" --count)

if [ "$error_count" != 0 ]; then
  echo "These logs have been copied in file://./$log_file"
  exit 1
fi

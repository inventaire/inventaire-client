#!/usr/bin/env bash
set -eu

log_file="logs/types_check_results.log"

svelte-check  --tsconfig ./tsconfig.client.json | tee -a /dev/tty > "$log_file"
echo "This logs have been copied in $log_file"

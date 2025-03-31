#!/usr/bin/env bash
set -euo pipefail

export FORCE_COLOR=1

webpack serve --config ./bundle/webpack.config.dev.cjs | ./scripts/add_log_tips.sh

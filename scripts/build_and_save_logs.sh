#!/usr/bin/env bash
# This can unfortunately not be done from the package.json script
# as it triggers "sh: 1: set: Illegal option -o pipefail"
# which is even worse that what is described here https://github.com/npm/npm/issues/18517
set -o pipefail
./scripts/build | tee ./logs/build.log

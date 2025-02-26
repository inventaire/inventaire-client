#!/usr/bin/env bash
# This can unfortunately not be done from the package.json script
# as it triggers "sh: 1: set: Illegal option -o pipefail"
# which is even worse that what is described here https://github.com/npm/npm/issues/18517
set -o pipefail

echo -e "\e[0;32mbuild and save logs\e[0m"
./scripts/build | tee ./logs/build.log
echo -e "\e[0;32mbuild and save logs: done\e[0m"

# Exit with code 0 (apparently required for Docker image build to succeed)
true

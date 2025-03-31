#!/usr/bin/env bash
export yellow=$'\e[0;33m'
export color_off=$'\e[0m'

awk '1;/Found/{printf ENVIRON["yellow"] "Persisting type errors might be fixed by clearing types build cache: rm ./tsconfig.tsbuildinfo" ENVIRON["color_off"]}'
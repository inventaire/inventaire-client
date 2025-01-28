#!/usr/bin/env bash
export NODE_ENV=federated
export FORCE_COLOR=1

custom_ansi_colors(){
  sed 's@\[32m@\[35m@g'
}

webpack serve --config ./bundle/webpack.config.dev.cjs 2> >(custom_ansi_colors >&2) | custom_ansi_colors

#!/usr/bin/env bash

set -e

cwd=$(pwd)
cd ..

parent_project=$(node -p "require('./package.json').name")
if [ "$parent_project" != "inventaire" ]; then
  echo "can't build: parent directory is not inventaire server directory"
  exit 1
fi

head_rev=$(git rev-parse --short HEAD)
main_rev=$(git rev-parse --short main)
head_branch=$(git symbolic-ref HEAD 2> /dev/null| sed 's|refs/heads/||')

cd "$cwd"

if [ "$head_rev" != "$main_rev" ]; then
  echo -e "The \e[0;33mserver repository HEAD is not on the 'main' branch\e[0m, but on '${head_branch}' (${head_rev}).
Dev server types might make the client type checks fail.
\e[0;33mBuild the client for production anyway? y/N \e[0m"
  read -r response
  if [ "$response" != "y" ]; then
    exit 1 ;
  fi
fi

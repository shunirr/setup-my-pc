#!/usr/bin/env bash
set -euxo pipefail

CWD=$(pwd)
TMPDIR=$(mktemp -d -p /tmp setup-my-pc.XXXXXX) && {
  trap 'rm -rf "$TMPDIR"' EXIT
}
cd "$TMPDIR"

curl -L -O https://github.com/shunirr/setup-my-pc/archive/main.zip
unzip main.zip
cd setup-my-pc-main
./osx.sh p

cd "$CWD"

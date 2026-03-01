#!/bin/bash

machine="$(uname -m)"
case "$machine" in
  x86_64|amd64) arch="amd64" ;;
  aarch64|arm64) arch="aarch64" ;;
  *) echo "Unsupported architecture: $machine" >&2; exit 1 ;;
esac

wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${arch}.deb && sudo apt install ./k9s_linux_${arch}.deb && rm k9s_linux_${arch}.deb

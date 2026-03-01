#!/bin/bash
machine="$(uname -m)"
case "$machine" in
  x86_64|amd64) arch="x86_64" ;;
  aarch64|arm64) arch="aarch64" ;;
  *) echo "Unsupported architecture: $machine" >&2; exit 1 ;;
esac

curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip -d /tmp
sudo /tmp/aws/install
rm -rf /tmp/aws awscliv2.zip

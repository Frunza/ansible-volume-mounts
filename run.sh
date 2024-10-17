#!/bin/sh

# Exit immediately if a simple command exits with a nonzero exit value
set -e

docker build --build-arg SSH_PRIVATE_KEY="$TARGET_MACHINE_SSH_PRIVATE_KEY" -t mountansible .
docker-compose -f docker-compose.yml run --rm main

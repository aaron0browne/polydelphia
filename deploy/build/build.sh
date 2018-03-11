#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAG="$(git describe --always --dirty)"
packer build -var "tag=$TAG" "${SCRIPT_DIR}/packer.json"

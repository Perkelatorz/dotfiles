#!/usr/bin/env bash
# bashls + shfmt
set -euo pipefail

greet() {
	local name="${1:-nvim}"
	echo "Hello, ${name}!"
}

greet "$@"

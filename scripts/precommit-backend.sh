#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../api"
./mvnw -B -ntp spotless:check checkstyle:check

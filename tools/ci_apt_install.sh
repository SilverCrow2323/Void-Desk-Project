#!/usr/bin/env bash
# Bounded apt installer for GitHub-hosted Ubuntu runners.
# Runner images can inject region-specific Azure/EC2 mirrors that stall or
# ignore package downloads. Normalize only those hosts to Ubuntu's HTTPS
# archive; never disable certificate or hostname verification.
set -euo pipefail

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 PACKAGE [PACKAGE ...]" >&2
  exit 2
fi

APT_SOURCES_ROOT="${QWASAR_CI_APT_SOURCES_ROOT:-/etc/apt}"
RUNNER_MIRROR_PATTERN='(azure\.archive\.ubuntu\.com|us-east-2\.ec2\.archive\.ubuntu\.com)'

apt_edit_file() {
  local file="$1"
  shift
  if [[ -w "$file" ]]; then
    sed -i "$@" "$file"
  else
    sudo sed -i "$@" "$file"
  fi
}

normalize_runner_mirrors() {
  local mirror_list="$APT_SOURCES_ROOT/apt-mirrors.txt"
  local file

  if [[ -f "$mirror_list" ]] && grep -Eq "$RUNNER_MIRROR_PATTERN" "$mirror_list"; then
    apt_edit_file "$mirror_list" -E "/$RUNNER_MIRROR_PATTERN/d"
    echo "Removed degraded region-specific mirrors from apt-mirrors.txt."
  fi

  while IFS= read -r -d '' file; do
    if grep -Eq "https?://$RUNNER_MIRROR_PATTERN/ubuntu" "$file"; then
      # Use # as the sed delimiter because the ERE contains an alternation |.
      apt_edit_file "$file" -E \
        "s#https?://$RUNNER_MIRROR_PATTERN/ubuntu/?#https://archive.ubuntu.com/ubuntu#g"
      echo "Normalized runner mirror in $file."
    fi
  done < <(
    find "$APT_SOURCES_ROOT" -maxdepth 2 -type f \
      \( -name 'sources.list' -o -name '*.list' -o -name '*.sources' \) -print0
  )
}

normalize_runner_mirrors

# The normalization-only mode is used by the host regression test. It never
# invokes APT and keeps the same code path as the real CI installer.
if [[ "${QWASAR_CI_APT_NORMALIZE_ONLY:-0}" == "1" ]]; then
  exit 0
fi

APT_OPTIONS=(
  -o Acquire::Retries=1
  -o Acquire::http::Timeout=20
  -o Acquire::https::Timeout=20
)
UPDATE_TIMEOUT="${QWASAR_CI_APT_UPDATE_TIMEOUT:-120}"
INSTALL_TIMEOUT="${QWASAR_CI_APT_INSTALL_TIMEOUT:-180}"

for attempt in 1 2; do
  if timeout --kill-after=10s "${UPDATE_TIMEOUT}s" \
      sudo apt-get update -qq "${APT_OPTIONS[@]}" &&
     timeout --kill-after=10s "${INSTALL_TIMEOUT}s" \
      sudo apt-get install -y "${APT_OPTIONS[@]}" "$@"; then
    exit 0
  fi

  if [[ "$attempt" -eq 2 ]]; then
    echo "APT update/install failed after 2 bounded attempts." >&2
    exit 1
  fi

  echo "APT mirror unavailable or too slow; retrying in 15s..." >&2
  sleep 15
done

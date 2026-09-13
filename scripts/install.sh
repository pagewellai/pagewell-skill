#!/usr/bin/env bash
# Install the pagewell CLI, picking the binary that matches this machine.
#
# This bundle ships prebuilt binaries — there is no source tree here to build
# from. That is deliberate: the binary you get is the one built from the source
# commit recorded in MANIFEST, so the SKILL text and the CLI can never disagree
# about which flags exist.
set -euo pipefail

# Substituted when the bundle is published. Seeing @@…@@ below means you are
# looking at the template in the source repository, not at a published copy.
REPO_SLUG="pagewellai/pagewell-skill"
BRANCH="main"
VERSION="v0.1.0"

BIN_DIR="${PAGEWELL_BIN_DIR:-$HOME/.local/bin}"
BASE_URL="https://raw.githubusercontent.com/$REPO_SLUG/$BRANCH"

have() { command -v "$1" >/dev/null 2>&1; }
die() { echo "$*" >&2; exit 1; }

digest() {
  if have shasum; then shasum -a 256 "$1" | cut -d' ' -f1
  elif have sha256sum; then sha256sum "$1" | cut -d' ' -f1
  else return 1; fi
}

# ---------------------------------------------------------------- platform

# uname is the only thing every one of these systems agrees on. Git Bash, MSYS
# and Cygwin each report a different flavour of Windows, so match on a prefix
# rather than an exact string.
raw_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
raw_arch="$(uname -m)"
ext=""
case "$raw_os" in
  darwin)               os=darwin ;;
  linux)                os=linux ;;
  mingw*|msys*|cygwin*|windows*) os=windows; ext=".exe" ;;
  *)                    os="$raw_os" ;;
esac
case "$raw_arch" in
  x86_64|amd64)         arch=amd64 ;;
  arm64|aarch64)        arch=arm64 ;;
  *)                    arch="$raw_arch" ;;
esac
asset="pagewell_${os}_${arch}${ext}"

# The bundle normally arrives whole — SKILL.md, references/ and bin/ together —
# so install from what is already on disk before reaching for the network.
here="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

unsupported() {
  echo "No prebuilt binary for ${raw_os}/${raw_arch} (looked for $asset)." >&2
  echo >&2
  echo "Published binaries:" >&2
  if [ -f "$here/bin/SHA256SUMS" ]; then
    sed 's|.*bin/|  |' "$here/bin/SHA256SUMS" >&2
  elif curl -fsSL "$BASE_URL/bin/SHA256SUMS" -o "$tmp/SHA256SUMS" 2>/dev/null; then
    sed 's|.*bin/|  |' "$tmp/SHA256SUMS" >&2
  else
    echo "  see https://github.com/$REPO_SLUG/tree/$BRANCH/bin" >&2
  fi
  exit 1
}

# ---------------------------------------------------------------- already there?

# Where this bundle lives is remembered for `pagewell upgrade`: it pulls that
# directory and re-runs this script, so the skill text and the binary move
# together. A curl-piped install has no bundle on disk and records nothing.
CONFIG_HOME="${PAGEWELL_CONFIG_HOME:-$HOME/.config/pagewell}"
remember_bundle() {
  [ -f "$here/SKILL.md" ] || return 0
  mkdir -p "$CONFIG_HOME" && chmod 700 "$CONFIG_HOME" 2>/dev/null || true
  printf 'bundle: %s\nbin: %s\n' "$here" "$1" > "$CONFIG_HOME/install.yaml"
}

# Re-running the installer after an update should upgrade, not silently do
# nothing — that is the whole point of running it again.
existing="$(command -v pagewell 2>/dev/null || true)"
if [ -n "$existing" ]; then
  cur="$("$existing" version 2>/dev/null | head -1 | awk '{print $2}' || echo unknown)"
  case "$cur" in
    "$VERSION") remember_bundle "$existing"; echo "Already at $VERSION: $existing"; exit 0 ;;
    *) echo "Upgrading: ${cur:-unknown} → $VERSION" ;;
  esac
fi

# ---------------------------------------------------------------- fetch

if [ -f "$here/bin/$asset" ]; then
  echo "Installing $asset from this bundle ($VERSION)"
  cp "$here/bin/$asset" "$tmp/$asset"
  sums="$here/bin/SHA256SUMS"
else
  have curl || die "Need curl to download the binary."
  echo "Downloading $asset ($VERSION)"
  curl -fsSL "$BASE_URL/bin/$asset" -o "$tmp/$asset" 2>/dev/null || unsupported
  curl -fsSL "$BASE_URL/bin/SHA256SUMS" -o "$tmp/SHA256SUMS" \
    || die "Could not fetch SHA256SUMS from $BASE_URL/bin/"
  sums="$tmp/SHA256SUMS"
fi

# ---------------------------------------------------------------- verify

# Verify before making it executable. A binary that arrived over the network is
# not something to run on trust, and a truncated download looks exactly like a
# working one right up until it segfaults.
if [ "${PAGEWELL_SKIP_VERIFY:-}" = "1" ]; then
  echo "Skipping checksum verification (PAGEWELL_SKIP_VERIFY=1)"
else
  want="$(grep -E "[ *]bin/${asset}\$" "$sums" 2>/dev/null | cut -d' ' -f1 || true)"
  [ -n "$want" ] || die "No checksum listed for $asset — refusing to install."
  got="$(digest "$tmp/$asset")" || die \
"Need shasum or sha256sum to verify the download.
  Install one, or re-run with PAGEWELL_SKIP_VERIFY=1 to accept it unverified."
  [ "$got" = "$want" ] || die \
"Checksum mismatch for $asset — refusing to install.
  expected $want
  got      $got"
  echo "Checksum OK"
fi

# ---------------------------------------------------------------- install

mkdir -p "$BIN_DIR"
chmod +x "$tmp/$asset"
# Windows cannot overwrite a running executable: when `pagewell upgrade` runs
# us, the old binary is the one calling — move it aside first.
if [ -n "$ext" ] && [ -f "$BIN_DIR/pagewell$ext" ]; then
  mv -f "$BIN_DIR/pagewell$ext" "$BIN_DIR/pagewell$ext.old" 2>/dev/null || true
fi
mv "$tmp/$asset" "$BIN_DIR/pagewell$ext"
target="$BIN_DIR/pagewell$ext"
remember_bundle "$target"

case ":$PATH:" in
  *":$BIN_DIR:"*)
    # A different pagewell earlier in PATH would keep winning, and the version
    # you just installed would never run. Say so rather than let it confuse.
    found="$(command -v pagewell 2>/dev/null || true)"
    if [ -n "$found" ] && [ "$found" != "$target" ]; then
      echo
      echo "Note: $found comes first in PATH and will shadow $target"
    fi
    ;;
  *)
    echo
    echo "Add $BIN_DIR to your PATH:"
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

"$target" version

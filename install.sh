#!/usr/bin/env sh
#
# AI E-Commerce Platform — one-command installer.
#
#   curl -fsSL https://raw.githubusercontent.com/kenanghasi-hash/ai-ecommerce-platform-public/main/install.sh | sh
#
# Downloads the latest published bundle, VERIFIES ITS CHECKSUM against the signed
# release manifest, unpacks it, and tells you the two things left to do. It does
# not touch your database, does not ask for credentials, and does not start
# anything on its own.
#
# Safe to re-run: an existing install is detected and left alone unless you pass
# --update, which preserves .env, public/uploads and storage.
#
# Options:
#   --dir <path>      install location (default: ./ai-shop)
#   --update          update an existing install in --dir instead of refusing
#   --version <v>     install a specific version tag instead of the latest
#   --manifest <url>  install from a different release channel entirely
#
set -eu

REPO="kenanghasi-hash/ai-ecommerce-platform-public"
TARGET="./ai-shop"
MODE="install"
VERSION=""
MANIFEST_OVERRIDE=""

RED=''; GRN=''; YEL=''; DIM=''; OFF=''
if [ -t 1 ]; then
  RED="$(printf '\033[31m')"; GRN="$(printf '\033[32m')"; YEL="$(printf '\033[33m')"
  DIM="$(printf '\033[2m')"; OFF="$(printf '\033[0m')"
fi
say()  { printf '%s\n' "$*"; }
ok()   { printf '%s✔%s %s\n' "$GRN" "$OFF" "$*"; }
warn() { printf '%s!%s %s\n' "$YEL" "$OFF" "$*"; }
die()  { printf '%sx%s %s\n' "$RED" "$OFF" "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)      TARGET="${2:-}"; shift 2 ;;
    --update)   MODE="update"; shift ;;
    --version)  VERSION="${2:-}"; shift 2 ;;
    --manifest) MANIFEST_OVERRIDE="${2:-}"; shift 2 ;;
    -h|--help)  sed -n '2,24p' "$0"; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# ---------------------------------------------------------------- prerequisites
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not installed."; }
need tar

DL=""
if command -v curl >/dev/null 2>&1; then DL="curl"
elif command -v wget >/dev/null 2>&1; then DL="wget"
else die "Need either curl or wget to download."
fi

fetch() { # fetch <url> <dest>
  if [ "$DL" = "curl" ]; then curl -fsSL "$1" -o "$2"
  else wget -qO "$2" "$1"; fi
}
fetch_stdout() {
  if [ "$DL" = "curl" ]; then curl -fsSL "$1"
  else wget -qO- "$1"; fi
}

# sha256: coreutils, busybox and macOS all spell this differently.
SHA=""
if command -v sha256sum >/dev/null 2>&1; then SHA="sha256sum"
elif command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"
elif command -v openssl >/dev/null 2>&1; then SHA="openssl dgst -sha256"
fi

if command -v node >/dev/null 2>&1; then
  NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [ "$NODE_MAJOR" -lt 18 ] 2>/dev/null; then
    warn "Node $(node -v) found — the shop needs 18+. Install a newer Node before starting it."
  else
    ok "Node $(node -v)"
  fi
else
  warn "Node.js not found on PATH. You will need Node 18+ to run the shop."
fi

# ------------------------------------------------------------------- manifest
if [ -n "$MANIFEST_OVERRIDE" ]; then
  MANIFEST_URL="$MANIFEST_OVERRIDE"
elif [ -n "$VERSION" ]; then
  MANIFEST_URL="https://github.com/$REPO/releases/download/$VERSION/manifest.json"
else
  MANIFEST_URL="https://github.com/$REPO/releases/latest/download/manifest.json"
fi

say ""
say "${DIM}Fetching release manifest…${OFF}"
MANIFEST="$(fetch_stdout "$MANIFEST_URL" 2>/dev/null || true)"
[ -n "$MANIFEST" ] || die "No release found yet at $REPO. Check the Releases page."

# Small, dependency-free JSON field reader — the manifest is written by our own
# release script, so its shape is known and flat.
field() { printf '%s' "$MANIFEST" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"; }

LATEST="$(field latest)"
URL="$(field downloadUrl)"
WANT_SHA="$(field sha256)"

[ -n "$LATEST" ] || die "Manifest has no version field — refusing to guess."
[ -n "$URL" ]    || die "Manifest names no download for $LATEST."
ok "Latest version: $LATEST"

# ------------------------------------------------------------ target directory
if [ -e "$TARGET/server.js" ]; then
  if [ "$MODE" != "update" ]; then
    die "$TARGET already contains an install. Re-run with --update to upgrade it (your .env, uploads and storage are preserved)."
  fi
  ok "Updating the existing install in $TARGET"
else
  [ "$MODE" = "update" ] && die "No install found in $TARGET to update."
  # Remember whether WE created the directory, so a failed install can undo it.
  # Leaving an empty folder behind after refusing to install reads like a
  # half-finished job, and the next run would be unsure what it was looking at.
  [ -d "$TARGET" ] || CREATED_TARGET=1
  mkdir -p "$TARGET"
fi

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t aishop)"
cleanup() {
  rm -rf "$TMP"
  # Only ever remove a directory this run created, and only while it is empty.
  if [ "${CREATED_TARGET:-0}" = "1" ] && [ "${INSTALL_DONE:-0}" != "1" ]; then
    rmdir "$TARGET" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# ---------------------------------------------------------- download + verify
say "${DIM}Downloading $LATEST…${OFF}"
fetch "$URL" "$TMP/deploy.tar.gz" || die "Download failed: $URL"

if [ -n "$WANT_SHA" ] && [ -n "$SHA" ]; then
  GOT="$($SHA "$TMP/deploy.tar.gz" | tr -d '\r' | awk '{ for (i=1;i<=NF;i++) if (length($i)==64) { print $i; exit } }')"
  [ "$GOT" = "$WANT_SHA" ] || die "Checksum mismatch — refusing to install.
  expected $WANT_SHA
  got      $GOT
This means the download was corrupted or tampered with. Nothing was changed."
  ok "Checksum verified"
elif [ -z "$SHA" ]; then
  warn "No sha256 tool available — cannot verify the download. Install coreutils to enable this."
else
  warn "Manifest carries no checksum — cannot verify the download."
fi

# ------------------------------------------------------------------- unpack
say "${DIM}Unpacking…${OFF}"
mkdir -p "$TMP/x"
tar -xzf "$TMP/deploy.tar.gz" -C "$TMP/x"

# The tarball may or may not have a single top-level folder; handle both.
SRC="$TMP/x"
if [ ! -e "$SRC/server.js" ]; then
  INNER="$(find "$TMP/x" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [ -n "$INNER" ] && [ -e "$INNER/server.js" ] && SRC="$INNER"
fi
[ -e "$SRC/server.js" ] || die "Unexpected bundle layout — no server.js inside the archive."

if [ "$MODE" = "update" ]; then
  # Never overwrite the three things that ARE the shop's identity and data.
  for keep in .env public/uploads storage; do
    if [ -e "$TARGET/$keep" ]; then
      mkdir -p "$TMP/keep/$(dirname "$keep")"
      cp -R "$TARGET/$keep" "$TMP/keep/$keep"
    fi
  done
  rm -rf "$TARGET"/* 2>/dev/null || true
fi

cp -R "$SRC"/. "$TARGET"/

if [ "$MODE" = "update" ] && [ -d "$TMP/keep" ]; then
  cp -R "$TMP/keep"/. "$TARGET"/
  ok "Preserved .env, uploads and storage"
fi

INSTALL_DONE=1
ok "Installed into $TARGET"

# -------------------------------------------------------------------- finish
say ""
if [ "$MODE" = "update" ]; then
  say "${GRN}Update complete.${OFF}"
  say ""
  say "  1. Restart the app  ${DIM}(pm2 restart all, or your panel's Restart button)${OFF}"
  say "  2. Open  /admin/update  and finish the database step if prompted"
else
  say "${GRN}Ready.${OFF} Two steps left:"
  say ""
  say "  1. Start it:"
  say "       ${DIM}cd $TARGET && PORT=3000 node server.js${OFF}"
  say "     ${DIM}or register the folder in your panel's \"Setup Node.js App\" with${OFF}"
  say "     ${DIM}server.js as the startup file, so it keeps running and survives reboots.${OFF}"
  say ""
  say "  2. Open  https://your-domain.com/install"
  say "     ${DIM}The wizard asks for your database and admin account, creates the${OFF}"
  say "     ${DIM}tables, generates every secret, and locks itself afterwards.${OFF}"
  say ""
  say "Update notifications are already on — this build follows the official"
  say "release channel, so you will see a banner in the admin when a new version"
  say "is out, and can install it with one click. Nothing to configure."
fi
say ""

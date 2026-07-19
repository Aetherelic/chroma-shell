#!/usr/bin/env bash

set -Eeuo pipefail

repo_url="${CHROMA_REPO_URL:-https://github.com/Aetherelic/chroma-shell.git}"
ref="${CHROMA_REF:-main}"
local_mode=0
passthrough=()

usage() {
    cat <<'USAGE'
CHROMA bootstrap installer

Usage:
  ./install.sh [--local] [--ref REF] [installer options]

Environment:
  CHROMA_REPO_URL   Repository URL to clone
  CHROMA_REF        Branch, tag, or commit to install

Examples:
  ./install.sh --local
  CHROMA_REF=feat/cross-distro-installer ./install.sh
  ./install.sh --ref v0.9.0-alpha.1 --dry-run
USAGE
}

while (($#)); do
    case "$1" in
        --local)
            local_mode=1
            shift
            ;;
        --ref|--branch)
            test $# -ge 2 || { printf 'Missing value for %s\n' "$1" >&2; exit 2; }
            ref="$2"
            shift 2
            ;;
        --repo)
            test $# -ge 2 || { printf 'Missing value for --repo\n' >&2; exit 2; }
            repo_url="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            passthrough+=("$1")
            shift
            ;;
    esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P || true)"

if test "$local_mode" -eq 1 || test -x "$script_dir/installer/chroma-installer"; then
    source_root="$script_dir"
    test -x "$source_root/installer/chroma-installer" || {
        printf 'Local installer not found in %s\n' "$source_root" >&2
        exit 1
    }
    exec "$source_root/installer/chroma-installer" \
        --source "$source_root" \
        --repo "$repo_url" \
        --ref "$ref" \
        "${passthrough[@]}"
fi

temporary="$(mktemp -d -t chroma-bootstrap.XXXXXX)"
cleanup() {
    rm -rf -- "$temporary"
}
trap cleanup EXIT INT TERM

printf 'CHROMA//BOOTSTRAP  acquiring %s (%s)\n' "$repo_url" "$ref"

if command -v git >/dev/null 2>&1; then
    git clone --filter=blob:none --no-checkout --quiet "$repo_url" "$temporary/repository"
    git -C "$temporary/repository" fetch --quiet --depth 1 origin "$ref"
    git -C "$temporary/repository" checkout --quiet --detach FETCH_HEAD
else
    command -v curl >/dev/null 2>&1 || {
        printf 'The bootstrap requires either Git or curl.\n' >&2
        exit 1
    }
    command -v tar >/dev/null 2>&1 || {
        printf 'The bootstrap requires tar when Git is unavailable.\n' >&2
        exit 1
    }

    case "$repo_url" in
        https://github.com/*/*.git|https://github.com/*/*)
            github_path="${repo_url#https://github.com/}"
            github_path="${github_path%.git}"
            archive="$temporary/source.tar.gz"
            curl -fL --retry 3 --connect-timeout 15 \
                "https://codeload.github.com/${github_path}/tar.gz/${ref}" \
                -o "$archive"
            mkdir -p "$temporary/extracted"
            tar -xzf "$archive" -C "$temporary/extracted"
            extracted_root="$(find "$temporary/extracted" -mindepth 1 -maxdepth 1 -type d -print -quit)"
            test -n "$extracted_root" || {
                printf 'Downloaded CHROMA archive was empty.\n' >&2
                exit 1
            }
            mv -- "$extracted_root" "$temporary/repository"
            ;;
        *)
            printf 'Git is required for custom non-GitHub repositories.\n' >&2
            exit 1
            ;;
    esac
fi

test -x "$temporary/repository/installer/chroma-installer" || {
    printf 'The selected CHROMA ref does not contain the installer.\n' >&2
    exit 1
}

"$temporary/repository/installer/chroma-installer" \
    --source "$temporary/repository" \
    --repo "$repo_url" \
    --ref "$ref" \
    "${passthrough[@]}"

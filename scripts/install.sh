#!/bin/sh
# Install justfeed.
#
# Inside a checkout of this repository the binary is built from the source tree;
# run anywhere else (for example piped from the release page) it is downloaded.
# The mode is picked automatically and can be forced with --from-source/--download.
#
# Usage:  install.sh [options]
#
#   --from-source         build from this checkout
#   --download            download a release instead of building
#   --version <vX.Y.Z>    the release to download (default: the latest)
#   --prefix <dir>        install the binary into <dir> (default: ~/.local/bin)
#   --no-modify-path      do not touch your shell profile, even if <dir> is not on PATH
#   --help                print this help
#
# Environment:
#   JUSTFEED_INSTALL_DIR    same as --prefix, overridden by the flag
#   JUSTFEED_NO_MODIFY_PATH set to 1 for --no-modify-path
#   JUSTFEED_VERSION        same as --version, overridden by the flag
#   JUSTFEED_BASE_URL       release base URL (default: the project's GitHub releases)
set -eu

# The one Linux target the release workflow builds; the installer fetches exactly it.
target=x86_64-unknown-linux-gnu
asset=justfeed-$target.tar.xz
repo_slug=riesemann/justfeed

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." 2>/dev/null && pwd || pwd)

prefix=${JUSTFEED_INSTALL_DIR:-$HOME/.local/bin}
version=${JUSTFEED_VERSION:-}
mode=auto
modify_path=1
if [ "${JUSTFEED_NO_MODIFY_PATH:-0}" = "1" ]; then
    modify_path=0
fi

usage() {
    sed -n '2,/^[^#]/p' "$0" | sed -n 's/^# \{0,1\}//p'
    exit "$1"
}

die() {
    printf 'install.sh: %s\n' "$1" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --from-source) mode=source; shift ;;
        --download)    mode=download; shift ;;
        --version)
            [ $# -ge 2 ] || die "--version needs a release like v2.0.0"
            version=$2
            shift 2
            ;;
        --version=*) version=${1#--version=}; shift ;;
        --prefix)
            [ $# -ge 2 ] || die "--prefix needs a directory"
            prefix=$2
            shift 2
            ;;
        --prefix=*) prefix=${1#--prefix=}; shift ;;
        --no-modify-path) modify_path=0; shift ;;
        -h|--help) usage 0 ;;
        *) die "unknown option '$1' (try --help)" ;;
    esac
done

if [ "$mode" = auto ]; then
    if [ -f "$repo_root/Cargo.toml" ] && grep -q '^name = "justfeed"' "$repo_root/Cargo.toml"; then
        mode=source
    else
        mode=download
    fi
fi

if [ "$mode" = source ] && [ ! -f "$repo_root/Cargo.toml" ]; then
    die "--from-source needs a checkout of the repository"
fi

[ "$(uname -s)" = "Linux" ] || die "this installer is for Linux; build with 'cargo install --path . --locked' instead (see the README)"

tmpdir=
cleanup() {
    if [ -n "$tmpdir" ] && [ -d "$tmpdir" ]; then
        rm -rf "$tmpdir"
    fi
}
trap cleanup EXIT

fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -fLsS -o "$2" "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$2" "$1"
    else
        die "neither curl nor wget is available to download the release"
    fi
}

# Build from the checkout when asked, otherwise download and verify a release.
if [ "$mode" = source ]; then
    command -v cargo >/dev/null 2>&1 || die "cargo was not found; install a Rust toolchain first, for example with https://sh.rustup.rs"
    printf 'Building justfeed (release) from %s …\n' "$repo_root"
    cargo build --release --locked --manifest-path "$repo_root/Cargo.toml"
    binary="$repo_root/target/release/justfeed"
    [ -x "$binary" ] || die "the build finished but $binary is missing"
else
    [ "$(uname -m)" = "x86_64" ] ||
        die "no prebuilt binary for this machine ($(uname -m)); build from source with 'cargo install --path . --locked'"
    case "$version" in
        "") ;;
        v*) ;;
        *) version="v$version" ;;
    esac

    base=${JUSTFEED_BASE_URL:-https://github.com/$repo_slug/releases}
    if [ -n "$version" ]; then
        base="$base/download/$version"
        printf 'Downloading justfeed %s …\n' "$version"
    else
        base="$base/latest/download"
        printf 'Downloading the latest justfeed release …\n'
    fi

    tmpdir=$(mktemp -d) || die "could not create a temporary directory"
    fetch "$base/$asset" "$tmpdir/$asset" || die "could not download $base/$asset"
    fetch "$base/$asset.sha256" "$tmpdir/$asset.sha256" || die "could not download $base/$asset.sha256"

    command -v sha256sum >/dev/null 2>&1 || die "sha256sum is missing; cannot verify the download"
    if ! (cd "$tmpdir" && sha256sum -c --strict "$asset.sha256" >/dev/null); then
        die "the checksum of $asset does not match — the download is refused"
    fi

    tar -xJf "$tmpdir/$asset" -C "$tmpdir" || die "could not unpack $asset"
    binary="$tmpdir/justfeed-$target/justfeed"
    [ -x "$binary" ] || die "the archive did not contain justfeed-$target/justfeed"
fi

mkdir -p "$prefix" || die "could not create $prefix"
install -m 0755 "$binary" "$prefix/justfeed" || die "could not install into $prefix"
printf 'Installed: %s/justfeed\n' "$prefix"

installed_version=$("$prefix/justfeed" --version 2>/dev/null || true)
if [ -n "$installed_version" ]; then
    printf 'Version:   %s\n' "$installed_version"
fi

# Offer to put the install directory on PATH when it is not there yet.
case ":${PATH:-}:" in
    *":$prefix:"*)
        ;;
    *)
        profile=
        case "${SHELL:-}" in
            */zsh)  profile="$HOME/.zshrc" ;;
            */bash) profile="$HOME/.bashrc" ;;
            */fish) profile="$HOME/.config/fish/config.fish" ;;
        esac
        if [ "$modify_path" -eq 1 ] && [ -n "$profile" ]; then
            if [ -f "$profile" ] && grep -qF "$prefix" "$profile"; then
                printf '%s is already mentioned in %s — start a new shell if justfeed is not found.\n' "$prefix" "$profile"
            elif [ -w "$profile" ] || [ ! -e "$profile" ]; then
                if [ "${profile##*/}" = "config.fish" ]; then
                    printf '\n# Added by the justfeed installer\nfish_add_path %s\n' "$prefix" >>"$profile"
                else
                    printf '\n# Added by the justfeed installer\nexport PATH="%s:$PATH"\n' "$prefix" >>"$profile"
                fi
                printf 'Added %s to PATH in %s — open a new shell (or source it).\n' "$prefix" "$profile"
            else
                printf '%s is not on your PATH; add it to %s yourself.\n' "$prefix" "$profile"
            fi
        else
            printf '%s is not on your PATH. Add it yourself, for example:\n  export PATH="%s:$PATH"\n' "$prefix" "$prefix"
        fi
        ;;
esac

printf "\nDone. Run 'justfeed' — a commented configuration template is written to\n"
printf '~/.config/justfeed/config.toml on the first start.\n'

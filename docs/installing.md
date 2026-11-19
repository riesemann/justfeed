# Installing

justfeed is a single binary with no data files beyond your configuration. A prebuilt one exists for
**Linux on x86_64**; every other platform builds from a clone.

| Platform | Status | How |
|---|---|---|
| Linux, x86_64 | Built and released | The installer below, or the plain archive |
| Linux, other architectures | Not built | Build from a clone |
| macOS | Not built | Build from a clone |
| Windows | Not built | Build from a clone |

*Built* means the release carries the archive and its checksum was verified. The app has not been
started on macOS or Windows by anyone yet, so those are build-and-test work rather than a missing
download link.

## Linux (x86_64)

The installer fetches the archive, checks it against the `sha256` the release carries and puts
`justfeed` in `~/.local/bin`:

```sh
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/riesemann/justfeed/releases/latest/download/justfeed-installer.sh | sh
```

Run the same script from a clone and it builds from the source tree instead — it tells the two
situations apart on its own, and needs nothing from the network for that:

```sh
./scripts/install.sh
```

### Options and environment variables

| Option / variable | Effect |
|---|---|
| `--from-source` / `--download` | Force building from the checkout / downloading a release |
| `--version <vX.Y.Z>` / `JUSTFEED_VERSION` | The release to download (default: the latest) |
| `--prefix <dir>` / `JUSTFEED_INSTALL_DIR` | Install the binary elsewhere (default `~/.local/bin`) |
| `--no-modify-path` / `JUSTFEED_NO_MODIFY_PATH=1` | Do not touch your shell profile, even when the install directory is not on `PATH` |
| `JUSTFEED_BASE_URL` | A different release base URL (default: this project's GitHub releases) |
| `--help` | Print the usage |

When the install directory is not on your `PATH`, the installer appends the matching line to
`~/.bashrc`, `~/.zshrc` or `~/.config/fish/config.fish` and says so. With `--no-modify-path` it only
prints what to add.

Only `x86_64` is downloaded; on another architecture the installer says so and points at the
build-from-source route instead.

### The plain archive

The release also carries `justfeed-x86_64-unknown-linux-gnu.tar.xz` — the binary plus the README,
the changelog and the licence — together with its `.sha256`, if you would rather unpack it yourself:

```sh
sha256sum -c justfeed-x86_64-unknown-linux-gnu.tar.xz.sha256
tar -xJf justfeed-x86_64-unknown-linux-gnu.tar.xz
./justfeed-x86_64-unknown-linux-gnu/justfeed --version
```

### What the binary needs

x86_64, and glibc **2.34 or newer**. That floor is read off the binary rather than assumed from the
build machine; it is built on Ubuntu 22.04, which ships 2.35.

## Uninstalling

Delete the binary:

```sh
rm ~/.local/bin/justfeed
```

Your configuration is not touched — `~/.config/justfeed/` (the config file) and the feeds in it stay
until you delete that directory too.

**If you also installed with `cargo`**, the binary is in `~/.cargo/bin` instead, and the two
directories can both be on your `PATH`. Whichever comes first wins, so `justfeed -V` is the only
reliable answer to which version runs; `cargo uninstall justfeed` removes the cargo one.

## Building from a clone

With a Rust toolchain (the crate uses edition 2024):

```sh
git clone https://github.com/riesemann/justfeed
cd justfeed
cargo install --path . --locked
```

`--locked` builds exactly the dependency versions in `Cargo.lock`. This installs into `~/.cargo/bin`;
[Development](development.md) has the build and test commands for working on the source.

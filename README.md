# justfeed

RSS feeds and their articles in a terminal interface (TUI), written in Rust.
Runs on Linux, macOS and Windows.

**Version 2.2.0** — see [CHANGELOG.md](CHANGELOG.md) for what each release contains.
Renamed from `tuifeed` in 2.0.0 — the configuration moved to `~/.config/justfeed/`.
Built with AI assistance — see [How this was built](#how-this-was-built).

![justfeed: the configured feeds on the left, the articles of the opened feed on the right](assets/screenshot.png)

## Documentation

This file is the front door, not the manual: what the app is, how to get it running, and the keys.
The manual is in [`docs/`](docs/README.md), one page per topic — [Installing](docs/installing.md),
[Configuration](docs/configuration.md), [Using it](docs/usage.md),
[Troubleshooting](docs/troubleshooting.md) and, for contributors,
[Development](docs/development.md).

## Installing

**Linux (x86_64)** has a prebuilt binary. The installer fetches the archive, checks it against the
sha256 the release carries and puts `justfeed` in `~/.local/bin`:

```sh
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/riesemann/justfeed/releases/latest/download/justfeed-installer.sh | sh
```

From a clone, the same script builds from the source tree instead:

```sh
./scripts/install.sh
```

[Installing](docs/installing.md) has its options and environment variables, the plain archive, what
the binary needs, uninstalling, and how to build on macOS or Windows.

## Quick start

Put your feeds into `~/.config/justfeed/config.toml` — a commented template is written on the first
start — and run:

```
justfeed
```

`justfeed --help` lists the options, `justfeed --list` the feeds you have configured and the path of
the file it read. [Configuration](docs/configuration.md) explains every setting.

## Controls

| Key | Effect |
|---|---|
| `↑` / `↓` | Select an entry in the focused column |
| `PgUp` / `PgDn` | Page through the focused column |
| `←` / `→` | Switch column (feeds ↔ articles) |
| `Tab` / `Shift-Tab` | Switch column (feeds ↔ articles) |
| `Enter` | Open a feed / open the article in the browser |
| Mouse wheel | Scroll the focused column |
| Mouse click | Open the feed / article under the pointer |
| `r` | Reload the feeds |
| `/` | Search articles: typing filters live, `Enter` commits, `Esc` discards |
| `Esc` | Reset the filter (the whole article list comes back) |
| `?` | Show/hide the key help |
| `q` | Quit |

The first configured feed opens on start, so its articles are there without an extra keypress.
Mouse reporting is on; hold `Shift` while dragging to select text with the terminal.

`Enter` hands an article's address to the browser only when it is an `http` or `https` address; a link
with another scheme is refused, because feed content is untrusted.
[Using it](docs/usage.md#opening-an-article) explains why, and what the footer line means.

## How this was built

justfeed is developed with AI assistance: the code, the tests and this documentation are written in
pairing sessions with an AI coding agent (Hermes Agent by Nous Research) and reviewed by the
maintainer. Nothing ships on the agent's word alone — every change passes `cargo fmt`,
`cargo build`, `cargo test` and `cargo clippy --all-targets`, the feed parsers are tested against
recorded real payloads, and the running interface is looked at by a human before a release.

## License

MIT — see [LICENSE](LICENSE).

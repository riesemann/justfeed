# justfeed

RSS feeds and their articles in a terminal interface (TUI), written in Rust.
Runs on Linux, macOS and Windows.

**Version 2.1.0** — see [CHANGELOG.md](CHANGELOG.md) for what each release contains.
Renamed from `tuifeed` in 2.0.0 — the configuration moved to `~/.config/justfeed/`.
Built with AI assistance — see [How this was built](#how-this-was-built).

![justfeed: the configured feeds on the left, the articles of the opened feed on the right](assets/screenshot.png)

## Installing

Every release carries a prebuilt Linux archive (x86_64, glibc 2.34 or newer — the floor read off the
binary, which is built on Ubuntu 22.04) and this installer, which fetches the archive, checks it
against the sha256 it carries and puts `justfeed` in `~/.local/bin`:

```sh
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/riesemann/justfeed/releases/latest/download/justfeed-installer.sh | sh
```

From a clone you get the same result built from the checkout instead — the installer tells the two
situations apart on its own:

```sh
./scripts/install.sh
```

Options and environment variables:

| Option / variable | Effect |
|---|---|
| `--from-source` / `--download` | Force building from the checkout / downloading a release |
| `--version <vX.Y.Z>` / `JUSTFEED_VERSION` | The release to download (default: the latest) |
| `--prefix <dir>` / `JUSTFEED_INSTALL_DIR` | Install the binary elsewhere (default `~/.local/bin`) |
| `--no-modify-path` / `JUSTFEED_NO_MODIFY_PATH=1` | Do not touch your shell profile, even when the install directory is not on `PATH` |
| `JUSTFEED_BASE_URL` | A different release base URL (default: this project's GitHub releases) |
| `--help` | Print the usage |

When the install directory is not on your `PATH`, the installer appends the matching line to
`~/.bashrc`, `~/.zshrc` or `~/.config/fish/config.fish` and says so (with `--no-modify-path` it only
prints what to add). Uninstall by deleting `<prefix>/justfeed`.

The release also carries the plain archive `justfeed-x86_64-unknown-linux-gnu.tar.xz` (the binary
plus the README, the changelog and the licence) together with its `.sha256`. On another
architecture or on macOS and Windows, build from a clone with a Rust toolchain:

```sh
cargo install --path . --locked
```

### Cutting a release

`.github/workflows/release.yml` runs on every `v*` tag: it runs the tests, builds the binary, packs
the archive, writes its `.sha256` and publishes all of it as a GitHub release — with that version's
section of [CHANGELOG.md](CHANGELOG.md) as the notes. `workflow_dispatch` runs the same build
without a tag and leaves the archive as a workflow artifact, for a dry run.

## Quick start

Put your feeds into `~/.config/justfeed/config.toml` — a commented template is written on the first
start — and run:

```
justfeed
```

`justfeed --help` lists the options, `justfeed --list` the feeds you have configured.

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

`Enter` hands an article's address to the system's browser only when it is an `http` or `https`
address. Feed content is untrusted: a link with another scheme (`file:`, `smb:`, …) would reach
whatever program is registered for that scheme, and a value like `-x` would arrive at the opener as
an option instead of a URL. Such a link is refused, and the footer says so until the next keypress —
as does a browser that cannot be started. The same line carries a failed feed.

## Configuration

`~/.config/justfeed/config.toml` (or the system's usual configuration directory). A commented
template is written on the first start; the example below shows every setting.

```toml
theme = "gruvbox"
mode = "dark"
colors = "auto"
max_articles = 0

[auto_update]
enabled = false
interval_minutes = 15

[layout]
feeds_percent = 35

[[sources]]
name = "Heise"
url = "https://www.heise.de/rss/heise-atom.xml"
max = 30
```

| Setting | Default | Meaning |
|---|---|---|
| `theme` | `gruvbox` | Colour family: `gruvbox`, `nord`, `dracula` or `catppuccin` |
| `mode` | `dark` | `light` or `dark` |
| `colors` | `auto` | How many colours to use: `auto`, `truecolor`, `256` or `16` |
| `max_articles` | `0` | Fallback cap for feeds without their own `max` (`0` = all) |
| `[auto_update] enabled` | `false` | Refresh all feeds on a timer |
| `[auto_update] interval_minutes` | `15` | How often, in whole minutes (at least `1`) |
| `[layout] feeds_percent` | `35` | Width of the feed column, in percent |
| `[[sources]] name` | — | Label for the feed; without one the feed's own title is used |
| `[[sources]] url` | — | The feed URL |
| `[[sources]] max` | — | Cap for this feed, overrides `max_articles` (`0` = all) |

Repeat the `[[sources]]` block for every feed you want. Three settings need a word of explanation:

- **`colors`** — `auto` detects what the terminal can do (`COLORTERM`, `TERM`); the other values
  force that colour depth. Without a 24-bit terminal the palette colours are mapped to the nearest
  256-colour or basic colour.
- **`max_articles` and `max`** — they cap how many articles are shown, `0` means no cap, and a
  feed's own `max` wins over the global `max_articles`. The list is cut from the **top**, so the
  newest entries stay.
- **The number in brackets** in the feed column is the count that is *used*: the feed's own `max`,
  otherwise the delivered count — never more than the feed offers.

### Automatic refresh

`[auto_update] enabled = true` fetches **every** configured feed again once `interval_minutes`
minutes have passed. The timer starts when the program starts, so the first automatic fetch happens
one interval after the start, not immediately.

```
[auto_update]
enabled = true
interval_minutes = 30
```

- Off by default: without it the feeds are loaded at start and only when you press `r`.
- `interval_minutes` counts whole minutes and is at least `1`; a smaller value is raised to one
  minute.
- `r` reloads by hand at any time and **restarts** the interval, so a manual reload is not followed
  by a second fetch a moment later.
- The refresh replaces the feeds' contents; the cursor, the open feed, the filter and the scroll
  position stay where they are. While a refresh runs, the feed column and the status line show
  `loading …` again — a feed that then fails keeps its reason and is named in the status line.
- All feeds are refreshed, also while `--feed` pins a single one.
- With auto-update switched on, `?` lists the interval (`auto-refresh  every 30 min`).

## Command line

```
justfeed                     # two columns: feed list on the left, articles on the right
justfeed -f Heise            # this feed only: no list, articles across the whole window
justfeed --feed 2            # the same via the number from --list
justfeed -l                  # list the configured feeds and exit
justfeed -V                  # print the version
justfeed --help              # usage and options
```

With `--feed <NR|NAME>` (`-f`) justfeed starts with **one** feed: the feed list is gone, the article
column uses the whole window and always holds the focus. `Tab`/`←`/`→` do nothing then, while
`↑`/`↓`, `/`, `r` and `Enter` work as usual. The feed is given either as the number from `--list` or
as the `name` from the configuration (case-insensitive); a feed without a `name` can only be
addressed by its number. If nothing matches, justfeed names the available feeds (exit code 2) without
taking over the terminal.

`--list` (`-l`) shows which feeds are configured — number, name and the respective `max`:

```
Configuration: /home/…/.config/justfeed/config.toml

2 feeds:

   1. Heise   (max 50)
   2. 9to5Linux

Show one of them directly:  justfeed --feed <NR|NAME>
```

It starts no interface and fetches nothing from the network.

## The article column

### Scrolling

The highlighted article is shown as **completely** as possible. As long as more articles follow
below it, at least the first line of the next one stays visible — the cursor therefore sits in the
second-to-last visible spot and you can see what comes next. For the **last** article (no successor)
the remaining height is used for its own text, so the title and the teaser are visible. Only an
article taller than the column is cut off at the top.

If the content does not fit into the column, the column additionally shows a **scrollbar** on the
right (a continuous track without arrow heads, thumb `█`); short lists leave the column free. The
text is then wrapped one column narrower so the scrollbar covers nothing. The thumb runs to the
bottom end as soon as the list is scrolled all the way down.

### Highlight

The cursor colours **only the background** (the theme's `selection_bg`), not the text: title, date
and teaser keep their own colours (accent / muted / secondary) and stay distinguishable that way.
The band stretches across the **full width** of the column (up to the scrollbar) instead of ending
behind the text. When the column has the focus, bold is added.

## Development

Build and run from the source tree:

```
cargo run
```

Before a commit:

```
cargo fmt
cargo build
cargo test
cargo clippy --all-targets
```

The parsers are tested against recorded payloads rather than hand-written examples — see
[`fixtures/README.md`](fixtures/README.md) for where they come from and how to replace one.

### Checking a run without a screen

`scripts/pty_run.py` starts the binary in a pty of a fixed size (100×30), sends a key sequence after
a delay, quits with `q` and prints everything the program drew — so a run can be checked without a
screen:

```
python3 scripts/pty_run.py <XDG_CONFIG_HOME> ./target/debug/justfeed 12 $'\x1b[B\r'
```

Note: `Enter` in a pty is a CR (`\r`), not an LF (`\n`) — with `\n`, for example, an open search
stays open and the final `q` types into the search instead of quitting.

### Diagnosing input

To see what your terminal actually sends for a key or a click, set `JUSTFEED_EVENT_LOG` and read the
file afterwards:

```
JUSTFEED_EVENT_LOG=/tmp/justfeed-events.log cargo run
```

Every `Event::Key` / `Event::Mouse` is appended with the state before and after it is handled.

## How this was built

justfeed is developed with AI assistance: the code, the tests and this documentation are written in
pairing sessions with an AI coding agent (Hermes Agent by Nous Research) and reviewed by the
maintainer. Nothing ships on the agent's word alone — every change passes `cargo fmt`,
`cargo build`, `cargo test` and `cargo clippy --all-targets`, the feed parsers are tested against
recorded real payloads, and the running interface is looked at by a human before a release.

## License

MIT — see [LICENSE](LICENSE).

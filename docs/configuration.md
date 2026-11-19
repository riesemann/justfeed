# Configuration

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

Repeat the `[[sources]]` block for every feed you want. Both RSS 2.0 and Atom are read; the URL is
whatever the site publishes.

Three settings need a word of explanation:

- **`colors`** — `auto` detects what the terminal can do (`COLORTERM`, `TERM`); the other values
  force that colour depth, under their canonical name or an alias: `truecolor` (`24bit`, `24-bit`),
  `256` (`ansi256`, `256color`) or `16` (`ansi16`, `16color`). Without a 24-bit terminal the palette
  colours are mapped to the nearest 256-colour or basic colour. See
  [Troubleshooting](troubleshooting.md#the-colours-look-wrong) if the result is not what you expect.
- **`max_articles` and `max`** — they cap how many articles are shown, `0` means no cap, and a
  feed's own `max` wins over the global `max_articles`. The list is cut from the **top**, so the
  newest entries stay.
- **The number in brackets** in the feed column is the count that is *used*: the feed's own `max`,
  otherwise the delivered count — never more than the feed offers.

Names are read case-insensitively and without surrounding spaces. An unknown value falls back to the
default instead of failing, so a typo in `theme`, `mode` or `colors` costs you the setting, not the
start.

## Automatic refresh

`[auto_update] enabled = true` fetches **every** configured feed again once `interval_minutes`
minutes have passed. The timer starts when the program starts, so the first automatic fetch happens
one interval after the start, not immediately.

```toml
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

## Where the file is

The path follows the platform's convention (`directories::ProjectDirs`): `~/.config/justfeed/` on
Linux, the equivalent location on macOS and Windows. `justfeed --list` prints the path it actually
read, which is the quickest way to find the file you are editing.

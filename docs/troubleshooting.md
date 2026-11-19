# Troubleshooting

## A feed fails to load

The feed's row keeps the reason, and the status line names the feed that failed. `r` reloads
everything, which is also the first thing to try: a timeout on a slow host often clears itself.

Check the URL in your [configuration](configuration.md) — a feed URL that moved answers `404`. Two
limits are worth knowing before you hunt further:

- A feed body larger than **10 MiB** is refused instead of being read into memory, so a feed that
  delivers an absurd amount of data shows as a failure rather than as a slow load.
- Only RSS 2.0 and Atom are parsed. A page that offers an HTML page where the feed should be is not
  a feed.

## Enter does nothing (or opens the wrong thing)

An article's address is handed to the browser **only** when it is an `http` or `https` address.
Feed content is untrusted: a link with another scheme (`file:`, `smb:`, …) would reach whatever
program is registered for that scheme, and a value like `-x` would arrive at the opener as an option
instead of a URL. Such a link is refused, and the footer says so until the next keypress.

The same footer line carries a browser that cannot be started — usually no default browser
registered for the desktop session you are running the app in, for example over SSH.

## Fewer articles than the feed delivers

`max` on the feed, or `max_articles` globally, caps how many are shown; `0` means no cap and a feed's
own `max` wins. The list is cut from the **top**, so the newest entries stay — the oldest ones are
the ones that disappear. The number in brackets next to the feed's name is the count that is *used*,
so it tells you which of the two settings is at work. See [Configuration](configuration.md).

## The colours look wrong

`colors = "auto"` decides from `COLORTERM` and `TERM` what your terminal can do. Over SSH, inside a
multiplexer or in a terminal that under-reports itself that guess can be wrong, and the palette
colours are then mapped down to 256 or 16 colours. Force it:

```toml
colors = "truecolor"     # or "256" / "16"
```

If the whole interface is too dark or too light, that is `mode` (`"dark"` / `"light"`), not
`colors`; if you dislike the palette itself, pick another `theme`.

## My settings do not seem to be read

`justfeed --list` prints the path of the file it actually read — edit that one. The usual cause is a
second copy of the file somewhere else in your home directory.

A single wrong value does not stop the app: an unknown `theme`, `mode` or `colors` falls back to the
default silently, which looks exactly like "the setting was ignored".

## Since the rename from tuifeed

The configuration moved to `~/.config/justfeed/config.toml` in 2.0.0, and the old file is **not**
read any more. If the app starts with the template instead of your feeds, that is the reason — copy
the old file over or fill the template in again. The feeds themselves are unchanged.

## Which binary is running (two installations)

`cargo install` puts justfeed in `~/.cargo/bin`, the installer in `~/.local/bin`. Both can be on your
`PATH`, and whichever comes first wins, so an update can look like it did nothing. `justfeed -V` and
`type -a justfeed` are the reliable answer. See [Installing](installing.md#uninstalling).

## A key does nothing

`?` lists the keys of the screen you are on. Two by-design cases: with `--feed` the article column
always holds the focus, so `Tab` / `←` / `→` do nothing; and an empty article list has nothing to
select. When you want to know what your terminal actually sends for a key or a click, the event log
in [Development](development.md#diagnosing-input) prints every event.

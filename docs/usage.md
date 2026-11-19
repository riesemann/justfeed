# Using it

The full **key list** is in the [README](../README.md#controls); this page explains the screens and
the behaviour behind the keys.

## The two screens

**Default** — the feed list on the left, the articles of the opened feed on the right:

```
justfeed
```

`Tab` / `←` / `→` move the focus between the two columns, `Enter` opens the feed under the cursor and
puts the focus on its articles. The first configured feed opens on start, so its articles are there
without an extra keypress; the row behind the feed's name shows how many articles are used
(see [Configuration](configuration.md) for `max`).

**One feed, full width** — with `--feed`, the feed list is gone and the articles use the whole
window:

```
justfeed -f Heise
```

The article column always holds the focus there, so `Tab` / `←` / `→` do nothing, while `↑` / `↓`,
`/`, `r` and `Enter` work as usual.

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

## Searching

`/` starts a filter over the article list; typing filters live, `Enter` commits it and `Esc` discards
it. Once committed, `Esc` resets it and the whole list comes back. The `?` overlay shows the keys of
whatever screen you are on.

## Opening an article

`Enter` (or a left click) hands an article's address to the system's browser — but only when it is an
`http` or `https` address. Feed content is untrusted: a link with another scheme (`file:`, `smb:`, …)
would reach whatever program is registered for that scheme, and a value like `-x` would arrive at the
opener as an option instead of a URL. Such a link is refused, and the footer says so until the next
keypress — as does a browser that cannot be started. The same line carries a failed feed.

Mouse reporting is on, so hold `Shift` while dragging to select text with the terminal.

## Command line

```
justfeed                     # two columns: feed list on the left, articles on the right
justfeed -f Heise            # this feed only: no list, articles across the whole window
justfeed --feed 2            # the same via the number from --list
justfeed -l                  # list the configured feeds and exit
justfeed -V                  # print the version
justfeed --help              # usage and options
```

With `--feed <NR|NAME>` (`-f`) the feed is given either as the number from `--list` or as the `name`
from the configuration (case-insensitive); a feed without a `name` can only be addressed by its
number. If nothing matches, justfeed names the available feeds (exit code 2) without taking over the
terminal.

`--list` (`-l`) shows which feeds are configured — number, name and the respective `max`:

```
Configuration: /home/…/.config/justfeed/config.toml

2 feeds:

   1. Heise   (max 50)
   2. 9to5Linux

Show one of them directly:  justfeed --feed <NR|NAME>
```

It starts no interface and fetches nothing from the network, which also makes it the quickest way to
check that your configuration is the one the app reads.

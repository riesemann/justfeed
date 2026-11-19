# Development

For working on the source rather than using the binary. Building and running it:

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
[`fixtures/README.md`](../fixtures/README.md) for where they come from and how to replace one.

The rest of this file is about checking behaviour without a screen and about shipping a release.

## Checking a run without a screen

`scripts/pty_run.py` starts the binary in a pty of a fixed size (100×30), sends a key sequence after
a delay, quits with `q` and prints everything the program drew — so a run can be checked without a
screen:

```
python3 scripts/pty_run.py <XDG_CONFIG_HOME> ./target/debug/justfeed 12 $'\x1b[B\r'
```

Note: `Enter` in a pty is a CR (`\r`), not an LF (`\n`) — with `\n`, for example, an open search
stays open and the final `q` types into the search instead of quitting.

## Diagnosing input

To see what your terminal actually sends for a key or a click, set `JUSTFEED_EVENT_LOG` and read the
file afterwards:

```
JUSTFEED_EVENT_LOG=/tmp/justfeed-events.log cargo run
```

Every `Event::Key` / `Event::Mouse` is appended with the state before and after it is handled.

## Cutting a release

`.github/workflows/release.yml` runs on every `v*` tag: it runs the tests, builds the binary, packs
the archive (the binary plus the README, the changelog and the licence), writes its `.sha256` and
publishes all of it as a GitHub release — with that version's section of
[CHANGELOG.md](../CHANGELOG.md) as the notes, and a failure when that section is missing. It also
attaches `justfeed-installer.sh`, the same `scripts/install.sh` a user gets from the release.

`workflow_dispatch` runs the same build without a tag and leaves the archive as a workflow artifact,
for a dry run. The release steps are skipped in that case.

The release ritual around it — the changelog section, the version in `Cargo.toml` and the README, the
annotated tag — is the maintainer's, and [Installing](installing.md) describes what the resulting
artifacts are.

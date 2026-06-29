# ZeroClaw Magisk

ARM64 Android Magisk/KernelSU/Next SU module builder for ZeroClaw.

This repository does not fork ZeroClaw source code. GitHub Actions builds from official upstream release tags at `zeroclaw-labs/zeroclaw`, overlays the Magisk packaging files, then publishes a release with the same tag.

## Release flow

- Scheduled workflow checks latest upstream `v*` tag daily.
- If this repo has no release with that tag, it builds `zeroclaw-magisk.zip`.
- Manual workflow can build a specific upstream tag.

## Runtime behavior

- Installs `/system/bin/zeroclaw`.
- Starts gateway dashboard after Android boot completes.
- Restarts ZeroClaw if it crashes, with backoff up to 60 seconds.
- Stores config/state in `/data/adb/zeroclaw`.
- Writes logs to `/data/local/tmp/zeroclaw/zeroclaw.log`.
- Root manager WebUI opens `http://127.0.0.1:42617/`.
- Root manager action button shows a color-coded ZeroClaw health report.

Disable autostart:

```sh
touch /data/adb/zeroclaw/disable-autostart
```

## Manual build in Actions

Open **Actions → Release Magisk Module → Run workflow**.

- `upstream_tag` empty: build latest upstream tag.
- `upstream_tag=v0.8.2`: build specific tag.
- `force=true`: rebuild even if release exists.

## Termux CLI wrapper

Install this optional wrapper so `zeroclaw ...` works from Termux without typing `su -c` each time:

```sh
curl -L https://raw.githubusercontent.com/greencabe/zeroclaw-magisk/main/packaging/termux/zeroclaw -o $PREFIX/bin/zeroclaw
chmod +x $PREFIX/bin/zeroclaw
```

Examples:

```sh
zeroclaw status
zeroclaw self-test
zeroclaw doctor
zeroclaw gateway get-paircode --new
```

The wrapper still uses root internally because module files and config live under `/data/adb`.

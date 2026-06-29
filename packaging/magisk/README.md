# ZeroClaw Magisk Module

Installs ZeroClaw on ARM64 Android devices and starts the gateway dashboard at boot.

## Build

```sh
./packaging/magisk/build-module.sh
```

Output:

```text
dist/magisk/zeroclaw-magisk.zip
```

## Install

Install the zip in Magisk, KernelSU, or Next SU module manager, then reboot.

## Runtime paths

- Binary: `/system/bin/zeroclaw`
- Config/state: `/data/adb/zeroclaw`
- PID file: `/data/adb/zeroclaw/zeroclaw.pid`
- Disable autostart: `touch /data/adb/zeroclaw/disable-autostart`
- Boot log: `/data/local/tmp/zeroclaw/zeroclaw.log`
- WebUI: opens `http://127.0.0.1:42617/`
- Action button: color-coded health check
- CLI tool shims: `/data/adb/zeroclaw/bin`
- Rotated log: `/data/local/tmp/zeroclaw/zeroclaw.log.1`

## Dashboard

The module builds ZeroClaw with `embedded-web`, so the dashboard assets are compiled into the binary. Boot script runs this under a crash-restart watchdog:

```sh
zeroclaw --config-dir /data/adb/zeroclaw gateway start
```

## Termux CLI wrapper

Optional wrapper after installing the module:

```sh
cp /data/adb/modules/zeroclaw/termux-wrapper.sh $PREFIX/bin/zeroclaw
chmod +x $PREFIX/bin/zeroclaw
```

Then use:

```sh
zeroclaw status
zeroclaw self-test
```

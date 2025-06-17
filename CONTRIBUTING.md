# Contributing to Stand-Up Timer

Stand-Up Timer is a [Flutter] desktop application.

## Test

To test the application, run:

```shell
# Run tests
flutter test

# Analyze code
flutter analyze
```

## Build

To build the application locally, run:

```shell
flutter build linux
```

## Package

To package Stand-Up Timer, install [`snapcraft`][snapcraft] and run:

```shell
snapcraft pack
```

The above command will create a `standup-timer_*.snap` file, install it with
`snap`:

```shell
sudo snap install --dangerous ./standup-timer_*.snap
```

[flutter]: https://flutter.dev/
[snapcraft]: https://github.com/canonical/snapcraft

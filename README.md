# swift-scripts

## Swift

### Linter / Formatter

```shell
swift format lint -r --strict ./src
swift format format -i ./src/<TARGET>.swift
swift format format -i -r -p ./src
```

## ime-status

### Build

```shell
swiftc -O ./src/ime-status.swift -o ./bin/ime-status
```

### Run

```shell
$ ./bin/ime-status
com.apple.inputmethod.Kotoeri.RomajiTyping.Roman
com.apple.inputmethod.Roman
Romaji
```

## ime-switch

### Build

```shell
swiftc -O ./src/ime-switch.swift -o ./bin/ime-switch
```
### Run

```shell
$ ./bin/ime-switch com.apple.inputmethod.Kotoeri.RomajiTyping.Roman Romaji
```


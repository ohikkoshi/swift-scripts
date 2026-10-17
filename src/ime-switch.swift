#!/usr/bin/swift
import Carbon
import CoreGraphics
import Foundation

func property(
    _ source: TISInputSource,
    _ key: CFString
) -> String {
    guard let value = TISGetInputSourceProperty(source, key) else {
        return ""
    }
    return Unmanaged<CFString>
        .fromOpaque(value)
        .takeUnretainedValue() as String
}

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: ime-switch <sourceId> <name or keycode>\n", stderr)
    exit(1)
}

let sourceId = CommandLine.arguments[1]
let name = CommandLine.arguments[2]

let sources =
    TISCreateInputSourceList(nil, true)
    .takeRetainedValue() as! [TISInputSource]

guard
    let source = sources.first(where: {
        property($0, kTISPropertyInputSourceID) == sourceId
    })
else {
    fputs("Input source not found: \(sourceId)\n", stderr)
    exit(1)
}

if TISSelectInputSource(source) != noErr {
    fputs("Failed to select input source\n", stderr)
    exit(1)
}

let keyCode: CGKeyCode

switch name {
case "Hiragana", "Kana":
    keyCode = 104  // JIS Kana
case "Romaji", "Roman", "Eisu":
    keyCode = 102  // JIS Eisu
default:
    guard let code = UInt16(name) else {
        exit(1)
    }
    keyCode = CGKeyCode(code)
}

guard
    let down = CGEvent(
        keyboardEventSource: nil,
        virtualKey: keyCode,
        keyDown: true
    ),
    let up = CGEvent(
        keyboardEventSource: nil,
        virtualKey: keyCode,
        keyDown: false
    )
else {
    exit(1)
}

down.post(tap: .cghidEventTap)
up.post(tap: .cghidEventTap)

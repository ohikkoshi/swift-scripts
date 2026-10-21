#!/usr/bin/swift
import Carbon

guard let unmanaged = TISCopyCurrentKeyboardInputSource() else {
    print("unknown")
    exit(1)
}

defer { unmanaged.release() }

let source = unmanaged.takeRetainedValue()

func getString(_ key: CFString) -> String {
    guard let value = TISGetInputSourceProperty(source, key) else {
        return ""
    }
    return Unmanaged<CFString>
        .fromOpaque(value)
        .takeUnretainedValue() as String
}

let modeId = getString(kTISPropertyInputModeID)
print(modeId)

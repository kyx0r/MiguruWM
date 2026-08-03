EmptyGUID := ParseGUID("{00000000-0000-0000-0000-000000000000}")

ParseGUID(stringified) {
    guid := Buffer(16)
    DllCall(
        "ole32.dll\CLSIDFromString",
        "Str", stringified,
        "Ptr", guid,
        "HRESULT",
    )
    return StrGet(guid, -guid.Size / 2, "utf-16")
}

;; True for HRESULTs meaning "this query can't be answered right now": the
;; window died, the shell is busy switching desktops, or the COM proxy went
;; away. Callers should treat those as "unknown desktop" and retry later.
IsTransientVDError(number) {
    switch number & 0xFFFFFFFF {
    case 0x8002802B, ;; E_ELEMENTNOTFOUND
         0x80004005, ;; E_FAIL
         0x80070005, ;; E_ACCESSDENIED
         0x80070057, ;; E_INVALIDARG
         0x8007139F, ;; E_NOT_VALID_STATE
         0x800706BA, ;; RPC_S_SERVER_UNAVAILABLE
         0x80010105, ;; RPC_E_SERVERFAULT
         0x80010108, ;; RPC_E_DISCONNECTED
         0x800401FD: ;; CO_E_OBJNOTCONNECTED
        return true
    }
    return false
}

StringifyGUID(guid) {
    ptr := 0
    if guid is Integer {
        ptr := guid
    } else if guid is String {
        ptr := StrPtr(guid)
    } else if guid is Buffer {
        ptr := guid.Ptr
    } else {
        return ""
    }

    len := StrLen("{________-____-____-____-____________}") + 1
    VarSetStrCapacity(&stringified, len)
    DllCall(
        "ole32.dll\StringFromGUID2",
        "Ptr", ptr,
        "Ptr", StrPtr(stringified),
        "Int", len,
        "Int",
    )
    return StrGet(StrPtr(stringified))
}

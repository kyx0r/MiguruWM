class IVirtualDesktop_19044 extends IUnknown {
    static GUID    := "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}"
    static Methods := [
        "IsViewVisible",
        "GetId",
    ]

    IsViewVisible(view) {
        ret := 0
        this._funcs["IsViewVisible"](
            "Ptr", view,
            "Int*", &ret,
            "HRESULT",
        )
        return ret > 0
    }

    GetId() {
        desktopId := Buffer(16)
        this._funcs["GetId"](
            "Ptr", desktopId,
            "HRESULT",
        )
        return StrGet(desktopId, -desktopId.Size / 2, "utf-16")
    }
}

class IVirtualDesktop2_19044 extends IVirtualDesktop_19044 {
    static GUID    := "{31EBDE3F-6EC3-4CBD-B9FB-0EF6D09B41F4}"
    static Methods := [
        "GetName",
    ]

    GetName() {
        hstr := 0
        this._funcs["GetName"](
            "Ptr*", &hstr,
            "HRESULT",
        )
        if !hstr {
            return ""
        }
        len := 0
        str := DllCall(
            "combase\WindowsGetStringRawBuffer",
            "Ptr", hstr,
            "UInt*", &len,
            "Ptr",
        )
        return StrGet(str)
    }
}

class IVirtualDesktop_22000 extends IVirtualDesktop2_19044 {
    static GUID    := "{536D3495-B208-4CC9-AE26-DE8111275BF8}"
    static Methods := [
        "Unknown1",
        "GetName",
        "GetWallpaperPath",
    ]

    GetWallpaperPath() {
        hstr := 0
        this._funcs["GetWallpaperPath"](
            "Ptr*", &hstr,
            "HRESULT",
        )
        if !hstr {
            return ""
        }
        len := 0
        str := DllCall(
            "combase\WindowsGetStringRawBuffer"
            "Ptr", hstr,
            "UInt*", &len,
            "Ptr",
        )
        return StrGet(str)
    }
}

class IVirtualDesktop_26100 extends IVirtualDesktop_22000 {
    static GUID    := "{3F07F4BE-B107-441A-AF0F-39D82529072C}"
    static Methods := [
        ;HRESULT Proc3([in] IApplicationView* p0, [out] int* p1);
        ;HRESULT Proc4([out] GUID* p0);
        ;HRESULT Proc5([out] FC_USER_MARSHAL** p0);
        ;HRESULT Proc6([out] FC_USER_MARSHAL** p0);
    ]
}

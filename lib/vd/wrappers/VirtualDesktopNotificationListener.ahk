IID_IVirtualDesktopNotification_19044  := "{C179334C-4295-40D3-BEA1-C654D965605A}"
IID_IVirtualDesktopNotification2_19044 := "{1BA7CF30-3591-43FA-ABFA-4AAF7ABEEDB7}"
IID_IVirtualDesktopNotification_26100  := "{B9E5E94D-233E-49AB-AF5C-2B4541C3AADE}"

class VirtualDesktopNotificationListener extends ComObjectImpl {
    static VTables := Map(
        IID_IVirtualDesktopNotification_19044, [
            "VirtualDesktopCreated",
            "VirtualDesktopDestroyBegin",
            "VirtualDesktopDestroyFailed",
            "VirtualDesktopDestroyed",
            "ViewVirtualDesktopChanged",
            "CurrentVirtualDesktopChanged",
            "VirtualDesktopRenamed",
        ],
        IID_IVirtualDesktopNotification2_19044, IID_IVirtualDesktopNotification_19044,
        IID_IVirtualDesktopNotification_26100, [
            "VirtualDesktopCreated",
            "VirtualDesktopDestroyBegin",
            "VirtualDesktopDestroyFailed",
            "VirtualDesktopDestroyed",
            "Unknown1",
            "VirtualDesktopRenamed",
            "ViewVirtualDesktopChanged",
            "CurrentVirtualDesktopChanged",
            "Unknown2",
        ],
    )

    __New(callback) {
        super.__New()
        this.callback := callback
    }

    VirtualDesktopCreated(desktop) {
        this.callback.Call("desktop_created", {
            desktop: VirtualDesktop(desktop),
        })
    }

    VirtualDesktopDestroyBegin(desktop, fallback) {
        this.callback.Call("desktop_destroy_begin", {
            desktop: VirtualDesktop(desktop),
            fallback: VirtualDesktop(fallback),
        })
    }

    VirtualDesktopDestroyFailed(desktop, fallback) {
        this.callback.Call("desktop_destroy_failed", {
            desktop: VirtualDesktop(desktop),
            fallback: VirtualDesktop(fallback),
        })
    }

    VirtualDesktopDestroyed(desktop, fallback) {
        this.callback.Call("desktop_destroyed", {
            desktop: VirtualDesktop(desktop),
            fallback: VirtualDesktop(fallback),
        })
    }

    ViewVirtualDesktopChanged(view) {
        this.callback.Call("view_changed", {
            view: ApplicationView(view),
        })
    }

    CurrentVirtualDesktopChanged(desktopFrom, desktopTo) {
        this.callback.Call("desktop_changed", {
            now: VirtualDesktop(desktopTo),
            was: VirtualDesktop(desktopFrom),
        })
    }

    VirtualDesktopRenamed(desktop, hstr) {
        len := 0
        str := DllCall(
            "combase\WindowsGetStringRawBuffer",
            "Ptr", hstr,
            "UInt*", len,
            "Ptr",
        )
        this.callback.Call("desktop_renamed", {
            desktop: VirtualDesktop(desktop),
            name: StrGet(str),
        })
    }

    Unknown1(desktop, n1, n2) {
        Msgbox(n1)
        Msgbox(n2)
    }

    Unknown2(desktop, hstr) {
        len := 0
        str := DllCall(
            "combase\WindowsGetStringRawBuffer",
            "Ptr", hstr,
            "UInt*", len,
            "Ptr",
        )
        msgbox(StrGet(str))
    }
}

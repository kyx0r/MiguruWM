#Requires AutoHotkey v2
#SingleInstance force
#WinActivateForce
#Warn VarUnset, Off
A_MaxHotkeysPerInterval := 1000
KeyHistory(0), ListLines(false), ProcessSetPriority("H")

; Modifier used by the #HotIf contexts below. Must be assigned before any code
; that can pump messages (e.g. MiguruWM()), otherwise a key press can evaluate
; the #HotIf expression while mod1 is still unset.
global mod1 := "Alt"

#include *i lib\miguru\miguru.ahk
#include *i lib\Popup.ahk
#include macros.ahk

GroupAdd("MIGURU_MANAGE",                                       " ahk_exe mintty.exe"                                                 )
GroupAdd("MIGURU_MANAGE", "Window Spy for AHKv2"                                                                                      )
GroupAdd("MIGURU_MANAGE",                                       " ahk_exe SnippingTool.exe"                                           )
GroupAdd("MIGURU_MANAGE",                                       " ahk_exe chrome.exe"                                                 )
GroupAdd("MIGURU_MANAGE",                                       " ahk_exe explorer.exe"                                               )

GroupAdd("MIGURU_AUTOFLOAT", "Window Spy for AHKv2"                                                                                   )
GroupAdd("MIGURU_AUTOFLOAT",                                    " ahk_exe SnippingTool.exe"                                           )
GroupAdd("MIGURU_DECOLESS",                                     " ahk_exe mintty.exe"                                                 )

if !IsSet(MiguruWM) {
    prog := RegExReplace(A_ScriptName, "i)\.ahk$", ".exe")
    if FileExist(prog) {
        Run(prog)
    }
    ExitApp()
}

layouts := [
    TallLayout(),
    FullscreenLayout(),
    FloatingLayout(),
]

mwm := { __Call: (name, params*) => } ; Ignore requests while mwm isn't ready yet
mwm := MiguruWM({
    layout: layouts[1],
    showPopup: (text, opts) => Popup(text, ObjMerge({
        duration: 500,
        showIcon: true,
    }, opts)),
    ;; …see https://github.com/imawizard/MiguruWM/wiki/Configuration
})

MiguruWM.SetupTrayMenu()

; Use Alt as modifier but disable it if pressed alone (mod1 set at top)
Alt::return

; Keybindings .............................................................{{{1

#Hotif GetKeyState(mod1, "P") and !GetKeyState("Shift", "P")

*1::mwm.Do("focus-workspace", { workspace: 1 })
*2::mwm.Do("focus-workspace", { workspace: 2 })
*3::mwm.Do("focus-workspace", { workspace: 3 })
*4::mwm.Do("focus-workspace", { workspace: 4 })
*5::mwm.Do("focus-workspace", { workspace: 5 })
*6::mwm.Do("focus-workspace", { workspace: 6 })
*7::mwm.Do("focus-workspace", { workspace: 7 })
*8::mwm.Do("focus-workspace", { workspace: 8 })
*9::mwm.Do("focus-workspace", { workspace: 9 })

*w::mwm.Do("focus-monitor", { monitor: 1 })
*e::mwm.Do("focus-monitor", { monitor: 2 })
*r::mwm.Do("focus-monitor", { monitor: 3 })

*j::mwm.Do("focus-window", { target: "next"     })
*k::mwm.Do("focus-window", { target: "previous" })
*m::mwm.Do("focus-window", { target: "master" })

*l::mwm.Set("master-size", { delta:  0.025 })
*h::mwm.Set("master-size", { delta: -0.025 })

*,::mwm.Set("master-count", { delta:  1 })
*.::mwm.Set("master-count", { delta: -1 })

*t::mwm.Do("float-window", { value: "toggle" }), mwm.Do("center-window")

*q::Reload()

*Enter::mwm.Do("swap-window", { with: "master" })
*s::mwm.Do("cycle-layout", { value: layouts })

^*vk01::MoveActiveWindow()
^*vk02::ResizeActiveWindow()

*F1::Logger.ToggleConsole()
*F2::mwm.Do("get-workspace-info")
*F3::mwm.Do("get-monitor-info")

#Hotif GetKeyState(mod1, "P") and GetKeyState("Shift", "P")

*1::mwm.Do("send-to-workspace", { workspace: 1 })
*2::mwm.Do("send-to-workspace", { workspace: 2 })
*3::mwm.Do("send-to-workspace", { workspace: 3 })
*4::mwm.Do("send-to-workspace", { workspace: 4 })
*5::mwm.Do("send-to-workspace", { workspace: 5 })
*6::mwm.Do("send-to-workspace", { workspace: 6 })
*7::mwm.Do("send-to-workspace", { workspace: 7 })
*8::mwm.Do("send-to-workspace", { workspace: 8 })
*9::mwm.Do("send-to-workspace", { workspace: 9 })

*w::mwm.Do("send-to-monitor", { monitor: 1 })
*e::mwm.Do("send-to-monitor", { monitor: 2 })
*r::mwm.Do("send-to-monitor", { monitor: 3 })

*j::mwm.Do("swap-window", { with: "next"     })
*k::mwm.Do("swap-window", { with: "previous" })

*c::try WinClose("A")
*q::ExitApp()

*Enter::Manage()
*Space::ResetLayout()

; ..........................................................................}}}

; Helper functions ........................................................{{{1

ResetLayout() {
    defaults := mwm.Options

    mwm.Set("layout", { value: defaults.layout })
    mwm.Set("master-size", { value: defaults.masterSize })
    mwm.Set("master-count", { value: defaults.masterCount })
    mwm.Set("padding", { value: defaults.padding })
    mwm.Set("spacing", { value: defaults.spacing })
}

GetSHAppFolderPath(hwnd := 0) {
    if !hwnd {
        hwnd := WinExist("A")
    }
    res := ""
    app := ComObject("Shell.Application")
    for window in app.Windows {
        if window && window.hwnd == hwnd {
            res := window.Document.Folder.Self.Path
            break
        }
    }
    return res
}

Manage() {
    try hwnd := WinExist("A")
    if hwnd {
       w := mwm._manage(EV_WINDOW_FOCUSED, hwnd, -1, 1)
       if w != "" {
            mwm._onWindowEvent(EV_WINDOW_REPOSITIONED, hwnd)
       }
    }
}

OpenTaskView() {
    Send("#{Tab}")
}

ShowDesktop() {
    Send("#d")
}

MoveActiveWindow() {
    MouseGetPos(, , &hwnd)
    if !hwnd {
        return
    }
    WinActivate("ahk_id" hwnd)
    mwm.Do("float-window", { hwnd: hwnd, value: true })
    PostMessage(WM_SYSCOMMAND, SC_MOVE,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYDOWN,    VK_LEFT,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYUP,      VK_LEFT,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYDOWN,    VK_RIGHT, , , "ahk_id" hwnd)
    PostMessage(WM_KEYUP,      VK_RIGHT, , , "ahk_id" hwnd)
    KeyWait("vk01")
    Send("{vk01 Up}")
}

ResizeActiveWindow() {
    MouseGetPos(, , &hwnd)
    if !hwnd {
        return
    }
    WinActivate("ahk_id" hwnd)
    mwm.Do("float-window", { hwnd: hwnd, value: true })
    PostMessage(WM_SYSCOMMAND, SC_SIZE,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYDOWN,    VK_DOWN,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYUP,      VK_DOWN,  , , "ahk_id" hwnd)
    PostMessage(WM_KEYDOWN,    VK_RIGHT, , , "ahk_id" hwnd)
    PostMessage(WM_KEYUP,      VK_RIGHT, , , "ahk_id" hwnd)
    KeyWait("vk02")
    Send("{vk01 Up}")
}

; ..........................................................................}}}

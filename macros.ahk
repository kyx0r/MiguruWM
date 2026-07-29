^Capslock::
{
	Sleep(50)
	WinMinimize("A")    ; need A to specify Active window
	return
}

^space::
{
	WinSetAlwaysOnTop(-1, "A")
}

!b::
{
	WinSetStyle("^0xC40000", "A")
	;WinHide "A"
	;WinShow "A"
}

/*
!f::
{
	if WinExist("ahk_class Shell_TrayWnd") {
		WinHide "ahk_class Shell_TrayWnd"
		;WinHide "ahk_class Shell_SecondaryTrayWnd"
	} Else {
		WinShow "ahk_class Shell_TrayWnd"
		;WinShow "ahk_class Shell_SecondaryTrayWnd"
	}
}
*/

!y::
{
	SetTitleMatchMode 2
	DetectHiddenWindows(true)
	Sleep 100
	Loop
	{
		for this_id in WinGetList("Remote Desktop Connection")
		{
			; A window can vanish at any point below; losing it must not
			; kill the whole keep-alive loop.
			try {
				; Try to activate and restore the window if it's minimized
				FocusedHwnd := ControlGetHwnd("IHWindowClass1", "ahk_id " this_id)
				state := WinGetMinMax("ahk_id " this_id)
				if (state = -1)
					WinActivate("ahk_id " this_id)
				FocusedClassNN := ControlGetClassNN(FocusedHwnd)
				ControlShow(FocusedClassNN, "ahk_id " this_id)
				ControlFocus(FocusedClassNN, "ahk_id " this_id)
				ControlSend("{Shift}", FocusedClassNN, "ahk_id " this_id)
				if (state = -1)
					WinMinimize("ahk_id " this_id)
			} catch Error {
				continue
			}
		}
		;Sleep(10000)
		Sleep(280000)
	}
	return
}

/*
!t::
{
	Loop {
		Send "^{s}"
		Sleep 1000
		Send "{Enter}"
		Sleep 1000
		Send "{n}"
		Sleep 2500
	}
}
*/

^!t::
{
	pass := EnvGet("rdppass")
	if pass == "" {
		MsgBox("rdppass is not set")
		return
	}
	Run "C:\Users\win\Desktop\eng36.rdp"
	;; Without a timeout this waits forever and leaves the thread hanging.
	if !WinWaitActive("ahk_exe CredentialUIBroker.exe", , 30) {
		return
	}
	Sleep(1500)
	;; Bail out if the prompt lost focus in the meantime, so that the
	;; password can't end up in whatever window is active now.
	if !WinActive("ahk_exe CredentialUIBroker.exe") {
		return
	}
	ControlSendText(pass, , "ahk_exe CredentialUIBroker.exe")
	Sleep(1500)
	ControlSend("{Enter}", , "ahk_exe CredentialUIBroker.exe")
}

#SuspendExempt
!o::Suspend  ; Alt+O
#SuspendExempt False

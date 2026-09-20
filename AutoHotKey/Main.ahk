#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Warn All

; ==============================================================
; HOTKEY & AUTOMATION REFERENCE
;   Alt+E      :: Reset / Restart File Explorer
;   Ctrl+Alt+D :: Run hidden Kill_Dock.bat
;   Shift+Del  :: Disable permanent delete (skip shift‑delete)
;   Ctrl+Alt+P :: Copy active window process name to clipboard
;   Alt+Q      :: Send Alt+F4 (close active window)
;   Alt+T      :: Open Windows Terminal
;   Alt+D      :: Launch MyDockFinder Dock_64.exe
;   Ctrl+Alt+R :: Reload this script
;   [Auto]     :: Automatically triggers Win+Home when maximizing any window
; ==============================================================

; ==============================================================
; File Explorer Resetter
; ==============================================================
!e:: {
    ; Close all CabinetWClass (File Explorer) windows
    while HWND := WinExist("ahk_class CabinetWClass") {
        WinClose(HWND)
        Sleep(50) ; Short pause for clean window destruction
    }
    ; Wait max 1s until all explorer windows report closed
    WinWaitClose("ahk_class CabinetWClass",, 1)
    ; Spawn fresh File Explorer
    Run("explorer.exe")
}

; ==============================================================
; Dock Utilities
; ==============================================================
^!d:: Run('C:\Scripts\Kill_Dock.bat',, "Hide")
!d:: Run('"C:\Program Files (x86)\Steam\steamapps\common\MyDockFinder\Dock_64.exe"')

; ==============================================================
; Accessibility: Disable permanent Shift+Delete
; ==============================================================
+Delete:: {
    SendInput "{Blind}{Shift Up}{Delete}"
}

; ==============================================================
; Utility: Copy active window process name to clipboard
; ==============================================================
^!p:: {
    try {
        exeName := WinGetProcessName("A")
        A_Clipboard := exeName
        ToolTip(exeName " copied!")
        SetTimer(ToolTip, -1500)
    }
    catch TargetError {
        ToolTip("No active window found.")
        SetTimer(ToolTip, -1500)
    }
}

; ==============================================================
; Window Management
; ==============================================================
!q:: Send("{Blind}{F4}") ; Alt+F4 close active window

; --- Auto-Minimize Background Windows on Maximize ---
SetTimer(CheckMaximizedState, 250)

CheckMaximizedState() {
    static lastMaximizedHWND := 0
    
    try {
        activeHWND := WinExist("A")
        if (!activeHWND)
            return

        ; Check if active window is Maximized (MinMax status = 1)
        winStatus := WinGetMinMax(activeHWND)
        
        ; If active window is maximized and wasn't the last one processed
        if (winStatus == 1 && activeHWND != lastMaximizedHWND) {
            lastMaximizedHWND := activeHWND
            
            ; Trigger Win + Home to minimize all background windows
            Send("#{Home}")
        }
        ; Reset tracking if active window is no longer maximized
        else if (winStatus != 1 && activeHWND == lastMaximizedHWND) {
            lastMaximizedHWND := 0
        }
    }
}

; ==============================================================
; Application Launchers
; ==============================================================
!t:: Run("wt.exe") ; Windows Terminal

; ==============================================================
; Script Control
; ==============================================================
^!r:: Reload()

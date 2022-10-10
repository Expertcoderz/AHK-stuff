#Warn
#Requires AutoHotkey v2.0-beta
#SingleInstance Force

;@Ahk2Exe-SetMainIcon WhatsAppTray.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription AHK WhatsApp Tray
;@Ahk2Exe-SetVersion 1.0.0

WIN_TITLE := "^WhatsApp$ ahk_class ^Chrome_WidgetWin_1$"

do_auto_hide := true

A_IconTip := "WhatsApp"
;TraySetIcon "WhatsAppTray.png"
SetTitleMatchMode "RegEx"
DetectHiddenWindows true

A_TrayMenu.Delete()
A_TrayMenu.Add("Open WhatsApp", App_Open)
A_TrayMenu.Add("Quit WhatsApp", App_Quit)
A_TrayMenu.Add("Hide automatically", ToggleAutoClose)

A_TrayMenu.Default := "Open WhatsApp"
if do_auto_hide
    A_TrayMenu.ToggleCheck("Hide automatically")

App_Open(*) {
    WinShow WIN_TITLE
    WinActivate WIN_TITLE
}

App_Quit(*) {
    WinClose WIN_TITLE
    if MsgBox("Would you also like to terminate AHK WhatsApp Tray?`n`nOtherwise, it will continue to run in the background while waiting for WhatsApp to be reopened.", "WhatsApp Tray", "YesNo Icon? Default2 262144") = "Yes"
        ExitApp
}

ToggleAutoClose(*) {
    A_TrayMenu.ToggleCheck("Close automatically")
    global do_auto_hide := !do_auto_hide
}

waitForFullyDefocused() {
    Sleep 500
    static CORE_WINDOWS := [
        "ahk_class Shell_TrayWnd",                  ; Taskbar
        "ahk_class Windows.UI.Core.CoreWindow",     ; Start menu, notifications pane and similar; also Snipping Tool
        "ahk_class XamlExplorerHostIslandWindow",   ; Alt+Tab task switcher UI
        "ahk_class AutoHotkeyGUI",
        "ahk_exe PowerToys.PowerLauncher.exe",      ; PowerToys Run
        "ahk_exe PowerToys.PowerOCR.exe",           ; PowerToys Text Extractor
        "ahk_exe PowerToys.MeasureToolUI.exe",      ; PowerToys Screen Ruler
        "ahk_exe PowerToys.ColorPickerUI.exe"       ; PowerToys Color Picker
    ]
    for winTitle in CORE_WINDOWS {
        if WinActive(winTitle) {
            WinWaitNotActive winTitle
            waitForFullyDefocused()
        }
    }
}

Loop {
    A_IconHidden := !WinExist(WIN_TITLE)
    if A_IconHidden
        WinWait WIN_TITLE
    else {
        Sleep 200
        WinWaitNotActive WIN_TITLE
        waitForFullyDefocused()
        if do_auto_hide && WinExist(WIN_TITLE) && !WinActive(WIN_TITLE) {
            WinHide WIN_TITLE
            ProcessSetPriority "BelowNormal", WinGetPID(WIN_TITLE)
            WinWaitActive WIN_TITLE
            ProcessSetPriority "AboveNormal", WinGetPID(WIN_TITLE)
        }
    }
}

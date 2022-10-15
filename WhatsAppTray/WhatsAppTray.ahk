#Warn
#Requires AutoHotkey v2.0-beta
#SingleInstance Force

;@Ahk2Exe-SetMainIcon WhatsAppTray.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription AHK WhatsApp Tray
;@Ahk2Exe-SetVersion 1.2.0

WIN_TITLE := "^WhatsApp$ ahk_class ^ApplicationFrameWindow$"

do_auto_close := true
whatsapp_exe_path := ""

Loop Files "C:\Program Files\WindowsApps\*.WhatsAppDesktop_*", "D" {
    if FileExist(A_LoopFilePath "\WhatsApp.exe") {
        whatsapp_exe_path := A_LoopFilePath "\WhatsApp.exe"
        break
    }
}
if !whatsapp_exe_path {
    A_IconHidden := true
    MsgBox "WhatsApp Desktop not found.`nTry running WhatsAppTray as an administrator or making sure that WhatsApp Desktop is installed from the Microsoft Store."
        , "WhatsApp Tray", "Iconx 262144"
    ExitApp
}

A_IconTip := "WhatsApp"
;TraySetIcon "WhatsAppTray.png"
DetectHiddenWindows true
SetTitleMatchMode "RegEx"

A_TrayMenu.Delete()
A_TrayMenu.Add("Open WhatsApp", App_Open)
A_TrayMenu.Add("Quit WhatsApp", App_Quit)
A_TrayMenu.Add("Close automatically", ToggleAutoClose)

A_TrayMenu.Default := "Open WhatsApp"
if do_auto_close
    A_TrayMenu.ToggleCheck("Close automatically")

App_Open(*) {
    if WinExist(WIN_TITLE)
        WinActivate
    else
        Run whatsapp_exe_path
}

App_Quit(*) {
    if WinExist(WIN_TITLE)
        WinClose
    if MsgBox("Exit AHK WhatsApp Tray?", "WhatsApp Tray", "YesNo Icon? Default2 262144") = "Yes"
        ExitApp
}

ToggleAutoClose(*) {
    A_TrayMenu.ToggleCheck("Close automatically")
    global do_auto_close := !do_auto_close
}

waitForFullyDefocused() {
    if !WinExist("A")
        WinWait "A"
    static CORE_WINDOWS := [
        "ahk_class Shell_TrayWnd",    ; Taskbar
        "ahk_class Windows.UI.Core.CoreWindow",    ; Start menu, notifications pane and similar; also Snipping Tool
        "ahk_class XamlExplorerHostIslandWindow",    ; Alt+Tab task switcher UI
        "ahk_class AutoHotkeyGUI",
        "ahk_exe PowerToys.PowerLauncher.exe",    ; PowerToys Run
        "ahk_exe PowerToys.PowerOCR.exe",    ; PowerToys Text Extractor
        "ahk_exe PowerToys.MeasureToolUI.exe",    ; PowerToys Screen Ruler
        "ahk_exe PowerToys.ColorPickerUI.exe"    ; PowerToys Color Picker
    ]
    for winTitle in CORE_WINDOWS {
        if WinActive(winTitle) {
            WinWaitNotActive
            waitForFullyDefocused()
        }
    }
}

WinWait WIN_TITLE
Loop {
    WinWaitNotActive WIN_TITLE
    waitForFullyDefocused()
    if do_auto_close && WinExist(WIN_TITLE) && !WinActive(WIN_TITLE) {
        WinHide
        WinClose
    }
    WinWait WIN_TITLE
    WinWaitActive WIN_TITLE
}

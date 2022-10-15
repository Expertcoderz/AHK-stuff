#Warn
#Requires AutoHotkey v2.0-beta
#NoTrayIcon
#SingleInstance Force

;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription AHK Discord Auto-Hider
;@Ahk2Exe-SetVersion 1.0.1

WIN_TITLE := "ahk_exe Discord.exe"

DetectHiddenWindows true

WinWait WIN_TITLE

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

Loop {
    WinWaitNotActive WIN_TITLE
    waitForFullyDefocused()
    if WinExist(WIN_TITLE) && !WinActive(WIN_TITLE) {
        WinHide
        ProcessSetPriority "Normal", WinGetPID()
        WinWaitActive
        ProcessSetPriority "AboveNormal", WinGetPID()
    } else
        WinWait WIN_TITLE
}

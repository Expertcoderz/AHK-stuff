#Warn
#Requires AutoHotkey v2.0-beta
#SingleInstance Force

;@Ahk2Exe-SetMainIcon WhatsAppTray.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription AHK WhatsApp Tray
;@Ahk2Exe-SetVersion 1.2.1

WIN_TITLE := "^WhatsApp$ ahk_class ^ApplicationFrameWindow$"

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
Persistent
SetTitleMatchMode "RegEx"

A_TrayMenu.Delete()
A_TrayMenu.Add("Open WhatsApp", App_Open)
A_TrayMenu.Add("Quit WhatsApp", App_Quit)
A_TrayMenu.Default := "Open WhatsApp"

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

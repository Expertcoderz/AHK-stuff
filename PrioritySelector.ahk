#Warn
#Requires AutoHotkey v2.0-beta
#NoTrayIcon
#SingleInstance Ignore

;@Ahk2Exe-SetMainIcon PrioritySelector.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription Process Priority Selector
;@Ahk2Exe-SetVersion 1.0.0

GetProcessPriority(PID) {
    local handle := DllCall("OpenProcess", "UInt", 0x400, "Int", 0, "UInt", PID)
    local priority := DllCall("GetPriorityClass", "UInt", handle)
    DllCall "CloseHandle", "UInt", handle
    return { 0: 0, 64: 1, 16384: 2, 32: 3, 32768: 4, 128: 5, 256: 6 }.%priority%
}

class PrioritySelector extends Gui {
    __New(pid := WinGetPID("A")) {
        if !pid {
            SoundPlay "*64"
            ExitApp
        }
        super.__New("+AlwaysOnTop -SysMenu -MinimizeBox +Owner", "Set Process Priority", this)
        this.OnEvent("Escape", "Cancel")

        this.AddText("", Format("{1} (PID: {2})", WinGetProcessName("ahk_pid " pid), pid))

        local currentPriority := GetProcessPriority(pid)
        this.AddDropDownList(currentPriority = 0 ? "3" : "Choose" currentPriority, ["Low", "Below normal", "Normal", "Above normal", "High", "Realtime"])
            .OnEvent("Change", "Submit")

        this.AddButton("yp w70 h20 Default", "Cancel")
            .OnEvent("Click", "Cancel")

        this.pid := pid
    }

    Submit(ddl, *) {
        try ProcessSetPriority SubStr(ddl.Text, 1, 1), this.pid
        catch as e
            MsgBox e.Message, "Error", "Iconx 8192"
        this.Destroy()
    }

    Cancel(*) =>
        this.Destroy()
}

PrioritySelector().Show()

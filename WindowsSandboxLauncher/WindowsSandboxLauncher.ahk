#Warn
#Requires AutoHotkey v2.0-beta
#NoTrayIcon
#SingleInstance Off

;@Ahk2Exe-SetMainIcon WindowsSandboxLauncher.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription AHK Windows Sandbox Launcher
;@Ahk2Exe-SetVersion 1.0.0

if pid := ProcessExist("WindowsSandboxClient.exe") {
    WinActivate "ahk_pid " pid
    ExitApp
} else if hwnd := WinExist("Sandbox Options") {
    WinActivate "ahk_id " hwnd
    ExitApp
}

SANDBOX_PATH := "Sandbox.wsb"

checkbox_options := [
    {
        DisplayText: "Allow &audio input",
        TagText: "AudioInput",
        On: "Enable",
        Off: "Disable"
    },
    {
        DisplayText: "Allow &video input",
        TagText: "VideoInput",
        On: "Enable",
        Off: "Disable"
    },
    {
        DisplayText: "Allow &printer sharing",
        TagText: "PrinterRedirection",
        On: "Enable",
        Off: "Disable"
    },
    {
        DisplayText: "Allow &networking",
        TagText: "Networking",
        On: "Default",
        Off: "Disable"
     },
     {
        DisplayText: "Allow v&GPU sharing",
        TagText: "vGPU",
        On: "Enable",
        Off: "Disable"
     },
     {
        DisplayText: "Pr&otected Client",
        TagText: "ProtectedClient",
        On: "Enable",
        Off: "Disable"
     }
]

class WindowsSandboxLauncher extends Gui {
    __New() {
        super.__New("-MinimizeBox", "Sandbox Options", this)
        this.OnEvent("Escape", "Cancel")

        this.AddGroupBox("w165 r" checkbox_options.Length, "Security Options")
        for i, info in checkbox_options
            info.Checkbox := this.AddCheckbox(i = 1 ? "xp+20 yp+20" : "", info.DisplayText)

        this.AddGroupBox("xm w165 r3", "Memory Limit")
        this.AddCheckbox("xp+20 yp+20 vMemoryConfigCheckbox", "Configure &memory limit:")
        .OnEvent("Click", "ToggledMemoryConfig")
        this.AddEdit("yp+25 w70 vMemoryConfigEdit Disabled Limit Number", "2048")
        this.AddUpDown("Range1024-8192", 2048)
        this.AddText("xp+75 yp+3 wp+5 vMemoryConfigUnitText Disabled", "MB")

        this.AddButton("xm w80 h25 vLaunchButton Default", "Launch")
        .OnEvent("Click", "Launch")
        this.AddButton("yp w80 h25 vCancelButton", "Cancel")
        .OnEvent("Click", "Cancel")
    }

    ToggledMemoryConfig(checkbox, *) {
        this["MemoryConfigEdit"].Enabled := checkbox.Value
        this["MemoryConfigUnitText"].Enabled := checkbox.Value
    }

    Launch(*) {
        if FileExist(SANDBOX_PATH)
            FileDelete SANDBOX_PATH

        this["LaunchButton"].Text := "..."
        this["LaunchButton"].Enabled := false
        this["CancelButton"].Enabled := false

        this["MemoryConfigCheckbox"].Enabled := false
        this["MemoryConfigEdit"].Enabled := false
        this["MemoryConfigUnitText"].Enabled := false

        local configXml := "<Configuration>"
        local _, info
        for _, info in checkbox_options {
            info.Checkbox.Enabled := false
            configXml .= "<" . info.TagText . ">" . (info.Checkbox.Value ? info.On : info.Off) . "</" . info.TagText . ">"
        }
        if this["MemoryConfigCheckbox"].Value
            configXml .= "<MemoryInMB>" this["MemoryConfigEdit"].Value "</MemoryInMB>"
        configXml .= "</Configuration>"

        FileAppend configXml, SANDBOX_PATH
        Run SANDBOX_PATH

        WinWait "ahk_exe WindowsSandboxClient.exe"
        this.Destroy()
        ExitApp
    }

    Cancel(*) {
        this.Destroy()
        ExitApp
    }
}

WindowsSandboxLauncher().Show("Center")

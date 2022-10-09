#Warn
#Requires AutoHotkey v2.0-beta
#NoTrayIcon
#SingleInstance Ignore

;@Ahk2Exe-SetMainIcon AutoClicker.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription Advanced Auto-Clicking Utility
;@Ahk2Exe-SetVersion 1.0.0

class AutoClickerGui extends Gui {
    __new() {
        super.__New("+AlwaysOnTop -MinimizeBox", "Auto-Clicker", this)
        this.OnEvent("Escape", (*) => this.Destroy())

        this.AddText("xm ym+2", "Button:")
        this.AddDropDownList("yp-2 xm+40 vClickButtonDropDownList Choose1", ["Left", "Right", "Middle"])

        this.AddText("xm yp+25", "Mode:")
        this.AddDropDownList("yp-2 xm+40 vClickModeDropDownList Choose1", ["Single click", "Double click", "Triple click", "No click"])

        this.AddGroupBox("xm w160 h80", "Click Intervals")

        this.AddText("xm+10 yp+20", "Minimum:")
        this.AddEdit("xp+50 yp-2 w50 vClickMinIntervalEdit Limit Number", "85")
        this.AddText("xp+54 yp+2", "ms")

        this.AddText("xm+10 yp+30", "Maximum:")
        this.AddEdit("xp+50 yp-2 w50 vClickMaxIntervalEdit Limit Number", "115")
        this.AddText("xp+54 yp+2", "ms")

        this.AddGroupBox("xm w160 h92", "Stop After")

        this.AddCheckbox("xm+10 yp+20 vStopAfterNumClicksCheckbox", "No. of clicks:")
            .OnEvent("Click", "ToggledStopAfterNumClicks")
        this.AddEdit("xp+80 yp-2 w45 vStopAfterNumClicksEdit Disabled Limit Number", "50")

        this.AddCheckbox("xm+10 yp+25 vStopAfterDurationCheckbox", "Duration:")
            .OnEvent("Click", "ToggledStopAfterDuration")
        this.AddEdit("xp+65 yp-2 w45 vStopAfterDurationEdit Disabled Limit Number", "60")
        this.AddText("xp+48 yp+2 vStopAfterDurationUnitText Disabled", "s")

        this.AddDropDownList("xm+10 yp+21 w140 vStopAfterModeDropDownList Choose1 Disabled", ["Whichever comes first", "When both have passed"])

        this.AddButton("xm w160", "Configure cursor positioning")
            .OnEvent("Click", "OpenCursorPosConfigGui")

        /*this.AddGroupBox("xm w160 h75", "Hotkeys")

        this.AddCheckbox("xm+10 yp+20 vStartHotkeyCheckbox Checked", "Start:")
            .OnEvent("Click", "ToggledStartHotkey")
        this.AddHotkey("xp+50 yp-2 w90 vStartHotkey", "^F2")

        this.AddCheckbox("xm+10 yp+30 vStopHotkeyCheckbox Checked", "Stop:")
            .OnEvent("Click", "ToggledStopHotkey")
        this.AddHotkey("xp+50 yp-2 w90 vStopHotkey", "^F3")*/

        this.AddButton("xm w76 vStartButton Default", "Start")
            .OnEvent("Click", "Start")
        this.AddButton("yp w76 vStopButton Disabled", "Stop")
            .OnEvent("Click", "Stop")

        this.AddStatusBar("vStatusBar", "Clicks: 0 | Elapsed: 0.0 s")

        this.CursorPosConfigGui := false
        this.CursorPosConfigData := { BoundaryMode: 1 }

        /*this.startHotkey := "^F2"
        this.stopHotkey := "^F3"
        Hotkey this.startHotkey, this.Start
        Hotkey this.stopHotkey, this.Stop*/

        this.clickCount := 0
        this.startTime := 0
    }

    ToggledStopAfterNumClicks(checkbox, *) {
        this["StopAfterNumClicksEdit"].Enabled := checkbox.Value
        this["StopAfterModeDropDownList"].Enabled := checkbox.Value && this["StopAfterDurationEdit"].Enabled
    }

    ToggledStopAfterDuration(checkbox, *) {
        this["StopAfterDurationEdit"].Enabled := checkbox.Value
        this["StopAfterDurationUnitText"].Enabled := checkbox.Value
        this["StopAfterModeDropDownList"].Enabled := checkbox.Value && this["StopAfterNumClicksEdit"].Enabled
    }

    OpenCursorPosConfigGui(*) {
        if !this.CursorPosConfigGui
            this.CursorPosConfigGui := CursorPositionConfigurationGui(this)
        local posX
        this.GetPos(&posX)
        this.CursorPosConfigGui.Show("x" posX)
        this.Opt("+Disabled")
    }

    /*ToggledStartHotkey(checkbox, *) {
        this["StartHotkey"].Enabled := checkbox.Value
        if this.startHotkey
            Hotkey this.startHotkey, checkbox.Value ? "On" : "Off"
    }

    ChangedStartHotkey(hotkey, *) {
        if this.startHotkey
            Hotkey this.startHotkey, "Off"
        this.startHotkey := hotkey.Value
        if hotkey.Value
            Hotkey hotkey.Value, this.Start, this["StartHotkeyCheckbox"].Value ? "On" : "Off"
    }

    ToggledStopHotkey(checkbox, *) {
        this["StopHotkey"].Enabled := checkbox.Value
        if this.stopHotkey
            Hotkey this.stopHotkey, checkbox.Value ? "On" : "Off"
    }

    ChangedStopHotkey(hotkey, *) {
        if this.stopHotkey
            Hotkey this.stopHotkey, "Off"
        this.stopHotkey := hotkey.Value
        if hotkey.Value
            Hotkey hotkey.Value, this.Stop, this["StopHotkeyCheckbox"].Value ? "On" : "Off"
    }*/

    Start(*) {
        this["StartButton"].Enabled := false
        this["StopButton"].Enabled := true
        this["StopButton"].Focus()

        this.clickCount := 0
        this.startTime := A_TickCount

        while this["StartButton"] && !this["StartButton"].Enabled {
            try {
                local stopCond1 := this["StopAfterNumClicksCheckbox"].Value && this.clickCount >= this["StopAfterNumClicksEdit"].Value
                local stopCond2 := this["StopAfterDurationCheckbox"].Value && (A_TickCount - this.startTime) / 1000 >= this["StopAfterDurationEdit"].Value
                if (stopCond1 || stopCond2) && (this["StopAfterModeDropDownList"].Value = 1 || (stopCond1 && stopCond2)) {
                    this.Stop()
                    break
                }

                CoordMode "Mouse", this.CursorPosConfigData.BoundaryMode = 1 ? "Screen"
                    : this.CursorPosConfigData.%"RelativeToScreen" this.CursorPosConfigData.BoundaryMode% ? "Screen" : "Client"

                Click (this.CursorPosConfigData.BoundaryMode = 1 ? ""
                    : this.CursorPosConfigData.BoundaryMode = 2 ? this.CursorPosConfigData.XPos " " this.CursorPosConfigData.YPos
                    : Random(this.CursorPosConfigData.XMinPos, this.CursorPosConfigData.XMaxPos) " " Random(this.CursorPosConfigData.YMinPos, this.CursorPosConfigData.YMaxPos))
                    . " " this["ClickButtonDropDownList"].Text
                    . " " (this["ClickModeDropDownList"].Value = 4 ? "0" : this["ClickModeDropDownList"].Value)

                this.clickCount += 1
                this["StatusBar"].Text := Format("Clicks: {1} | Elapsed: {2:.1f} s", this.clickCount, (A_TickCount - this.startTime) / 1000)

                Sleep Random(this["ClickMinIntervalEdit"].Value, this["ClickMaxIntervalEdit"].Value)
            } catch
                break
        }
    }

    Stop(*) {
        this["StopButton"].Enabled := false
        this["StartButton"].Enabled := true
        this["StartButton"].Focus()
    }
}

class CursorPositionConfigurationGui extends Gui {
    __new(autoclickergui) {
        this.Parent := autoclickergui
        this.isActive := true

        super.__New("+AlwaysOnTop -MinimizeBox +Owner" autoclickergui.Hwnd, "Cursor Positioning", this)
        this.OnEvent("Escape", "Close")
        this.OnEvent("Close", "Close")

        this.AddText("xm ym+2", "Boundary:")
        this.AddDropDownList("xm+52 yp-2 w150 vBoundaryMode AltSubmit Choose1", [
            "(User-controlled)",
            "Fixed point",
            "Fixed box"])
            .OnEvent("Change", "ChangedModeSelection")
        this["BoundaryMode"].OnEvent("LoseFocus", "ChangedModeSelection")

        this.PerBoundaryConfigControls := [
            [],
            [
                this.AddText("xp ym+30 Hidden", "X:"),
                this.AddEdit("xp+20 yp-2 w30 vXPos Limit Number Hidden"),
                this.AddText("xp+45 yp+2 Hidden", "Y:"),
                this.AddEdit("xp+20 yp-2 w30 vYPos Limit Number Hidden"),
                this.AddGroupBox("xm+52 yp+30 w150 h60 Hidden", "Relative To"),
                this.AddRadio("xp+10 yp+20 Group vRelativeToScreen2 Checked Hidden", "Entire screen"),
                this.AddRadio("xp vRelativeToWindow2 Hidden", "Focused window")
            ],
            [
                this.AddText("xm+52 ym+30 Hidden", "X min:"),
                this.AddEdit("xp+35 yp-2 w30 vXMinPos Limit Number Hidden"),
                this.AddText("xp+45 yp+2 Hidden", "Y min:"),
                this.AddEdit("xp+35 yp-2 w30 vYMinPos Limit Number Hidden"),
                this.AddText("xm+52 yp+30 Hidden", "X max:"),
                this.AddEdit("xp+35 yp-2 w30 vXMaxPos Limit Number Hidden"),
                this.AddText("xp+45 yp+2 Hidden", "Y max:"),
                this.AddEdit("xp+35 yp-2 w30 vYMaxPos Limit Number Hidden"),
                this.AddGroupBox("xm+52 yp+30 w150 h60 Hidden", "Relative To"),
                this.AddRadio("xp+10 yp+20 Group vRelativeToScreen3 Checked Hidden", "Entire screen"),
                this.AddRadio("xp vRelativeToWindow3 Hidden", "Focused window")
            ]
        ]

        this.AddButton("yp+30 w80 Default", "OK")
            .OnEvent("Click", "Submit")
        this.AddButton("yp w80", "Cancel")
            .OnEvent("Click", "Close")

        this.AddStatusBar("vStatusBar", "")

        if autoclickergui.CursorPosConfigData.BoundaryMode != 1 {
            this["BoundaryMode"].Value := autoclickergui.CursorPosConfigData.BoundaryMode
            this.ChangedModeSelection(this["BoundaryMode"])
            switch this["BoundaryMode"].Value {
                case 2:
                    this["XPos"].Value := autoclickergui.CursorPosConfigData.XPos
                    this["YPos"].Value := autoclickergui.CursorPosConfigData.YPos
                    this["RelativeToScreen2"].Value := autoclickergui.CursorPosConfigData.RelativeToScreen2 = 1
                    this["RelativeToWindow2"].Value := autoclickergui.CursorPosConfigData.RelativeToWindow2 = 1
                case 3:
                    this["XMinPos"].Value := autoclickergui.CursorPosConfigData.XMinPos
                    this["YMinPos"].Value := autoclickergui.CursorPosConfigData.YMinPos
                    this["XMaxPos"].Value := autoclickergui.CursorPosConfigData.XMaxPos
                    this["YMaxPos"].Value := autoclickergui.CursorPosConfigData.YMaxPos
                    this["RelativeToScreen3"].Value := autoclickergui.CursorPosConfigData.RelativeToScreen3 = 1
                    this["RelativeToWindow3"].Value := autoclickergui.CursorPosConfigData.RelativeToWindow3 = 1
            }
        }
    }

    ChangedModeSelection(ddl, *) {
        for index, list in this.PerBoundaryConfigControls {
            for ctrl in list {
                if index = ddl.Value && ctrl.Visible
                    ; Don't do anything if we're already on the correct page.
                    ; This is to avoid defocusing controls on this page when this function is called on the second time;
                    ; (first time by the Change event and then by LoseFocus of the BoundaryMode DDL control)
                    ; (the latter callback is necessary due to a likely UI framework bug in which Change doesn't fire when the DDL's selection is changed by keyboard means).
                    return
                else
                    ctrl.Visible := false
            }
        }
        for ctrl in this.PerBoundaryConfigControls[ddl.Value]
            ctrl.Visible := true

        local ddl_value := ddl.Value
        if ddl_value > 1 {
            while this.isActive && ddl.Value = ddl_value {
                CoordMode "Mouse", this["RelativeToScreen" ddl_value].Value = 1 ? "Screen" : "Client"
                local x, y
                MouseGetPos &x, &y
                this["StatusBar"].Text := Format("Mouse X: {1:.0d} | Mouse Y: {2:.0d}", x, y)
                Sleep 100
            }
        } else
            this["StatusBar"].Text := ""
    }

    Submit(*) {
        if (this["BoundaryMode"].Value = 2 && !(this["XPos"].Value && this["YPos"].Value))
            || (this["BoundaryMode"].Value = 3 && !(this["XMinPos"].Value && this["YMinPos"].Value && this["XMaxPos"].Value && this["YMaxPos"].Value))
        {
            MsgBox "Missing field(s).", "Error", "Iconx 8192"
            return
        }
        this.Parent.CursorPosConfigData := super.Submit()
        this.Parent.Opt("-Disabled")
    }

    Close(*) {
        this.isActive := false
        try this.Destroy()
        this.Parent.CursorPosConfigGui := false
        try this.Parent.Opt("-Disabled")
    }
}

AutoClickerGui().Show("x0")

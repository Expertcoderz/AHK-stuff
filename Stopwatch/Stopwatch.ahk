#Warn
#Requires AutoHotkey v2.0-beta
#NoTrayIcon
#SingleInstance Off

;@Ahk2Exe-SetMainIcon Stopwatch.ico
;@Ahk2Exe-SetCompanyName Expertcoderz
;@Ahk2Exe-SetDescription Basic Stopwatch
;@Ahk2Exe-SetVersion 1.0.1

formatDuration(seconds) {
    local hours, minutes
    seconds := Mod(seconds, 24 * 3600)
    hours := seconds // 3600
    seconds := Mod(seconds, 3600)
    minutes := seconds // 60
    seconds := Mod(seconds, 60)
    return Format("{1:02d}:{2:02d}:{3:02d}", hours, minutes, seconds)
}

class StopwatchGui extends Gui {
    __New() {
        super.__New("+AlwaysOnTop -MinimizeBox", "Stopwatch", this)
        this.OnEvent("Escape", "Close")
        this.OnEvent("Close", "Close")

        this.SetFont("s30")
        this.AddText("xm y10 w162 h40 vCountText Center", "00:00:00")
        this.SetFont()

        this.AddButton("xm yp+55 w162 h25 vPauseResumeButton", "Paus&e")
            .OnEvent("Click", (button, *) => button.Text := button.Text = "R&esume" ? "Paus&e" : "R&esume")

        this.AddButton("xm yp+35 w76 h25", "&Reset")
            .OnEvent("Click", "Reset")
        this.AddButton("yp xp+86 w76 h25", "&Done")
            .OnEvent("Click", "Close")

        this.isActive := true
        this.ticksElapsed := 0
    }

    Reset(*) {
        this.ticksElapsed := 0
        this["CountText"].Text := "00:00:00"
    }

    Close(*) {
        this.isActive := false
        this.Destroy()
    }
}

stopwatch := StopwatchGui()
stopwatch.Show("x0 y30")
Loop {
    while stopwatch["PauseResumeButton"].Text = "Resum&e"
        Sleep 0
    Loop {
        startTime := A_TickCount
        Sleep 500
        if stopwatch.isActive && stopwatch["PauseResumeButton"].Text = "Paus&e" {
            stopwatch.ticksElapsed += A_TickCount - startTime
            stopwatch["CountText"].Text := formatDuration(stopwatch.ticksElapsed // 1000)
        } else
            break
    }
    if !stopwatch.isActive
        break
}

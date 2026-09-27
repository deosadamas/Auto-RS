#Requires AutoHotkey v2.0

; Thrown by Bot.Wait when the user stops the bot; unwinds the script loop cleanly.
class StopSignal extends Error {
}

; Script contract: a class with `static Name`, `static Setup()` (read config, validate)
; and `static Step()` (one unit of work; call Bot.Wait for every delay so Stop/Pause work).
class Bot {
    static running := false
    static paused := false
    static stopRequested := false
    static script := ""
    static scripts := Map()
    static cfg := ""
    static startTick := 0
    static onStatus := ""

    static Register(script) => Bot.scripts[script.Name] := script

    static Status(msg) {
        if Bot.onStatus
            Bot.onStatus.Call(msg)
    }

    ; Interruptible sleep. Bot.Wait(ms) or Bot.Wait(lo, hi) for a randomized delay.
    static Wait(lo, hi := 0) {
        ms := hi ? Round(Human.Rand(lo, hi)) : lo
        end := A_TickCount + ms
        loop {
            if Bot.stopRequested
                throw StopSignal("stop")
            if Bot.paused {
                Sleep 100
                continue
            }
            left := end - A_TickCount
            if (left <= 0)
                return
            Sleep Min(50, left)
        }
    }

    static Start(name) {
        if Bot.running
            return
        if !Bot.scripts.Has(name)
            throw ValueError("Unknown script: " name)
        Bot.script := Bot.scripts[name]
        Bot.stopRequested := false
        Bot.paused := false
        Bot.running := true
        Bot.startTick := A_TickCount
        SetTimer((*) => Bot.Run(), -1)
    }

    static TogglePause() {
        if !Bot.running
            return
        Bot.paused := !Bot.paused
        Bot.Status(Bot.paused ? "Paused" : "Running " Bot.script.Name)
        Logger.Info(Bot.paused ? "Paused" : "Resumed")
    }

    static Stop() {
        if Bot.running
            Bot.stopRequested := true
    }

    static Run() {
        Logger.Info("Starting " Bot.script.Name)
        Bot.Status("Running " Bot.script.Name)
        try {
            Screen.Focus()
            Bot.script.Setup()
            loop {
                if !WinActive(Screen.title)
                    Screen.Focus()
                AntiBan.Tick()
                Bot.script.Step()
            }
        } catch StopSignal {
            Logger.Info("Stopped by user")
        } catch Error as e {
            Logger.Error(e.Message " (" e.File ":" e.Line ")")
            Bot.Status("Error - see log")
        } finally {
            Send "{Shift up}"
            Bot.running := false
            Bot.paused := false
            Logger.Info(Format("{} ran {:.1f} min", Bot.script.Name, (A_TickCount - Bot.startTick) / 60000))
            if (Bot.stopRequested)
                Bot.Status("Idle")
        }
    }
}

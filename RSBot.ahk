#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Event"                 ; Input mode is often ignored by game clients
SetKeyDelay 30, 40
CoordMode "Mouse", "Client"      ; all coords relative to the active (game) window
CoordMode "Pixel", "Client"

#Include %A_ScriptDir%\lib\Logger.ahk
#Include %A_ScriptDir%\lib\Config.ahk
#Include %A_ScriptDir%\lib\Human.ahk
#Include %A_ScriptDir%\lib\Screen.ahk
#Include %A_ScriptDir%\lib\Inventory.ahk
#Include %A_ScriptDir%\lib\AntiBan.ahk
#Include %A_ScriptDir%\lib\Bot.ahk
#Include %A_ScriptDir%\scripts\Woodcutter.ahk
#Include %A_ScriptDir%\scripts\AutoClicker.ahk

Bot.Register(Woodcutter)
Bot.Register(AutoClicker)

Bot.cfg := Config(A_ScriptDir "\config.ini")
Screen.title := Bot.cfg.Get("General", "WindowTitle", "ahk_exe RuneLite.exe")
Logger.file := A_ScriptDir "\" Bot.cfg.Get("General", "LogFile", "bot.log")
AntiBan.Configure(Bot.cfg)

App.Build()

F1:: App.Toggle()
F2:: Bot.Stop()
F3:: App.Pick()

class App {
    static gui := ""
    static status := ""
    static logBox := ""
    static ddl := ""

    static Build() {
        names := []
        for name in Bot.scripts
            names.Push(name)

        g := Gui("+AlwaysOnTop", "Auto-RS")
        g.SetFont("s9", "Segoe UI")
        g.Add("Text", "xm", "Script:")
        App.ddl := g.Add("DropDownList", "x+8 yp-3 w200 Choose1", names)
        g.Add("Button", "xm w88", "Start/Pause F1").OnEvent("Click", (*) => App.Toggle())
        g.Add("Button", "x+6 w88", "Stop F2").OnEvent("Click", (*) => Bot.Stop())
        g.Add("Button", "x+6 w88", "Pick F3").OnEvent("Click", (*) => App.PickDelayed())
        App.status := g.Add("Text", "xm w280 h18", "Idle")
        App.logBox := g.Add("Edit", "xm w280 r12 ReadOnly -Wrap")
        g.OnEvent("Close", (*) => ExitApp())
        g.Show()
        App.gui := g

        Logger.sink := (line) => App.AppendLog(line)
        Bot.onStatus := (msg) => (App.status.Text := msg)
        Logger.Info("Ready. Window: " Screen.title (Screen.Exists() ? " (found)" : " (NOT FOUND)"))
    }

    static Toggle() {
        if Bot.running
            Bot.TogglePause()
        else
            Bot.Start(App.ddl.Text)
    }

    static AppendLog(line) {
        App.logBox.Value .= line "`r`n"
        SendMessage 0x115, 7, 0, App.logBox      ; WM_VSCROLL SB_BOTTOM
    }

    ; Copy mouse position (client coords of the active window) and pixel color.
    ; Press F3 while hovering the game so the coords match what scripts use.
    static Pick() {
        MouseGetPos &x, &y
        c := PixelGetColor(x, y)
        A_Clipboard := x "," y
        Logger.Info(Format("Picked {},{} color={} (coords copied)", x, y, c))
    }

    ; Button variant: give the user 3 s to hover the game before sampling.
    static PickDelayed() {
        Bot.Status("Hover target... 3 s")
        SetTimer(() => (App.Pick(), Bot.Status("Idle")), -3000)
    }
}

#Requires AutoHotkey v2.0

; Randomized long breaks plus occasional small idle actions between script steps.
class AntiBan {
    static nextBreak := 0
    static breakEvery := [35, 70]   ; minutes between breaks
    static breakLen := [3, 10]      ; minutes per break
    static idleChance := 4          ; % chance per step of an idle action

    static Configure(cfg) {
        AntiBan.breakEvery := [cfg.Int("AntiBan", "BreakEveryMin", 35), cfg.Int("AntiBan", "BreakEveryMax", 70)]
        AntiBan.breakLen := [cfg.Int("AntiBan", "BreakLenMin", 3), cfg.Int("AntiBan", "BreakLenMax", 10)]
        AntiBan.idleChance := cfg.Int("AntiBan", "IdleChance", 4)
        AntiBan.Schedule()
    }

    static Schedule() {
        mins := Human.Rand(AntiBan.breakEvery[1], AntiBan.breakEvery[2])
        AntiBan.nextBreak := A_TickCount + Round(mins * 60000)
        Logger.Info(Format("Next break in {:.1f} min", mins))
    }

    ; Called once per script step.
    static Tick() {
        if (A_TickCount >= AntiBan.nextBreak) {
            AntiBan.TakeBreak()
            return
        }
        if (Random(1, 100) <= AntiBan.idleChance)
            AntiBan.Idle()
    }

    static TakeBreak() {
        mins := Human.Rand(AntiBan.breakLen[1], AntiBan.breakLen[2])
        Logger.Info(Format("Break for {:.1f} min", mins))
        Bot.Status(Format("On break ({:.0f} min)", mins))
        MouseGetPos &mx, &my
        Human.MoveTo(mx + Random(-200, 200), my + Random(-150, 150))
        Bot.Wait(Round(mins * 60000))
        AntiBan.Schedule()
        Screen.Focus()
        Bot.Status("Running " Bot.script.Name)
    }

    static Idle() {
        switch Random(1, 4) {
            case 1:                         ; wander the mouse
                MouseGetPos &mx, &my
                Human.MoveTo(mx + Random(-120, 120), my + Random(-80, 80))
            case 2:                         ; nudge the camera
                Human.Press(Random(0, 1) ? "Left" : "Right", 250, 1100)
            case 3:                         ; hesitate
                Bot.Wait(700, 2500)
            case 4:                         ; hover over the inventory
                s := Inventory.slots.Length ? Inventory.slots[Random(1, 28)] : ""
                if s
                    Human.MoveTo(s[1] + Random(-8, 8), s[2] + Random(-8, 8))
                Bot.Wait(300, 900)
        }
    }
}

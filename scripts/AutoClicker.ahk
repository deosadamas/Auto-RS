#Requires AutoHotkey v2.0

; Clicks a fixed point at randomized intervals (alching, spell casting, etc).
; Tune [AutoClicker] in config.ini.
class AutoClicker {
    static Name := "AutoClicker"
    static target := [0, 0]
    static min := 1800
    static max := 3200
    static jitter := 3

    static Setup() {
        cfg := Bot.cfg
        this.target := cfg.Point("AutoClicker", "Target")
        this.min := cfg.Int("AutoClicker", "IntervalMin", 1800)
        this.max := cfg.Int("AutoClicker", "IntervalMax", 3200)
        this.jitter := cfg.Int("AutoClicker", "Jitter", 3)
        if (this.min > this.max)
            throw ValueError("[AutoClicker] IntervalMin must be <= IntervalMax")
    }

    static Step() {
        Bot.Status("Clicking " this.target[1] "," this.target[2])
        Human.Click(this.target[1], this.target[2], "Left", this.jitter)
        Bot.Wait(this.min, this.max)
    }
}

#Requires AutoHotkey v2.0

; Finds a tree by color in the viewport, clicks it, waits while chopping, and drops
; logs when the inventory fills (shift-drop on OSRS, right-click menu on RS3 - see
; [Inventory] DropMode). Tune [Woodcutter] in the active config.
; OSRS tip: use RuneLite's Object Markers plugin to outline trees in a solid unique color
; and set TreeColor to that color - far more reliable than natural tree pixels.
class Woodcutter {
    static Name := "Woodcutter"
    static treeColor := 0
    static treeTol := 12
    static region := []
    static logColor := 0
    static logTol := 10
    static chopMin := 5000
    static chopMax := 9000

    static Setup() {
        cfg := Bot.cfg
        this.treeColor := cfg.Color("Woodcutter", "TreeColor")
        this.treeTol := cfg.Int("Woodcutter", "TreeTolerance", 12)
        this.region := cfg.Region("Woodcutter", "SearchRegion")
        this.logColor := cfg.Color("Woodcutter", "LogColor")
        this.logTol := cfg.Int("Woodcutter", "LogTolerance", 10)
        this.chopMin := cfg.Int("Woodcutter", "ChopWaitMin", 5000)
        this.chopMax := cfg.Int("Woodcutter", "ChopWaitMax", 9000)
        Inventory.Configure(cfg)
        if (!this.treeColor || !this.logColor)
            throw ValueError("[Woodcutter] TreeColor and LogColor must be set (use F3 to pick)")
    }

    static Step() {
        if Inventory.IsFull(this.logColor, this.logTol) {
            Bot.Status("Dropping logs")
            Logger.Info("Inventory full - dropping " Inventory.Count(this.logColor, this.logTol) " logs")
            Inventory.DropAll(this.logColor, this.logTol)
            Bot.Wait(400, 900)
            return
        }

        if !Screen.FindRandom(this.treeColor, this.region, &x, &y, this.treeTol) {
            Bot.Status("No tree visible - waiting")
            Bot.Wait(1500, 3500)
            return
        }

        Bot.Status("Chopping tree at " x "," y)
        Human.Click(x, y)
        Bot.Wait(this.chopMin, this.chopMax)      ; walk over + first swings

        ; Keep waiting while the tree still stands and there is room for logs.
        deadline := A_TickCount + this.chopMax * 4
        while (A_TickCount < deadline) {
            if Inventory.IsFull(this.logColor, this.logTol)
                return
            if !Screen.Near(x, y, this.treeColor, this.treeTol, 10) {
                Logger.Info("Tree gone")
                return
            }
            Bot.Wait(1200, 2600)
        }
        Logger.Warn("Chop timed out - re-clicking")
    }
}

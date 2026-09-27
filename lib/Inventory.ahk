#Requires AutoHotkey v2.0

; 4x7 inventory grid helpers. Slot centers derive from [Inventory] FirstSlot/SlotDX/SlotDY.
class Inventory {
    static slots := []

    static Configure(cfg) {
        first := cfg.Point("Inventory", "FirstSlot")
        dx := cfg.Int("Inventory", "SlotDX", 42), dy := cfg.Int("Inventory", "SlotDY", 36)
        Inventory.slots := []
        loop 7 {
            row := A_Index - 1
            loop 4
                Inventory.slots.Push([first[1] + (A_Index - 1) * dx, first[2] + row * dy])
        }
    }

    ; Full when the last slot holds the item color.
    static IsFull(color, tol := 10) {
        s := Inventory.slots[28]
        return Screen.Near(s[1], s[2], color, tol, 6)
    }

    static Count(color, tol := 10) {
        n := 0
        for s in Inventory.slots
            n += Screen.Near(s[1], s[2], color, tol, 6)
        return n
    }

    ; Shift-drop every slot holding `color`. Only matching slots are clicked, so tools stay.
    ; Requires "Shift click to drop" enabled in the game settings.
    static DropAll(color, tol := 10) {
        Send "{Shift down}"
        try {
            for s in Inventory.slots {
                if !Screen.Near(s[1], s[2], color, tol, 6)
                    continue
                Human.Click(s[1], s[2], "Left", 4)
                Bot.Wait(60, 200)
            }
        } finally {
            Send "{Shift up}"
        }
    }
}

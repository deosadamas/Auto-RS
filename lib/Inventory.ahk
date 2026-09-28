#Requires AutoHotkey v2.0

; 4x7 inventory grid helpers. Slot centers derive from [Inventory] FirstSlot/SlotDX/SlotDY.
; DropMode "shift" (OSRS: shift-click) or "menu" (RS3: right-click, pick "Drop" at a fixed offset).
class Inventory {
    static slots := []
    static dropMode := "shift"
    static dropOffset := [0, 0]     ; "Drop" menu entry relative to the right-click point

    static Configure(cfg) {
        first := cfg.Point("Inventory", "FirstSlot")
        if (!first[1] && !first[2])
            throw ValueError("[Inventory] FirstSlot must be set (use F3 over backpack slot 1)")
        dx := cfg.Int("Inventory", "SlotDX", 42), dy := cfg.Int("Inventory", "SlotDY", 36)
        Inventory.slots := []
        loop 7 {
            row := A_Index - 1
            loop 4
                Inventory.slots.Push([first[1] + (A_Index - 1) * dx, first[2] + row * dy])
        }
        Inventory.dropMode := StrLower(cfg.Get("Inventory", "DropMode", "shift"))
        switch Inventory.dropMode {
            case "shift":
                Inventory.dropOffset := [0, 0]
            case "menu":
                entry := cfg.Point("Inventory", "DropMenuEntry")
                Inventory.dropOffset := [entry[1] - first[1], entry[2] - first[2]]
                if (!Inventory.dropOffset[1] && !Inventory.dropOffset[2])
                    throw ValueError("[Inventory] DropMenuEntry must be set (right-click slot 1, F3 over 'Drop')")
            default:
                throw ValueError("[Inventory] DropMode must be 'shift' or 'menu'")
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

    ; Drop every slot holding `color`. Only matching slots are clicked, so tools stay.
    static DropAll(color, tol := 10) {
        if (Inventory.dropMode = "menu")
            Inventory.DropAllMenu(color, tol)
        else
            Inventory.DropAllShift(color, tol)
    }

    ; OSRS: requires "Shift click to drop" enabled in the game settings.
    static DropAllShift(color, tol) {
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

    ; RS3 has no shift-drop: right-click the slot and click "Drop" in the context menu.
    ; The menu anchors at the actual cursor position, so the offset is applied to where
    ; the jittered right-click landed, not the slot center.
    static DropAllMenu(color, tol) {
        off := Inventory.dropOffset
        for s in Inventory.slots {
            if !Screen.Near(s[1], s[2], color, tol, 6)
                continue
            Human.Click(s[1], s[2], "Right", 3)
            Bot.Wait(160, 340)                       ; menu open
            MouseGetPos &mx, &my
            Human.Click(mx + off[1], my + off[2], "Left", 1)
            Bot.Wait(120, 320)
        }
    }
}

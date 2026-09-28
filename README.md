# Auto-RS

AutoHotkey v2 bot framework for RuneScape: Old School (RuneLite) and RS3 (NXT client). Color/pixel based; no memory reading or injection.

**Botting violates Jagex's rules and can get the account banned. Use a throwaway account.**

## Requirements

- AutoHotkey v2 (`winget install AutoHotkey.AutoHotkey`)
- Game window not minimized and not exclusive fullscreen (pixel search needs a visible window)
- OSRS: RuneLite in **Fixed - Classic layout**; "Shift click to drop" enabled in game settings (Woodcutter)
- RS3: client windowed, interface **locked**, UI scale left alone after sampling coordinates

## Run

Double-click `RSBot.ahk`. Pick a config profile (`config.ini` = OSRS, `config.rs3.ini` = RS3) and a script in the dropdowns. Any `*.ini` next to `RSBot.ahk` shows up as a profile.

| Key | Action |
|-----|--------|
| F1  | Start / pause |
| F2  | Stop |
| F3  | Copy mouse position (client coords) and log pixel color under cursor. Press while hovering the game. |

`bot.log` records everything shown in the GUI.

## Configure

All coordinates in the profile are client coordinates of the game window — press F3 over the game to get them.

- `[General] WindowTitle` — AHK WinTitle of the client (`ahk_exe RuneLite.exe` / `ahk_exe rs2client.exe`).
- `[Inventory] FirstSlot` — center of the top-left inventory slot; `SlotDX/DY` spacing.
- `[Inventory] DropMode` — `shift` (OSRS shift-click) or `menu` (RS3 right-click → Drop). For `menu`, `DropMenuEntry` is the F3 position of the "Drop" entry after right-clicking slot 1; the offset from slot 1 is reused for every slot, so keep the backpack far enough from the window edge that the menu isn't pushed back for the bottom row.
- `[Woodcutter] TreeColor` — OSRS: enable RuneLite **Object Markers**, mark the trees with a solid unusual color (e.g. `0xFF00FF`) and use that value. RS3: no markers, so F3 a distinctive trunk pixel and raise `TreeTolerance` until trees are found reliably. `LogColor` — F3 over the center of a log in the inventory.
- `[AntiBan]` — break cadence in minutes and per-step idle-action chance.

### RS3 setup

1. Windowed client, lock the interface (Esc → Interface → Edit layout → Lock).
2. Select `config.rs3.ini` in the Config dropdown.
3. F3 over backpack slot 1 → `FirstSlot`; slot 2 minus slot 1 → `SlotDX`; slot 5 minus slot 1 → `SlotDY`.
4. Right-click a log in slot 1, hover **Drop**, F3 → `DropMenuEntry`.
5. F3 a log in the backpack → `LogColor`; F3 a tree trunk → `TreeColor`; set `SearchRegion` to the 3D viewport, excluding UI panels.

## Write a script

Drop a class in `scripts/`, `#Include` it in `RSBot.ahk`, and `Bot.Register(YourClass)`.

```ahk
class Miner {
    static Name := "Miner"
    static Setup() {           ; read Bot.cfg, validate, throw on bad config
    }
    static Step() {            ; one unit of work; loops until stopped
        if Screen.FindRandom(0xFF00FF, [4, 4, 515, 337], &x, &y, 10)
            Human.Click(x, y)
        Bot.Wait(3000, 6000)   ; ALWAYS Bot.Wait, never Sleep - it handles pause/stop
    }
}
```

Library:

- `Human.MoveTo/Click/Press/Delay/Rand` — Bezier mouse paths, jittered clicks, bell-shaped delays.
- `Screen.Find/FindRandom/Near/WaitFor/Focus` — pixel search in a region, tolerance, window focus.
- `Inventory.IsFull/Count/DropAll` — 4x7 slot grid from config; `DropAll` shift-drops or menu-drops per `DropMode`.
- `AntiBan` — scheduled breaks and random idle actions, called automatically between steps.
- `Bot.Wait(ms)` / `Bot.Wait(lo, hi)` — interruptible randomized sleep; throws `StopSignal` on F2.

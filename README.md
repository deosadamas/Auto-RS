# Auto-RS

AutoHotkey v2 bot framework for Old School RuneScape (RuneLite). Color/pixel based; no memory reading or injection.

**Botting violates Jagex's rules and can get the account banned. Use a throwaway account.**

## Requirements

- AutoHotkey v2 (`winget install AutoHotkey.AutoHotkey`)
- RuneLite in **Fixed - Classic layout**, window not minimized
- "Shift click to drop" enabled in game settings (Woodcutter)

## Run

Double-click `RSBot.ahk`. Pick a script in the dropdown.

| Key | Action |
|-----|--------|
| F1  | Start / pause |
| F2  | Stop |
| F3  | Copy mouse position (client coords) and log pixel color under cursor. Press while hovering the game. |

`bot.log` records everything shown in the GUI.

## Configure

All coordinates in `config.ini` are client coordinates of the game window — press F3 over the game to get them.

- `[General] WindowTitle` — AHK WinTitle of the client (`ahk_exe RuneLite.exe`).
- `[Inventory] FirstSlot` — center of the top-left inventory slot; `SlotDX/DY` spacing.
- `[Woodcutter] TreeColor` — enable RuneLite **Object Markers**, mark the trees with a solid unusual color (e.g. `0xFF00FF`) and use that value. Natural tree pixels are unreliable. `LogColor` — F3 over the center of a log in the inventory.
- `[AntiBan]` — break cadence in minutes and per-step idle-action chance.

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
- `Inventory.IsFull/Count/DropAll` — 4x7 slot grid from config.
- `AntiBan` — scheduled breaks and random idle actions, called automatically between steps.
- `Bot.Wait(ms)` / `Bot.Wait(lo, hi)` — interruptible randomized sleep; throws `StopSignal` on F2.

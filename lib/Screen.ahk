#Requires AutoHotkey v2.0

; Game-window binding and pixel detection. All coords are Client coords of the game window
; (CoordMode "Client" is set in RSBot.ahk), so they survive window moves.
class Screen {
    static title := "ahk_exe RuneLite.exe"

    static Exists() => WinExist(Screen.title) != 0

    static Focus() {
        if !WinExist(Screen.title)
            throw Error("Game window not found: " Screen.title)
        if !WinActive(Screen.title) {
            WinActivate Screen.title
            if !WinWaitActive(Screen.title, , 3)
                throw Error("Could not activate game window")
            Sleep 250
        }
    }

    ; region := [x1, y1, x2, y2]. Sets &x/&y to the first match.
    static Find(color, region, &x, &y, tol := 10) {
        return PixelSearch(&x, &y, region[1], region[2], region[3], region[4], color, tol)
    }

    ; Like Find, but starts from a random sub-rectangle so repeated clicks land on
    ; different matching pixels instead of always the top-left one.
    static FindRandom(color, region, &x, &y, tol := 10) {
        w := region[3] - region[1], h := region[4] - region[2]
        loop 6 {
            rx := region[1] + Random(0, w // 2), ry := region[2] + Random(0, h // 2)
            if PixelSearch(&x, &y, rx, ry, Min(rx + w // 2, region[3]), Min(ry + h // 2, region[4]), color, tol)
                return true
        }
        return Screen.Find(color, region, &x, &y, tol)
    }

    ; True if color appears within `r` px of (x, y). Tolerant of 1-2 px config error.
    static Near(x, y, color, tol := 10, r := 4) {
        return PixelSearch(&fx, &fy, x - r, y - r, x + r, y + r, color, tol)
    }

    ; Poll for a color in region until found or timeout (ms). Cooperative with Bot.Wait.
    static WaitFor(color, region, &x, &y, timeout := 5000, tol := 10) {
        deadline := A_TickCount + timeout
        while (A_TickCount < deadline) {
            if Screen.Find(color, region, &x, &y, tol)
                return true
            Bot.Wait(80, 160)
        }
        return false
    }
}

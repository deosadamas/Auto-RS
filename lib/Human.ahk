#Requires AutoHotkey v2.0

; Human-like input: curved mouse paths, jittered clicks, bell-shaped random delays.
class Human {
    ; Bell-shaped random in [lo, hi] (mean of 3 uniforms). Never a flat distribution.
    static Rand(lo, hi) {
        if (lo >= hi)
            return lo
        return lo + (hi - lo) * (Random() + Random() + Random()) / 3
    }

    static Delay(lo, hi) => Sleep(Round(Human.Rand(lo, hi)))

    ; Move along a cubic Bezier with random control points and smoothstep timing.
    static MoveTo(x, y) {
        MouseGetPos &sx, &sy
        dx := x - sx, dy := y - sy
        dist := Sqrt(dx * dx + dy * dy)
        if (dist < 2) {
            MouseMove x, y, 0
            return
        }
        spread := Max(10, dist * 0.25)
        c1x := sx + dx * 0.3 + Random(-spread, spread)
        c1y := sy + dy * 0.3 + Random(-spread, spread)
        c2x := sx + dx * 0.7 + Random(-spread, spread)
        c2y := sy + dy * 0.7 + Random(-spread, spread)
        steps := Max(12, Round(dist / Random(6, 10)))
        loop steps {
            t := A_Index / steps
            t := t * t * (3 - 2 * t)          ; ease in/out
            u := 1 - t
            px := u*u*u*sx + 3*u*u*t*c1x + 3*u*t*t*c2x + t*t*t*x
            py := u*u*u*sy + 3*u*u*t*c1y + 3*u*t*t*c2y + t*t*t*y
            MouseMove Round(px), Round(py), 0
            Sleep Random(3, 9)
        }
        MouseMove x, y, 0
    }

    ; Click near (x, y) with pixel jitter and a realistic press/release gap.
    static Click(x, y, button := "Left", jitter := 2) {
        Human.MoveTo(x + Random(-jitter, jitter), y + Random(-jitter, jitter))
        Human.Delay(40, 140)
        Click button " Down"
        Human.Delay(35, 95)
        Click button " Up"
    }

    ; Press a key with a human hold duration.
    static Press(key, holdMin := 40, holdMax := 110) {
        Send "{" key " down}"
        Human.Delay(holdMin, holdMax)
        Send "{" key " up}"
    }
}

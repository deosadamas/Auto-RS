#Requires AutoHotkey v2.0

; Typed accessors over config.ini.
class Config {
    __New(path) {
        if !FileExist(path)
            throw Error("Config not found: " path)
        this.path := path
    }

    Get(section, key, default := "") => IniRead(this.path, section, key, default)

    Int(section, key, default := 0) => Integer(this.Get(section, key, default))

    ; Accepts 0xRRGGBB or decimal.
    Color(section, key, default := 0) => Integer(this.Get(section, key, default))

    ; "x,y" -> [x, y]
    Point(section, key) => this.Ints(section, key, 2)

    ; "x1,y1,x2,y2" -> [x1, y1, x2, y2]
    Region(section, key) => this.Ints(section, key, 4)

    Ints(section, key, count) {
        raw := this.Get(section, key)
        parts := StrSplit(raw, ",", " `t")
        if (parts.Length != count)
            throw ValueError(Format("[{}] {} must have {} comma-separated ints, got '{}'", section, key, count, raw))
        out := []
        for p in parts
            out.Push(Integer(p))
        return out
    }
}

#Requires AutoHotkey v2.0

; File + GUI logging. `sink` is an optional callable(line) the GUI installs.
class Logger {
    static file := A_ScriptDir "\bot.log"
    static sink := ""

    static Info(msg)  => Logger.Write("INFO", msg)
    static Warn(msg)  => Logger.Write("WARN", msg)
    static Error(msg) => Logger.Write("ERR ", msg)

    static Write(level, msg) {
        line := FormatTime(, "HH:mm:ss") " [" level "] " msg
        try FileAppend(line "`n", Logger.file)
        if Logger.sink
            Logger.sink.Call(line)
    }
}

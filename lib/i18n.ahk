_(msg_key, p0 = "-0", p1 = "-0", p2 = "-0", p3 = "-0", p4 = "-0", p5 = "-0", p6 = "-0", p7 = "-0", p8 = "-0", p9 = "-0")
{
    global _locale_
    IniRead, msg, % A_ScriptDir . "\locale.ini", % _locale_, % msg_key, % msg_key
    if (msg = "ERROR" or msg = "")
        return % msg_key
    StringReplace, msg, msg, `\n, `r`n, ALL
    StringReplace, msg, msg, `\t, % A_Tab, ALL
    Loop 10
    {
        idx := A_Index - 1
        if (p%idx% != "-0")
            msg := RegExReplace(msg, "\{" . idx . "\}", p%idx%)
    }
    return % msg
}
GetConf(file, sec, key, def:=0)
{
    IniRead, value, % file, % sec, % key, % def
    return value
}

SetConf(file, sec, key, value)
{
    FileAppend,, % file, CP0
    IniWrite, % value, % file, % sec, % key
}
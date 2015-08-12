#SingleInstance force
#Persistent
CoordMode, Mouse, Screen

IniRead, StartMenu_t, %A_WorkingDir%\settings.ini, Function, StartMenu, 0
IniRead, Screenshot_t, %A_WorkingDir%\settings.ini, Function, Screenshot, 0
IniRead, ToggleHidden_t, %A_WorkingDir%\settings.ini, Function, ToggleHidden, 0
IniRead, MapCapsLock_t, %A_WorkingDir%\settings.ini, Function, MapCapsLock, 0
IniRead, KillQQAd_t, %A_WorkingDir%\settings.ini, Function, KillQQAd, 0
IniRead, QQAdIni, %A_WorkingDir%\settings.ini, QQAd, Classes, %A_Space%

QQAdClasses := StrSplit(QQAdIni, ",")
for index, element in QQAdClasses
{
    GroupAdd, adQQ, %element% ahk_class TXGuiFoundation
}

SetTimer, StartMenu, 100
SetTimer, KillQQAd, 1000
Return

StartMenu:
MouseGetPos, x, y
If (x == 0 and y == 0 and sm_flag == 0 and StartMenu_t == 1)
{
    MouseGetPos, , , win_id
    WinGetClass, win_class, ahk_id %win_id%
    MouseState := GetKeyState("LButton") + GetKeyState("RButton") + GetKeyState("MButton")
    PosDist := oldx1 ** 2 + oldy1 ** 2 + oldx2 ** 2 + oldy2 ** 2
    If ((win_class == "Shell_TrayWnd" or win_class == "Windows.UI.Core.CoreWindow") and MouseState == 0 and PosDist > 72000)
    {
        sm_flag := 1
        Send, {LWin}
        Sleep, 100
    }
    Else
    {
        sm_flag := 0
    }
}
If (x != 0 or y != 0)
{
    sm_flag := 0
}
oldx2 := oldx1
oldy2 := oldy1
oldx1 := x
oldy1 := y
Return

KillQQAd: 
If (KillQQAd_t == 1)
{
    WinClose, ahk_group adQQ
}
Return

#If (Screenshot_t == 1)
^!q::
If !WinExist("ahk_class Microsoft-Windows-Tablet-SnipperToolbar")
{
    Run, C:\Windows\sysnative\SnippingTool.exe
    Sleep, 500
}
Else
{
    WinActivate, ahk_class Microsoft-Windows-Tablet-SnipperToolbar
}
Sleep, 50
Send, ^n
Return

~RButton::
If WinActive("ahk_class Microsoft-Windows-Tablet-SnipperToolbar")
{
    Send, {Esc}
}

Return
#If

#If (ToggleHidden_t == 1)
~^h::
If WinActive("ahk_class CabinetWClass")
{
    Sleep, 150
    Send, {LAlt}
    Sleep, 10
    Send, vhh
}
Return
#If

#If (MapCapsLock_t == 1)
    +CapsLock::
    If GetKeyState("CapsLock", "T") == 1
    {
        SetCapsLockState, off
    }
    Else
    {
        SetCapsLockState, on
    }
    Return
    Capslock::Ctrl
#If
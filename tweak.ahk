#SingleInstance force
#Persistent
CoordMode Mouse, Screen

SetTimer StartMenu, 100
Return

StartMenu:
MouseGetPos x, y
If (x == 0 and y == 0 and sm_flag == 0)
{
    MouseGetPos,,,win_id
    WinGetClass win_class, ahk_id %win_id%
    If (win_class == "Shell_TrayWnd" or win_class == "Windows.UI.Core.CoreWindow")
    {
        sm_flag := 1
        Send {LWin}
        Sleep 100
    }
    else
    {
        sm_flag := 0
    }
}
If (x != 0 or y != 0)
{
    sm_flag := 0
}
Return

^!q::
If !WinExist("ahk_class Microsoft-Windows-Tablet-SnipperToolbar")
{
    Run C:\Windows\sysnative\SnippingTool.exe
    Sleep 500
}
else
{
    WinActivate ahk_class Microsoft-Windows-Tablet-SnipperToolbar
}
Sleep 50
Send ^n
Return

~RButton::
If WinActive("ahk_class Microsoft-Windows-Tablet-SnipperToolbar")
{
    Send {Esc}
}
Return

~^h::
If WinActive("ahk_class CabinetWClass")
{
    Sleep 150
    Send {LAlt}
    Sleep 10
    Send vhh
}
Return

+Capslock::Capslock
Capslock::Ctrl

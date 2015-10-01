#SingleInstance force
#Persistent
CoordMode, Mouse, Screen

IniRead, StartMenu_t, %A_WorkingDir%\settings.ini, Function, StartMenu, 0
IniRead, Screenshot_t, %A_WorkingDir%\settings.ini, Function, Screenshot, 0
IniRead, ToggleHidden_t, %A_WorkingDir%\settings.ini, Function, ToggleHidden, 0
IniRead, MoveWindow_t, %A_WorkingDir%\settings.ini, Function, MoveWindow, 0
IniRead, CleanUpDeadIcon_t, %A_WorkingDir%\settings.ini, Function, CleanUpDeadIcon, 0
IniRead, BingSoftKeyboard_t, %A_WorkingDir%\settings.ini, Function, BingSoftKeyboard, 0
IniRead, QuickShell_t, %A_WorkingDir%\settings.ini, Function, QuickShell, 0
IniRead, MapCapsLock_t, %A_WorkingDir%\settings.ini, Function, MapCapsLock, 0
IniRead, KillQQAd_t, %A_WorkingDir%\settings.ini, Function, KillQQAd, 0
IniRead, QQAdIni, %A_WorkingDir%\settings.ini, QQAd, Classes, %A_Space%

QQAdClasses := StrSplit(QQAdIni, ",")
for index, element in QQAdClasses
{
    GroupAdd, adQQ, %element% ahk_class TXGuiFoundation
}

SetTimer, StartMenu, 100
SetTimer, CleanTray, 4500
SetTimer, KillQQAd, 500
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

CleanTray:
If (CleanUpDeadIcon_t == 1)
{
    tray_iconCleanup()
}
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

#If (MoveWindow_t == 1)
#m::
Send, !{Space}m
Sleep, 5
Send {Left}{Right}
Return
#If

#If (BingSoftKeyboard_t == 1)
#z::
Send, ^+mk
Return
#If

#If (QuickShell_t == 1)
!F2::
Run *RunAs "powershell"
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

tray_icons()
{
    static TB_BUTTONCOUNT := 0x0418, TB_GETBUTTON := 0x0417
    array := []
    array[0] := ["sProcess", "toolTip", "nMsg", "uID", "idx", "idn", "Pid", "hwnd", "sClass", "hIcon"]
    Index := 0
    detectHiddenWindows_old := a_detectHiddenWindows
    DetectHiddenWindows, On
    for key, sTray in ["NotifyIconOverflowWindow", "Shell_TrayWnd"]
    {
        WinGet, taskbar_pid, PID, ahk_class %sTray%
        hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", taskbar_pid)
        pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
        idxTB := tray_getTrayBar()
        SendMessage, %TB_BUTTONCOUNT%, 0, 0, ToolbarWindow32%key%, ahk_class %sTray%
        Loop, %ErrorLevel%
        {
            SendMessage, %TB_GETBUTTON%, a_index - 1, pProc, ToolbarWindow32%key%, ahk_class %sTray%
            varSetCapacity(btn, 32, 0), varSetCapacity(nfo, 32, 0)
            DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
            iBitmap := numGet(btn, 0)
            idn := numGet(btn, 4)
            Statyle := numGet(btn, 8)
            If dwData := numGet(btn, 12, "Uint")
            iString := numGet(btn, 16)
            else dwData := numGet(btn, 16, "int64"), iString := numGet(btn, 24, "int64")
            DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
            If numGet(btn, 12, "Uint")
            {
                hwnd := numGet(nfo, 0)
                uID := numGet(nfo, 4)
                nMsg := numGet(nfo, 8)
                hIcon := numGet(nfo, 20)
            }
            Else hwnd := numGet(nfo, 0, "int64"), uID := numGet(nfo, 8, "Uint"), nMsg := numGet(nfo, 12, "Uint")
            WinGet, pid, PID, ahk_id %hwnd%
            WinGet, sProcess, ProcessName, ahk_id %hwnd%
            WinGetClass, sClass, ahk_id %hwnd%
            varSetCapacity(sTooltip, 128), varSetCapacity(wTooltip, 128*2)
            DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128 * 2, "Uint", 0)
            DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
            idx := a_index - 1
            toolTip := a_isUnicode ? wTooltip : sTooltip
            Index++
            for a, b in array[0]
            array[Index, b] := %b%
        }
        DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
        DllCall("CloseHandle", "Uint", hProc)
    }
    DetectHiddenWindows, %detectHiddenWindows_old%
    Return array
}

tray_iconCleanup()
{
    tray_icons := tray_icons()
    for index in tray_icons
    {
        IfEqual, index, 0, Continue
        If (tray_icons[index, "sProcess"] = "")
        tray_iconRemove(tray_icons[index, "hwnd"], tray_icons[index, "uID"], "", tray_icons[index, "hIcon"])
    }
}

tray_iconRemove(hwnd, uID, nMsg = 0, hIcon = 0, nRemove = 0x2)
{
    varSetCapacity(nid, size := 936 + 4 * a_ptrSize)
    numPut(size, nid, 0, "uint")
    numPut(hwnd, nid, a_ptrSize)
    numPut(uID, nid, a_ptrSize * 2, "uint")
    numPut(1|2|4, nid, a_ptrSize * 3, "uint")
    numPut(nMsg, nid, a_ptrSize * 4, "uint")
    numPut(hIcon, nid, a_ptrSize * 5, "uint")
    Return DllCall("shell32\Shell_NotifyIconA", "Uint", nRemove, "Uint", &nid)
}

tray_getTrayBar()
{
    detectHiddenWindows_old := a_detectHiddenWindows
    DetectHiddenWindows, On
    ControlGet, hParent, hwnd,, TrayNotifyWnd1 , ahk_class Shell_TrayWnd
    ControlGet, hChild , hwnd,, ToolbarWindow321, ahk_id %hParent%
    Loop
    {
        ControlGet, hwnd, hwnd,, ToolbarWindow32%a_index%, ahk_class Shell_TrayWnd
        If !hwnd
            Break
        Else If (hwnd = hChild)
        {
            idxTB := a_index
            Break
        }
    }
    DetectHiddenWindows, %detectHiddenWindows_old%
    Return idxTB
}
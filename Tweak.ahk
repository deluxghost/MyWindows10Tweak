#Persistent
#SingleInstance force
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%\lib\Gdip.ahk
#Include %A_ScriptDir%\lib\i18n.ahk
#Include %A_ScriptDir%\lib\Conf.ahk
#Include %A_ScriptDir%\lib\Thumbnail.ahk

OnExit AppExit
CoordMode, Mouse, Screen
DetectHiddenWindows, On

; ## Settings ##

t_Settings := A_ScriptDir . "\settings.ini"
if !FileExist(t_Settings)
    NewSetting(t_Settings)
t_MoveWindow := GetConf(t_Settings, "HotKey", "MoveWindow")
t_ToggleHidden := GetConf(t_Settings, "HotKey", "ToggleHidden")
t_CapsLock2Ctrl := GetConf(t_Settings, "HotKey", "CapsLock2Ctrl")
t_DisableNumLock := GetConf(t_Settings, "HotKey", "DisableNumLock")
t_Minimize := GetConf(t_Settings, "HotKey", "Minimize")
t_ArrowKeyMouse := GetConf(t_Settings, "HotKey", "ArrowKeyMouse")
t_ScrollVolume := GetConf(t_Settings, "Mouse", "ScrollVolume")
t_GnomeStyleStart := GetConf(t_Settings, "Monitor", "GnomeStyleStart")
t_CleanTrayIcon := GetConf(t_Settings, "Monitor", "CleanTrayIcon")
t_TotalCmdHack := GetConf(t_Settings, "Monitor", "TotalCmdHack")
t_NoExtWarning := GetConf(t_Settings, "Monitor", "NoExtWarning")
t_SaveAsEnable := GetConf(t_Settings, "SaveAsFile", "Enable")
t_LiveEnable := GetConf(t_Settings, "LiveWindow", "Enable")
t_TrashInPC := GetConf(t_Settings, "Windows", "TrashInPC")
_locale_ := GetConf(t_Settings, "Locale", "Locale")

rel_pos_x = 0, rel_pos_y = 0
live_count = 0, live_ypos = 0

; ## Init ##

;Menu, Tray, Icon, %A_ScriptDir%\Tweak.ico
Menu, Tray, Click, 1
Menu, Tray, Tip, Tweak
Menu, Tray, Add, Windows 10 Tweak, Menu_Show
Menu, Tray, ToggleEnable, Windows 10 Tweak
Menu, Tray, Add, Author: deluxghost, Menu_Show
Menu, Tray, ToggleEnable, Author: deluxghost
Menu, Tray, Default, Windows 10 Tweak
Menu, Tray, Add
Menu, Tray, Add, % _("tray.settings"), Menu_Settings
Menu, Tray, Add, % _("tray.reload"), Menu_Reload
Menu, Tray, Add
Menu, Tray, Add, % _("tray.exit"), Menu_Exit
Menu, Tray, NoStandard

TrashInPC(t_TrashInPC)

WinGet, systray, ID, ahk_class Shell_TrayWnd
SetTimer, GnomeStyleStart, 100
SetTimer, CleanTrayIcon, 4000
SetTimer, TotalCmdWatch, 200
SetTimer, NoExtWarning, 50
return

; ## Subs & GUI ##

NewSetting(file)
{
    FileAppend,
    ( LTrim
    [Locale]
    Locale=en_US
    [HotKey]
    MoveWindow=1
    ToggleHidden=1
    CapsLock2Ctrl=1
    DisableNumLock=1
    Minimize=1
    ArrowKeyMouse=1
    [Mouse]
    ScrollVolume=1
    [Monitor]
    GnomeStyleStart=1
    CleanTrayIcon=1
    NoExtWarning=1
    [SaveAsFile]
    Enable=1
    [LiveWindow]
    Enable=1
    [Windows]
    TrashInPC=0
    ), % file
}

AppExit:
GoSub, LiveClean
ExitApp
return

Menu_Show:
Menu, Tray, Show
return

Menu_Settings:
Gui, Settings:New
Gui, Settings:+LabelSettings_On -MaximizeBox
Gui, Settings:Add, Text, x12 y9 w350 h20, % _("gui.settings.language")
Gui, Settings:Add, Edit, Limit10 -Multi v_l x12 y29 w350 h20, % _locale_
Gui, Settings:Add, CheckBox, Checked%t_MoveWindow% v_c1 x12 y59 w350 h20, % _("gui.settings.movewindow")
Gui, Settings:Add, CheckBox, Checked%t_ToggleHidden% v_c2 x12 y79 w350 h20, % _("gui.settings.togglehidden")
Gui, Settings:Add, CheckBox, Checked%t_CapsLock2Ctrl% v_c3 x12 y99 w350 h20, % _("gui.settings.caplocks2ctrl")
Gui, Settings:Add, CheckBox, Checked%t_DisableNumLock% v_c4 x12 y119 w350 h20, % _("gui.settings.disablenumlock")
Gui, Settings:Add, CheckBox, Checked%t_Minimize% v_c5 x12 y139 w350 h20, % _("gui.settings.minimize")
Gui, Settings:Add, CheckBox, Checked%t_ArrowKeyMouse% v_c6 x12 y159 w350 h20, % _("gui.settings.arrowkeymouse")
Gui, Settings:Add, CheckBox, Checked%t_ScrollVolume% v_c7 x12 y179 w350 h20, % _("gui.settings.scrollvolume")
Gui, Settings:Add, CheckBox, Checked%t_GnomeStyleStart% v_c8 x12 y199 w350 h20, % _("gui.settings.gnomestylestart")
Gui, Settings:Add, CheckBox, Checked%t_CleanTrayIcon% v_c9 x12 y219 w350 h20, % _("gui.settings.cleantrayicon")
Gui, Settings:Add, CheckBox, Checked%t_NoExtWarning% v_c10 x12 y239 w350 h20, % _("gui.settings.noextwarning")
Gui, Settings:Add, CheckBox, Checked%t_SaveAsEnable% v_c11 x12 y259 w350 h20, % _("gui.settings.saveasfile")
Gui, Settings:Add, CheckBox, Checked%t_LiveEnable% v_c12 x12 y279 w350 h20, % _("gui.settings.livewindow")
Gui, Settings:Add, CheckBox, Checked%t_TrashInPC% v_c13 x12 y299 w350 h20, % _("gui.settings.trashinpc")
Gui, Settings:Add, Text, x12 y332 w350 h20, % _("gui.settings.warning")
Gui, Settings:Add, Button, gBtnSave Default x12 y363 w170 h30, % _("gui.settings.save")
Gui, Settings:Add, Button, gBtnCancel x192 y363 w170 h30, % _("gui.settings.cancel")
Gui, Settings:Show, h405 w375, % _("gui.settings")
return

Menu_Reload:
Reload
return

Menu_Exit:
ExitApp
return

Settings_OnClose:
Gui, Settings:Destroy
return

BtnSave:
Gui, Settings:Submit, NoHide
SetConf(t_Settings, "Locale", "Locale", _l)
SetConf(t_Settings, "HotKey", "MoveWindow", _c1)
SetConf(t_Settings, "HotKey", "ToggleHidden", _c2)
SetConf(t_Settings, "HotKey", "CapsLock2Ctrl", _c3)
SetConf(t_Settings, "HotKey", "DisableNumLock", _c4)
SetConf(t_Settings, "HotKey", "Minimize", _c5)
SetConf(t_Settings, "HotKey", "ArrowKeyMouse", _c6)
SetConf(t_Settings, "Mouse", "ScrollVolume", _c7)
SetConf(t_Settings, "Monitor", "GnomeStyleStart", _c8)
SetConf(t_Settings, "Monitor", "CleanTrayIcon", _c9)
SetConf(t_Settings, "Monitor", "NoExtWarning", _c10)
SetConf(t_Settings, "SaveAsFile", "Enable", _c11)
SetConf(t_Settings, "LiveWindow", "Enable", _c12)
SetConf(t_Settings, "Windows", "TrashInPC", _c13)
Reload
return

BtnCancel:
Gui, Settings:Destroy
return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

MsgToolTip(msg, timeout:=1000)
{
    ToolTip, % msg
    SetTimer, RemoveToolTip, % timeout
}

TrashInPC(yes:=0)
{
    if (!A_IsAdmin) {
        MsgBox, % _("need.admin", _("gui.settings.trashinpc"))
        return
    }
    RootKey := "HKEY_LOCAL_MACHINE"
    SubKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{645FF040-5081-101B-9F08-00AA002F954E}"
    if (yes) {
        RegWrite, REG_SZ, % RootKey, % SubKey
    } else {
        RegDelete, % RootKey, % SubKey
    }
}

; ## HotKey ##

#If (t_MoveWindow)
    #m::
    Send, !{Space}m
    Sleep, 5
    Send {Left}{Right}
    return
#If

#If (t_ToggleHidden)
    ~^h::
    if WinActive("ahk_class CabinetWClass") or WinActive("ahk_class WorkerW") {
        RootKey := "HKEY_CURRENT_USER"
        SubKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        RegRead, Hidden_Status, % RootKey, % SubKey, Hidden
        if Hidden_Status = 2
            RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 1
        else 
            RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 2
        Send, {F5}
        MsgToolTip(_("stat.hidden.files", Hidden_Status == "2" ? _("stat.on") : _("stat.off")))
    }
return
#If

#If (t_CapsLock2Ctrl)
    +CapsLock::
    if GetKeyState("CapsLock", "T") == 1 {
        SetCapsLockState, Off
    } else {
        SetCapsLockState, On
    }
    MsgToolTip(_("stat.capslock", GetKeyState("CapsLock", "T") == 1 ? _("stat.on") : _("stat.off")))
    return
    Capslock::Ctrl
#If

#If (t_DisableNumLock)
    NumLock::
    SetNumlockState, On
    return
#If

#If (t_Minimize)
    #z::
    WinGet, active_id, ID, A
    WinMinimize, ahk_id %active_id%
    return
#If

#If (t_ArrowKeyMouse) and GetKeyState("LButton") + GetKeyState("RButton") + GetKeyState("MButton")
    Up::
    MouseMove,  0, -1,, R
    rel_pos_y -= 1
    ShowMousePos(1)
    return
    Left::
    MouseMove, -1,  0,, R
    rel_pos_x -= 1
    ShowMousePos(1)
    return
    Down::
    MouseMove,  0,  1,, R
    rel_pos_y += 1
    ShowMousePos(1)
    return
    Right::
    MouseMove,  1,  0,, R
    rel_pos_x += 1
    ShowMousePos(1)
    return
#If

#If (t_ArrowKeyMouse)
    ^!Up::
    MouseMove,  0, -1,, R
    ShowMousePos()
    return
    ^!Left::
    MouseMove, -1,  0,, R
    ShowMousePos()
    return
    ^!Down::
    MouseMove,  0,  1,, R
    ShowMousePos()
    return
    ^!Right::
    MouseMove,  1,  0,, R
    ShowMousePos()
    return
    ~LButton::
    ~MButton::
    ~RButton::
    ~LButton Up::
    ~MButton Up::
    ~RButton Up::
    rel_pos_x := 0
    rel_pos_y := 0
    ToolTip
    return
#If

ShowMousePos(rel:=0)
{
    global rel_pos_x, rel_pos_y
    CoordMode, Pixel, Screen
    MouseGetPos, abs_pos_x, abs_pos_y
    PixelGetColor, pos_color, abs_pos_x, abs_pos_y, RGB
    pos_color_hex := "#" . SubStr(pos_color, 3)
    pos_color_r := ("0x" . SubStr(pos_color, 3, 2))
    pos_color_g := ("0x" . SubStr(pos_color, 5, 2))
    pos_color_b := ("0x" . SubStr(pos_color, 7, 2))
    pos_color_r += 0, pos_color_g += 0, pos_color_b += 0
    pos_color_str := _("mouse.pos.hex", pos_color_hex) . "`n" . _("mouse.pos.rgb", pos_color_r, pos_color_g, pos_color_b)
    if (rel) {
        ToolTip, % _("mouse.pos.abs", abs_pos_x, abs_pos_y) . "`n" . _("mouse.pos.rel", rel_pos_x, rel_pos_y) . "`n" . pos_color_str
    } else {
        MsgToolTip(_("mouse.pos.abs", abs_pos_x, abs_pos_y) . "`n" . pos_color_str, 3000)
    }
}

; ## Mouse ##

#If (t_ScrollVolume and MouseIsOver("ahk_class Shell_TrayWnd"))
    WheelUp::
    Send {Volume_Up}
    Sleep, 100
    return
    WheelDown::
    Send {Volume_Down}
    Sleep, 100
    return
#If

MouseIsOver(WinTitle)
{
    MouseGetPos,,, Win
    return WinExist(WinTitle . " ahk_id " . Win)
}

; ## Monitor ##

GnomeStyleStart:
MouseGetPos, x, y
WinGetPos sx, sy,,, ahk_id %systray%
p_x := (sx == 0 ? 0 : A_ScreenWidth - 1)
p_y := (sy == 0 ? 0 : A_ScreenHeight - 1)
if (t_GnomeStyleStart and x == p_x and y == p_y and menu_stat == 0) {
    MouseGetPos,,, win_id
    WinGetClass, win_class, ahk_id %win_id%
    MouseState := GetKeyState("LButton") + GetKeyState("RButton") + GetKeyState("MButton")
    PosDist := (x1-p_x) ** 2 + (y1-p_y) ** 2 + (x2-p_x) ** 2 + (y2-p_y) ** 2
    win_list1 := "Shell_TrayWnd"
    win_list2 := "Windows.UI.Core.CoreWindow"
    win_list3 := "ImmersiveLauncher"
    win_list4 := "ImmersiveSwitchList"
    win_list5 := "DV2ControlHost"
    win_list6 := "Button"
    if win_class not in %win_list1%,%win_list2%,%win_list3%,%win_list4%,%win_list5%,%win_list6%
        return
    if (MouseState == 0 and PosDist > 72000) {
        menu_stat := 1
        Send, {LWin}
        Sleep, 100
    } else {
        menu_stat := 0
    }
}
if (x != p_x or y != p_y) {
    menu_stat := 0
}
x2 := x1, y2 := y1
x1 := x, y1 := y
return

CleanTrayIcon:
if (t_CleanTrayIcon)
{
    tray_iconCleanup()
}
return

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

TotalCmdWatch:
if (t_TotalCmdHack and WinActive("ahk_class TNASTYNAGSCREEN"))
{
    WinGetText, tcmd_content, ahk_class TNASTYNAGSCREEN
    StringMid, tcmd_num, tcmd_content, 0, 1
    if (GetKeyState("Alt", "P") == 0) {
        Sleep, 400
        ControlSend,, %tcmd_num%, ahk_class TNASTYNAGSCREEN
    }
}
return

NoExtWarning:
if (t_NoExtWarning and WinExist(_("sys.rename.title") . " ahk_class #32770"))
{
    SetControlDelay -1
    ControlClick, Button1, % _("sys.rename.title") . " ahk_class #32770",,,, NA
}
return

; ## SaveAsFile ##

#If t_SaveAsEnable and WinActive("ahk_class CabinetWClass")
    ~^v::
    save_hWnd := WinExist("A")
    for window in ComObjCreate("Shell.Application").Windows {
        if window.HWND == save_hWnd {
            PasteToPath(window.Document.Folder.Self.Path)
        }
    }
    return
#If
#If t_SaveAsEnable and WinActive("ahk_class WorkerW")
    ~^v::
    PasteToPath(A_Desktop)
    return
#If

PasteToPath(path)
{
    if !InStr(FileExist(path), "D")
        return
    path := RegExReplace(path, "([^\\])$", "$1\")
    if DllCall("IsClipboardFormatAvailable", "Uint",1) or DllCall("IsClipboardFormatAvailable", "Uint",13) {
        paste_type := _("type.text")
    } else if DllCall("IsClipboardFormatAvailable", "Uint",2) {
        paste_type := _("type.image")
    } else {
        return
    }
    pToken := Gdip_Startup()
    clip := (paste_type == _("type.text") ? clipboard : Gdip_CreateBitmapFromClipboard())
    default_name := ""
    Loop {
        InputBox, filename, % _("paste.title", paste_type), % _("enter.filename"),, 360, 135,,,,, % default_name
        if ErrorLevel
            break
        filename := Trim(filename, OmitChars := " `t")
        if !IsFileName(filename) {
            MsgBox, 0x10, % _("invalid.name"), % _("invalid.name.msg")
            default_name := filename
            continue
        }
        if !InStr(filename, ".")
            filename := filename . (paste_type == _("type.text") ? ".txt" : ".png")
        fullname := path . filename
        default_name := filename
        if FileExist(fullname) and !(InStr(FileExist(fullname), "R") or InStr(FileExist(fullname), "D")) {
            MsgBox, 0x134, % _("file.exists"), % _("file.exists.msg1", filename)
            IfMsgBox, No
                continue
            try {
                FileDelete, %fullname%
                if (paste_type == _("type.text")) {
                    FileAppend, %clip%, %fullname%
                } else {
                    SaveImage(clip, fullname)
                }
            } catch {
                MsgBox, 0x10, % _("paste.failed"), % _("paste.failed.msg")
            }
            break
        } else if FileExist(fullname) {
            MsgBox, 0x30, % _("file.exists"), % _("file.exists.msg2", filename)
            continue
        } else {
            try {
                if (paste_type == _("type.text")) {
                    FileAppend, %clip%, %fullname%
                } else {
                    SaveImage(clip, fullname)
                }
            } catch {
                MsgBox, 0x10, % _("paste.failed"), % _("paste.failed.msg")
            }
            break
        }
    }
    Gdip_Shutdown(pToken)
}

SaveImage(pBitmap, filename)
{
    Gdip_SaveBitmapToFile(pBitmap, filename, Quality:=100)
    Gdip_DisposeImage(pBitmap)
}

IsFileName(filename)
{
    filename := Trim(filename, OmitChars := " `t")
    if !filename or filename == "CON" or filename == "NUL"
        return false
    if InStr(filename, "\") or InStr(filename, "/") or InStr(filename, ":") or InStr(filename, "*")
        return false
    if InStr(filename, "?") or InStr(filename, "<") or InStr(filename, ">") or InStr(filename, "|")
        return false
    return true
}

; ## Live Window ##

#If (t_LiveEnable)
    #`::
    WinGet, live_win_id, ID, A
    live_win_id += 0
    if (live_win_id == live_id)
        return
    if (_live_%live_win_id%_ > 0){
        LiveDel(live_win_id)
    } else {
        LiveAdd(live_win_id)
    }
    return
#If

ShowLive:
live_x0 := A_ScreenWidth - 275, live_y0 := 75
Gui, Live:New
Gui, Live:+LabelLive_On +Hwndlive_id -MaximizeBox +AlwaysOnTop +Owner +Resize +ToolWindow
Gui, Live:Show, NoActivate x%live_x0% y%live_y0% w200 h25, % _("gui.live")
live_id += 0
WinGetPos,,, live_w, live_h, ahk_id %live_id%
offset_x := live_w - 200, offset_y := live_h - 25
SetTimer, UpdateLive, 300
return

UpdateLive:
WinGetPos,,, live_w, live_h, ahk_id %live_id%
live_ypos := 0, live_i := 0
Loop, %live_count%
{
    live_i += 1
    loop_id := live_%live_i%_
    loop_id += 0
    if (loop_id == live_id or !WinExist("ahk_id " . loop_id)) {
        live_i -= 1
        LiveDel(loop_id)
        continue
    }
    Thumbnail_GetSourceSize(_live_%loop_id%_thumb_, loop_w, loop_h)
    livepic_w := live_w - offset_x
    livepic_h := livepic_w * (loop_h / loop_w)
    Thumbnail_SetRegion(_live_%loop_id%_thumb_, 0, live_ypos, livepic_w, livepic_h, 0, 0, loop_w, loop_h)
    Thumbnail_Show(_live_%loop_id%_thumb_)
    live_ypos += livepic_h
}
WinMove, ahk_id %live_id%,,,, live_w, live_ypos + offset_y
return

Live_OnClose:
LiveDelAll()
return

LiveClean:
SetTimer, UpdateLive, Off
Gui, Live:Destroy
return

LiveAdd(id)
{
    global
    id += 0
    if live_count < 1
        GoSub, ShowLive
    live_count += 1
    live_%live_count%_ := id
    _live_%id%_ := live_count
    _live_%id%_thumb_ := Thumbnail_Create(live_id, id)
}

LiveDel(id)
{
    global
    id += 0
    Thumbnail_Destroy(_live_%id%_thumb_)
    live_index := _live_%id%_
    _live_%id%_ =
    Loop, % live_count - live_index {
        ii := A_Index + live_index - 1
        jj := ii + 1
        next_id := live_%jj%_
        live_%ii%_ := live_%jj%_
        _live_%next_id%_ := ii
    }
    live_%live_count%_ =
    live_count -= 1
    if live_count < 1
        GoSub, LiveClean
}

LiveDelAll()
{
    global
    Loop, %live_count% {
        id := live_%A_Index%_
        Thumbnail_Destroy(_live_%id%_thumb_)
        _live_%id%_ =
        live_%A_Index%_ =
    }
    live_count = 0
    GoSub, LiveClean
}

; ## End ##

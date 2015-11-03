Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & "C:\script\configure.cmd" & Chr(34), 0
Set WinScriptHost = Nothing
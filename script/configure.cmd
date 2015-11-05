@echo off

rem remove scheduled task
rem SchTasks /Delete /TN "Configure InteGREAT4TFS" /F

rem Turn of IEC
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f
Rundll32 iesetup.dll, IEHardenLMSettings
Rundll32 iesetup.dll, IEHardenUser
Rundll32 iesetup.dll, IEHardenAdmin
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /f /va
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /f /va
:: Optional to remove warning on first IE Run and set home page to blank.
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "First Home Page" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Default_Page_URL" /t REG_SZ /d "about:blank" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "DisableFirstRunCustomize" /t REG_DWORD /d 1 /f

rem Create local admin service account
net user /add intgr8serviceacct P2ssw0rd /expires:never /logonpasswordchg:no /comment:"InteGREAT4TFS service account"
WMIC USERACCOUNT WHERE "Name='intgr8serviceacct'" SET PasswordExpires=FALSE
net localgroup administrators intgr8serviceacct /add
rem configure rights
ntrights +r SeServiceLogonRight -u "intgr8serviceacct" 

rem change app pool identity
cd\windows\system32\inetsrv
appcmd set config /section:applicationPools /[name='intgr8appservice'].processModel.identityType:SpecificUser /[name='intgr8appservice'].processModel.userName:intgr8serviceacct /[name='intgr8appservice'].processModel.password:P2ssw0rd

rem Update web.config file for UI app
copy c:\script\web.config "C:\Program Files (x86)\eDev Technologies\inteGREAT4TFS 2015 Update 1\User Interface" /Y

rem restart IIS
iisreset

rem launch product site
start /MAX iexplore.exe http://www.modernrequirements.com/

rem Clean up
cd\
rd c:\script /s /q


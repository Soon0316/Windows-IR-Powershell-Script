$OutputDir = "./"
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

# 1. Registry Hive Dump
$RegOut = "$OutputDir\Registry"
New-Item -Path $RegOut -ItemType Directory -Force | Out-Null
reg save HKLM\SAM "$RegOut\SAM" /y
reg save HKLM\SYSTEM "$RegOut\SYSTEM" /y
reg save HKLM\SECURITY "$RegOut\SECURITY" /y
reg save HKLM\SOFTWARE "$RegOut\SOFTWARE" /y
reg save HKCU "$RegOut\NTUSER.DAT" /y

# 2. Windows Event Logs
$EvtOut = "$OutputDir\EventLogs"
New-Item -Path $EvtOut -ItemType Directory -Force | Out-Null
wevtutil epl Security "$EvtOut\Security.evtx"
wevtutil epl System "$EvtOut\System.evtx"
wevtutil epl Application "$EvtOut\Application.evtx"
wevtutil epl Microsoft-Windows-PowerShell/Operational "$EvtOut\Powershell.evtx"

# 3. Recent Files
Copy-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Destination "$OutputDir\Recent" -Recurse -Force

# 4. Prefetch
Copy-Item "C:\Windows\Prefetch\*" -Destination "$OutputDir\Prefetch" -Recurse -Force -ErrorAction SilentlyContinue

# 5. WMI Repository
Copy-Item "C:\Windows\System32\wbem\Repository\*" -Destination "$OutputDir\WMI" -Recurse -Force

# 6. Windows Error Reporting (WER)
Copy-Item "C:\ProgramData\Microsoft\Windows\WER\" -Destination "$OutputDir\WER" -Recurse -Force -ErrorAction SilentlyContinue

# 7. Netstat Output
netstat -ano | Out-File "$OutputDir\netstat.txt"

# 8. Systeminfo
systeminfo | Out-File "$OutputDir\systeminfo.txt"

# 9. Amcache
Copy-Item "C:\Windows\AppCompat\Programs\Amcache.hve" -Destination "$OutputDir\Amcache.hve" -Force -ErrorAction SilentlyContinue

# 10. SRUDB
Copy-Item "C:\Windows\System32\sru\*" -Destination "$OutputDir\SRUDB" -Recurse -Force -ErrorAction SilentlyContinue

# 11. Browser History & Cache
$BrowserOut = "$OutputDir\Browser"
New-Item -Path $BrowserOut -ItemType Directory -Force | Out-Null

# Chrome
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
if (Test-Path $chromePath) {
    Copy-Item "$chromePath\History" -Destination "$BrowserOut\Chrome_History" -Force -ErrorAction SilentlyContinue
    Copy-Item "$chromePath\Cache\*" -Destination "$BrowserOut\Chrome_Cache" -Recurse -Force -ErrorAction SilentlyContinue
}

# Edge
$edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
if (Test-Path $edgePath) {
    Copy-Item "$edgePath\History" -Destination "$BrowserOut\Edge_History" -Force -ErrorAction SilentlyContinue
    Copy-Item "$edgePath\Cache\*" -Destination "$BrowserOut\Edge_Cache" -Recurse -Force -ErrorAction SilentlyContinue
}

# 12. Powershell History
Copy-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Destination "$OutputDir\Powershell_History.txt" -Force -ErrorAction SilentlyContinue

# 13. setupapi.dev.log
Copy-Item "C:\Windows\INF\setupapi.dev.log" -Destination "$OutputDir\setupapi.dev.log" -Force -ErrorAction SilentlyContinue

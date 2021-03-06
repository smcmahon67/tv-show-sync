# restart iTunes and associated services so that WIFI sync works after PC goes to sleep

# stop iTunes.  Doesn't matter if its not running.
"stopping itunes"
Get-Process iTunes | % { $_.CloseMainWindow() } | Out-Null

"restarting apple mobile device"
Start-Process powershell -Verb runAs -ArgumentList "& Restart-Service ""Apple Mobile Device"""

"restarting apple bonjour service"
Start-Process powershell -Verb runAs -ArgumentList "& Restart-Service ""Bonjour Service"""

"starting itunes"
Invoke-Item "C:\Program Files (x86)\iTunes\iTunes.exe"

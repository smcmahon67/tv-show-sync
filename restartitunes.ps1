# restart iTunes and associated services so that WIFI sync works after PC goes to sleep

# stop iTunes.  Doesn't matter if its not running.
Get-Process iTunes | % { $_.CloseMainWindow() } | Out-Null

# for service in Apple Mobile Device, Bonjour Service, iPod Service.  FingerPrint depends on Bonjour so must be restarted also.
# restart service
Stop-Service FingerPrint
Restart-Service "Apple Mobile Device", "iPod Service", "Bonjour Service" -Force
Start-Service FingerPrint

# start iTunes
Invoke-Item "C:\Program Files (x86)\iTunes\iTunes.exe"

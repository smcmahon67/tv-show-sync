# script to grab the latest XML EPG from freepg.tv
Set-Location -Path "C:\ProgramData\ARGUS TV\XMLTV"
Invoke-WebRequest -Uri "http://au.freepg.tv/xmltv/oztivo/ACT.Canberra.gz?UID=DD81BE72&K=C9709EEB10218DF59044F422B21EBD04" -OutFile "epg.xml"

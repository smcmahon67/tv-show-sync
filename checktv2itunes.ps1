$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

$tvdir= "d:\Recorded TV"
$itunesTV = "D:\iTunes Media\TV Shows"
$covers = "D:\iTunes Media\covers"
$logfile =  "C:\Users\Steve\Documents\log\checktv2itunes.log"

Get-Date
# loop through mcebuddydir
foreach ($episode in (Get-ChildItem $tvdir *.wtv)) {
    # check to see if this file is in the right directory in itunes
    ($name, $title, $filename, $year) = meta_from_mcebuddy $episode
    $fullpath = "$itunesTV\$name\$filename"
    if (!(test-path "$fullpath")) {
        "can't find $fullpath"
    }
    
    # check to see if there's a cover file
    if (!(test-path "$covers\$name.jpg")) {
        "couldn't find $covers\$name.jpg"
    }
}

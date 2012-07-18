# set up some variables
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# don't use mapped network drives in powershell scripts if possible
$master = "\\orac3\iTunes Media\TV Shows\"
$shows = @( "Escape To The Country",
            "Homes Under The Hammer",
            "New Zealand's Next Top Model",
            "Dr Oz",
            "Selling Houses Abroad",
            "Survivor- One World",
            "The Amazing Race Australia")

Get-Date
$library = ituneslibrary

foreach ($show in $shows) {
    "checking $show"
    $masterdir = $master+$show
    if (test-path $masterdir) {
        foreach ($episode in (Get-ChildItem $masterdir)) {
            if (Test-Path "$masterdir\$episode" -PathType leaf) {
                "checking $episode"
                ($name, $title, $filename, $year, $month, $day, $time) = meta_from_iTunes_file $episode
                ($newname, $newtitle, $newfilename, $newyear) = meta_from_mcebuddy $filename
                $title = "$newname`_$year-$month-$day-$time"
                $newfilename = "$title.m4v"
                "new file name is $newfilename"
                $newdir = $master+$newname
                                
                # create the new directory if it doesn't exist
                if (!(test-path $newdir)) {
                    "making directory $newdir"
                    new-item $newdir -type directory
                }
                $newpath = $newdir+"\"+$newfilename
                
                # move file incrementing if it already exists
                if (test-path $newpath) {
                    "$newpath already exists"
                } else {
                    "moving $episode to $newdir"
                    # make sure we can find this file in iTunes so we can update it
                    ($library.Search("$name",0) | Sort-Object DateAdded -descending).Count
                    # Move-Item "$masterdir\$episode" $newpath
                }
            }
        }
    }
}

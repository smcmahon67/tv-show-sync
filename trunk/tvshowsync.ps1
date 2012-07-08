# set up some variables
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# don't use mapped network drives in powershell scripts if possible
$master = "\\orac3\iTunes Media\TV Shows\"
$slave = "\\NMAYNARD\My Documents\My Music\iTunes\iTunes Media\TV Shows\"
$shows = @( "Bollywood Star",
            "Selling Houses Abroad",
            "MasterChef Australia",
            "Escape To The Country",
            "60 Minute Makeover",
            "Homes Under The Hammer",
            "Fashion Star",
            "New Zealand's Next Top Model",
            "Judge Judy",
            "Drop Dead Diva",
            "Dr Oz",
            "The Bachelor",
            "Grand Designs")

Get-Date
$library = ituneslibrary

foreach ($show in $shows) {
    "checking $show"
    $masterdir = $master+$show
    if (test-path $masterdir) {
        $slavedir = $slave+$show
        if (!(test-path $slavedir)) {
            "making directory $remotedir"
            new-item $slavedir -type directory
        }
        foreach ($episode in (Get-ChildItem $masterdir)) {
            "checking $episode"
            if ((Test-Path "$masterdir\$episode" -PathType leaf) -and -not (Test-Path "$slavedir\$episode")) {
                "copying over $episode"
                Copy-Item "$masterdir\$episode" "$slavedir"
                "add $episode to iTunes and setting metadata"
                ($name, $title, $filename, $year) = meta_from_file $episode
                add_to_itunes_set_metadata $library "$slavedir\$episode" $title $name $year $master+"covers"
            }
        }
    }
}

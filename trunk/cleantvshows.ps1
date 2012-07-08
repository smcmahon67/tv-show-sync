# look for shows in the TV shows directory that are not in iTunes
# set up some variables
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# don't use mapped network drives in powershell scripts if possible
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
    $dir = $slave+$show
    if (test-path $dir) {
        foreach ($episode in (Get-ChildItem $dir)) {
            "checking $episode"
            if ((Test-Path "$masterdir\$episode" -PathType leaf)) {
               "checking whether $episode is in iTunes"
                $title = ([string]$episode).substring(0,([string]$episode).Length - 4)
                if (!($item = $library.Search("$title",0))) {
                    "$title not in library - removing"
#                    Remove-Item $episode
                }
            }
        }
    }
}

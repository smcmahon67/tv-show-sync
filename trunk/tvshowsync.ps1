# set up some variables
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# don't use mapped network drives in powershell scripts if possible
$itunesdir = "\\NMAYNARD\My Documents\My Music\iTunes\iTunes Media"
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
$localtvshows = "D:\iTunes Media\TV Shows\"

Get-Date
foreach ($show in $shows) {
    "checking $show"
    $localdir = $localtvshows+$show
    if (test-path $localdir) {
        $remotedir = $itunesdir+"\TV Shows\"+$show
        if (!(test-path $remotedir)) {
            "making directory $remotedir"
            new-item $remotedir -type directory
        }
        foreach ($episode in (Get-ChildItem $localdir)) {
            "checking $episode"
            if (!(test-path "$remotedir\$episode")) {
                "copying over $episode"
                Copy-Item "$localdir\$episode" $autodir
            }
        }
    }
}

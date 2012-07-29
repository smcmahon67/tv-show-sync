# set up some variables
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# don't use mapped network drives in powershell scripts if possible
$master = "d:\iTunes Media\TV Shows\"
$shows = @( "The Bachelor",
            "Playing It Straight",
            "MasterChef Australia",
            "Judge Judy",
            "Grand Designs",
            "Fashion Star",
            "America's Next Top M",
            "Selling Houses Abroa",
            "The Big Bang Theory",
            "Escape to the Countr",
            "60 Minute Makeover",
            "Homes Under the Hamm",
            "New Zealand's Next T",
            "The Amazing Race Aus",
            "Minuscule",
            "Phineas And Ferb",
            "Fringe",
            "Survivor- One World",
            "Dr Oz",
            "Downton Abbey")

Get-Date
$library = ituneslibrary

foreach ($show in $shows) {
    "checking $show"
    $masterdir = $master+$show
    if (test-path $masterdir) {
        foreach ($episode in (Get-ChildItem $masterdir)) {
            if (Test-Path "$masterdir\$episode" -PathType leaf) {
                "checking $episode"
                $title = ([string]$episode).SubString(0,([string]$episode).Length - 4)
                
                # find
                if ($library.Search("$title",0) -eq $null) {
                    "need to add $title to iTunes"
                    ($name, $title, $filename, $year,$month,$day,$time) = meta_from_iTunes_file $episode
                    add_to_itunes_set_metadata $library "$masterdir\$episode" $title $name $year
                }
            }
        }
    }
}

# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# define some path locations
$itunesTV = "D:\iTunes Media\TV Shows"
$library = ituneslibrary

foreach ($item in $library.Search("Fringe",0)) {
    if ($item.SeasonNumber -eq 4) {
        $item.Name = "Fringe S04E{0:0#}" -f $item.EpisodeNumber
    }
}

# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.

"starting tv2itunesync.ps1"
Get-Date

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1


# define some path locations
$mcebuddydir = "d:\videos\mcebuddydir"
$itunesTV = "D:\iTunes Media\TV Shows"

"creating itunes object"
Measure-Command {$library = ituneslibrary}


# loop through mcebuddydir
"looping through $mcebuddydir"
foreach ($episode in (Get-ChildItem $mcebuddydir *)) {
    # get metadata from current file name
    measure-command {($name, $title, $filename, $year) = meta_from_mcebuddy $episode}
    $dir = "$itunesTV\$name"
    $path = "$dir\$filename"
    "testing $dir"
    if (!(test-path "$dir")) {
        "making directory $dir"
        measure-command {New-Item $dir -type directory}
    }
    
    "considering $path"
    # move to iTunes directory
    if (!(Test-Path $path)) {
        "moving file $filename"
        measure-command {move-Item "$mcebuddydir\$episode" $path}
    }
    
    "adding to itunes and setting metadata"
    add_to_itunes_set_metadata $library $path $title $name $year
}

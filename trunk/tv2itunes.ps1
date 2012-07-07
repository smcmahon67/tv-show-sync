# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1


# define some path locations
$mcebuddydir = "d:\videos\mcebuddydir"
$itunesTV = "D:\iTunes Media\TV Shows"
$covers = "C:\atomic\covers"

# set up interaction with iTunes
# need to test for an error here if can't create itunes object
$itunes = New-Object -ComObject iTunes.application
if (-not $?) {
    "error creating iTunes object"
    exit 1
}
$library = $itunes.LibraryPlaylist

Get-Date

# loop through mcebuddydir
foreach ($episode in (Get-ChildItem $mcebuddydir *.m4v)) {
    # get metadata from current file name
    ($name, $title, $filename, $year) = fixname($episode)
    $dir = "$itunesTV\$name"
    $path = "$dir\$filename"
    
    if (!(test-path "$dir")) {
        "making directory $dir"
        New-Item $dir -type directory
    }
    
    # move to iTunes directory
    if (!(Test-Path $path)) {
        "moving file $filename"
        Move-Item "$mcebuddydir\$episode" $path
    }
    
    # add to iTunes
    # note that if you are debugging this iTunes will move the file to the movies directory till it gets its metadata updated below.
    $library.AddFile($path)
    
    # get handle
    $item = $library.Search("$name",0) | Sort-Object DateAdded -descending| Select-Object -First 1
    
    # set metadata
    $item.Name = $title
    $item.Show = $name
    $item.VideoKind = 3 # TV show
    $item.Year = $year
    
    # replace existing artwork with something I have specified if it exists
    if (Test-Path "$covers\$name.jpg") {
        # delete all existing artwork
        foreach ($a in $item.Artwork) { $a.Delete() }
    
        # add new artwork
        $item.AddArtworkFromFile("$covers\$name.jpg")
    }
}

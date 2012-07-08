function ituneslibrary() {
    # set up interaction with iTunes
    # need to test for an error here if can't create itunes object
    $itunes = New-Object -ComObject iTunes.application
    if (-not $?) {
        "error creating iTunes object"
        exit 1
    }
    $itunes.LibraryPlaylist
}

function fixname($episode) {
    # get metadata from current file name
    ($name, $network, $year, $month, $day, $hour, $min, $sec) = ([string]$episode).split('_')
    $name = $name.Replace(" - All New Episodes","")
    $name = $name.Replace("Dr Oz ","Dr Oz")
    $name = $name.Replace("K-Zone - Phineas And Ferb- Phineas And Ferb ","Phineas And Ferb")
    $name = $name.Replace("New Zealand's Next Top Model - All New E","New Zealand's Next Top Model")
    $name = $name.Replace("Fashion Star - Special Encore Presentati","Fashion Star")
    $title = "$name`_$year-$month-$day-$hour$min"
    
    if ($title.Length -gt 36) {
        $title = $title.substring(0,36)
    }
    $filename = "$title.m4v"
    $name
    $title
    $filename
    $year
}

function meta_from_file($episode) {
    # get metadata from current file name
    $filename = [string]$episode
    ($name, $remainder) = $filename.split('_')
    ($year, $month, $day, $time) = $remainder.split('-')

    $name
    $title
    $filename
    $year
}

function add_to_itunes_set_metadata($library,$path,$title,$name,$year,$covers) {
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

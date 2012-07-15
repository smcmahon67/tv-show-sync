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

function meta_from_mcebuddy($episode) {
    # get metadata from files created by MCE Buddy
    # format is name_network_year_month_day_hour_min_sec
    # certain file names are fixed, names are truncated to allow the new file name format to fit in with iTunes
    ($name, $network, $year, $month, $day, $hour, $min, $sec) = ([string]$episode).split('_')
    $name = $name.Replace(" - All New Episodes","")
    $name = $name.Replace("Dr Oz ","Dr Oz")
    $name = $name.Replace("K-Zone - Phineas And Ferb- Phineas And Ferb ","Phineas And Ferb")
    $name = $name.Replace("Fashion Star - Special Encore Presentati","Fashion Star")
    if ($name.Length -gt 20) {
        $name = $name.substring(0,20)
    }
    $title = "$name`_$year-$month-$day-$hour$min"
    
    $filename = "$title.m4v"
    $name
    $title
    $filename
    $year
}

function meta_from_iTunes_file($episode) {
    # get metadata from current file name
    $filename = [string]$episode
    ($name, $remainder) = $filename.split('_')
    ($year, $month, $day, $time) = $remainder.split('-')

    $name
    $title
    $filename
    $year
    $month
    $day
    $time
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

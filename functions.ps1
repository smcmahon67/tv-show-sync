$master = "D:\iTunes Media\TV Shows\"
$covers = "D:\iTunes Media\covers\"
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
            "Downton Abbey",
            "The Farmer Wants a W",
            "I Will Survive",
            "Beauty And The Geek",
            "Glee",
            "So You Think You Can",
            "Survivor- Philippine",
            "MasterChef- The Prof",
            "My Big Fat Operation",
            "Pimp My Ride",
            "Scorpion",
            "Doctor Who",
            "Dragon Riders of Be",
            "Minority Report",
            "Star Trek Voyager")
$showlist = "showlist.txt"

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

function test_ituneslibrary() {
    $library = ituneslibrary
    $library
    "ituneslibrary OK"
    $True
}

function meta_from_mcebuddy($episode) {
    # get metadata from files created by MCE Buddy
    # format is name_network_year_month_day_hour_min_sec
    # certain file names are fixed, names are truncated to allow the new file name format to fit in with iTunes.
    # Filenames and folder names are limited to 40 characters.
    ($name, $network, $year, $month, $day, $hour, $min, $sec) = ([string]$episode).split('_')
    # standardise show names by finding an occurance in the given name string
    foreach ($show in $shows) {
        if ($name -match $show) {
            $name = $show
        }
    }
    # remove trailing white space
    $name = $name -replace "\s*$",""
    # sometimes there's a space at the end and sometimes not so use regex
    if ($name.Length -gt 20) {
        $name = $name.substring(0,20)
    }
    $title = "$name`_$year-$month-$day-$hour$min"
    
    $filename = $title + $episode.extension
    $name
    $title
    $filename
    $year
}

function test_meta_from_mcebuddy() {
    $testname = "Minuscule_ABC1_2012_06_30_17_21_19.m4v"
    ($name, $title, $filename, $year) = meta_from_mcebuddy $testname
    ($name, $title, $filename, $year)
    if ($name.Length -gt 20) {
        "length of $name is greater than 20"
        $False
    } elseif ($title.Length -gt 36) {
        "length of $title is greater than 36"
        $False
    } elseif ($filename.Lenth -gt 40) {
        "length of $filename is greater than 40"
        $False
    } else {
        "meta_from_mcebuddy OK"
        $True
    }
}

function meta_from_iTunes_file($episode) {
    # get metadata from current file name
    $filename = [string]$episode
    ($name, $remainder) = $filename.split('_')
    $remainder = $remainder.Replace(".m4v","")
    ($year, $month, $day, $time) = $remainder.split('-')
    $title = "$name`_$year-$month-$day-$time"

    $name
    $title
    $filename
    $year
    $month
    $day
    $time
}

function test_meta_from_iTunes_file() {
    $testname = "Minuscule_2012-06-30-1721.m4v" # test file should be in the right format
    ($name, $title, $filename, $year, $month, $day, $time) = meta_from_iTunes_file $testname
    ($name, $title, $filename, $year, $month, $day, $time)
    "meta_from_iTunes_file OK"
    $True
}

function add_to_itunes($library,$path) {
    # add to iTunes
    # note that if you are debugging this iTunes will move the file to the movies directory till it gets its metadata updated below.
    $result = $library.AddFile($path)
}

function itunes_handle($name,$title) {
    # some shows have a different name in the meta data than the file name - probably just when there is a ":" involved
    $searchname = $name.Replace("-",":")
    $item = $library.Search("$searchname",0) | Sort-Object DateAdded -descending | select -first 1
    if (!($item)) {
        $item = $library.Search("$name",0) | Sort-Object DateAdded -descending | select -first 1
        if (!($item)) {
            "couldn't find $name in iTunes!"
            #exit 1
        }
    }
    $item
}

function set_itunes_metadata($item,$title,$name,$year) {
    # set metadata
    $item.Name = $title
    $item.Show = $name
    $item.VideoKind = 3 # TV show
    $item.Year = $year
    $item.Album = $name
    $item.Artist = "1" # need to have something here so grouping works on IOS
    
    # special case for Fringe
    if ($name -eq "Fringe") {
        $item.SeasonNumber = 4
    }
}

function set_artwork($item,$name) {
    if (Test-Path ($covers+"$name.jpg")) {
        # delete all existing artwork
        foreach ($a in $item.Artwork) { $a.Delete() }
    
        # add new artwork
        $item.AddArtworkFromFile($covers+"$name.jpg")
    }
}

function add_to_itunes_set_metadata($library,$path,$title,$name,$year) {
    "adding to iTunes"
    add_to_itunes $library $path
       
    # get handle
    "getting handle"
    $item = itunes_handle $name $title
    
    "setting metadata"
    set_itunes_metadata $item $title $name $year
    
    "setting artwork"
    set_artwork $item $name
}

function move_file_to_itunes($mcebuddydir,$episode,$dir,$path) {
    #"testing $dir"
    if (!(test-path "$dir")) {
        #"making directory $dir"
        New-Item $dir -type directory
    }
    
    #"considering $path"
    # move to iTunes directory
    if (!(Test-Path $path)) {
        #"moving file $filename"
        Move-Item "$mcebuddydir\$episode" $path
    }
}

function setup_test_move_file_to_itunes() {
    # this test depends on meta_from_mcebuddy working so that should be tested first
    $mcebuddydir = "d:\videos\mcebuddydir"
    $itunesTV = "D:\iTunes Media\TV Shows"

    # put test file in place
    $testname = "Minuscule_ABC1_2012_06_30_17_21_19.m4v"
    Copy-Item "D:\videos\mcebuddydirtest\$testname" $mcebuddydir
    ($name, $title, $filename, $year) = meta_from_mcebuddy $testname
    $dir = "$itunesTV\$name"
    $path = "$dir\$filename"

    move_file_to_itunes $mcebuddydir $testname $dir $path
    $path
    $title
    $name
    $year
}

function test_move_file_to_itunes() {
    ($path,$title,$name,$year) = setup_test_move_file_to_itunes
    ($path,$title,$name,$year)
    $result = Test-Path $path
    Remove-Item -Force $path
    $result
}


function test() {
    if (!(test_ituneslibrary)) {
        exit 1
    } elseif (!(test_meta_from_mcebuddy)) {
        exit 1
    } elseif (!(test_meta_from_iTunes_file)) {
        exit 1
    } elseif (!(test_move_file_to_itunes)) {
        exit 1
    }
}

function free_disk_c() {
    (gwmi win32_logicaldisk | where-object { $_.DeviceID -eq "C:" }).FreeSpace
}

function file_size($file) {
    (Get-Item $file).Length
}   
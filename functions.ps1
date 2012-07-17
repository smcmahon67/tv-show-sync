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
    $path = "D:\iTunes Media\Movies\$title\$title.m4v"
    $list = $library.Search("$name",0) | Sort-Object DateAdded -descending
    if (!($list)) {
        "couldn't find $name in iTunes!"
        #exit 1
    }
    $item = $null
    foreach ($i in $list) {
        if ($i.Location -eq $path) {
            $item = $i
            break
        }
    }
    if ($item -eq $null) {
        "couldn't find $name with location $path in iTunes!"
        #exit 1
    }
    $item
}

function set_itunes_metadata($item,$title,$name,$year) {
    # set metadata
    $item.Name = $title
    $item.Show = $name
    $item.VideoKind = 3 # TV show
    $item.Year = $year
}

function set_artwork($item,$name) {
    if (Test-Path "$covers\$name.jpg") {
        # delete all existing artwork
        foreach ($a in $item.Artwork) { $a.Delete() }
    
        # add new artwork
        $item.AddArtworkFromFile("$covers\$name.jpg")
    }
}

function add_to_itunes_set_metadata($library,$path,$title,$name,$year,$covers) {
    add_to_itunes $library $path
       
    # get handle
    $item = itunes_handle $name $title
    
    set_itunes_metadata $item $title $name $year
    
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
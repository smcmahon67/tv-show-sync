# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.
param(
    [string]$show = "",
    [int]$days = 3
)


$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\functions.ps1

# define some path locations
$itunesTV = "D:\iTunes Media\TV Shows"

function new-tvshow() {
    $tvshow = @{}
    $tvshow.replace_a = " "
    $tvshow.replace_b = "."
    
    return $tvshow
}

function process-tvshow($item,$recent,$tv_res,$tvshow) {
    if (($item.DateAdded -gt $recent) -and ($item.VideoKind -ne 3)) {
        $series = 0
        $episode = 0
        
        # get series and episode number
        $found=$False
        foreach ($tv_re in $tv_res) {
            if ($item.Name -Match $tv_re -and -not $found) {
                $found = $True
                $series = $matches[1]
                $episode = $matches[2]
            }
        }
        
        if ($series -eq 0 -and $episode -eq 0) {
            "couldn't match series and episode for "+$item.Name+" - giving up"
        } else {
            "updating metadata for "+$item.Name
            # set metadata
            $item.Show = $tvshow
            $item.VideoKind = 3 # TV show
            $item.SeasonNumber = $series
            $item.EpisodeNumber = $episode
            $item.Artist = "1"
            
            set_artwork $item $tvshow
        }
    }
}

# define the names of TV shows to consider
$tvshows = @{}
$tvshows["The Apprentice UK"] = new-tvshow
$tvshows["Fringe"] = new-tvshow
$tvshows["The Apprentice"] = new-tvshow
$tvshows["Stargate SG-1"] = new-tvshow
$tvshows["Stargate SG-1"].replace_a = "SG-1"
$tvshows["Stargate SG-1"].replace_b = "SG1"
$tvshows["Glee"] = new-tvshow
$tvshows["Grand Designs"] = new-tvshow
$tvshows["Grand Designs"].replace_a = "Grand Designs"
$tvshows["Grand Designs"].replace_b = "grand.designs"
$tvshows["Dollhouse"] = new-tvshow
$tvshows["Damages"] = new-tvshow
$tvshows["Caprica"] = new-tvshow
$tvshows["Stargate Atlantis"] = new-tvshow
$tvshows["Lost"] = new-tvshow
$tvshows["Andromeda"] = new-tvshow
$tvshows["Arrow"] = new-tvshow
$tvshows["The Prisoner"] = new-tvshow
$tvshows["Breaking Bad"] = new-tvshow
$tvshows["Breaking Bad"].replace_a = "Breaking Bad"
$tvshows["Breaking Bad"].replace_a = "Breaking.Bad"
$tvshows["Alias"] = new-tvshow
$tvshows["Defiance"] = new-tvshow
$tvshows["The Walking Dead"] = new-tvshow
$tvshows["Babylon 5"] = new-tvshow
$tvshows["Continuum"] = new-tvshow
$tvshows["The Clone Wars"] = new-tvshow


$tv_res = @("s(\d\d)e(\d\d)",
            "(\d)x(\d+)",
            "Season (\d+) Episode (\d+)",
            "(\d)(\d+)"            )
$recent=(Get-Date).AddDays(-$days)
$library = ituneslibrary

if ($show -ne "") {
    $recent = (Get-Date).AddDays(-10000)
    
    # get a list of the latest shows that are still movies. i.e. videokind is 1
    foreach ($item in $library.Search("$show",0)) {
        # only update metadata of episodes added since yesterday which have not already had their metadata
        # updated.
        process-tvshow $item $recent $tv_res $tvshow
    }
} else {
    # add other tvshows as well
    foreach ($show in $shows) {
        $tvshows[$show] = new-tvshow
    }

    # loop through TV shows
    foreach ($tvshow in $tvshows.Keys) {
        "processing $tvshow"
    
        # produce the bittorent version of the tv show name
        # might have to loop through several versions of this
        $showname_bt = $tvshow.Replace($tvshows[$tvshow].replace_a,$tvshows[$tvshow].replace_b)
        if ($showname_bt -ne $tvshow) {
            "using $showname_bt as alternate for $tvshow"
        }

        # get a list of the latest shows that are still movies. i.e. videokind is 1
        foreach ($item in $library.Search("$showname_bt",0)) {
            # only update metadata of episodes added since yesterday which have not already had their metadata
            # updated.
            process-tvshow $item $recent $tv_res $tvshow
        }

        foreach ($item in $library.Search("$tvshow",0)) {
            # only update metadata of episodes added since yesterday which have not already had their metadata
            # updated.
            process-tvshow $item $recent $tv_res $tvshow
        }
    }
 }

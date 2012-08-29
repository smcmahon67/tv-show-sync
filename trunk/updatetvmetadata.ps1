# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.

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
        foreach ($tv_re in $tv_res) {
            if ($item.Name -Match $tv_re) {
                $series = $matches[1]
                $episode = $matches[2]
            }
        }
        
        if ($series -eq 0 -and $episode -eq 0) {
            "couldn't match series and episode for "+$item.Name+" - giving up"
        } else {
            # set metadata
            $item.Show = $tvshow
            $item.VideoKind = 3 # TV show
            $item.SeasonNumber = $series
            $item.EpisodeNumber = $episode
            
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
$tv_res = @("s(\d\d)e(\d\d)",
            "(\d)x(\d+)")
$recent=(Get-Date).AddDays(-3)
$library = ituneslibrary

# loop through TV shows
foreach ($tvshow in $tvshows.Keys) {
    "processing $tvshow"
    
    # produce the bittorent version of the tv show name
    # might have to loop through several versions of this
    $showname_bt = $tvshow.Replace($tvshows[$tvshow].replace_a,$tvshows[$tvshow].replace_b)
    "using $showname_bt as alternate for $tvshow"

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

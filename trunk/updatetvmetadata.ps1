# this script assumes that the "keep iTunes Media Folder Organised" option is selected in iTunes preferences/advanced.
# will log to file on the command line that calls this.  Leave messages going to stdout for debugging.

# define some path locations
$itunesTV = "D:\iTunes Media\TV Shows"
$covers = "C:\atomic\covers"

# set up interaction with iTunes
$itunes = New-Object -ComObject iTunes.application
$library = $itunes.LibraryPlaylist

# define the names of TV shows to consider
$tvshows = @("The Apprentice UK","Fringe")
$tv_res = @("s(\d\d)e(\d\d)")

$yesterday=(Get-Date).AddDays(-1)

# loop through TV shows
foreach ($tvshow in $tvshows) {
    "processing $tvshow"
    
    # produce the bittorent version of the tv show name
    # might have to loop through several versions of this
    $showname_bt = $tvshow.Replace(" ",".")
    "using $showname_bt for $tvshow"

    # get a list of the latest shows that are still movies. i.e. videokind is 1
    foreach ($item in $library.Search("$showname_bt",0)) {
        # only update metadata of episodes added since yesterday
        if ($item.DateAdded -gt $yesterday) {
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
                
                # replace existing artwork with something I have specified if it exists
                if (Test-Path "$covers\$tvshow.jpg") {
                    # delete all existing artwork
                    foreach ($a in $item.Artwork) { $a.Delete() }
        
                    # add new artwork
                    $item.AddArtworkFromFile("$covers\$tvshow.jpg")
                }
            }
        }
    }
}

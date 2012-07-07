function fixname($episode) {
    # get metadata from current file name
    ($name, $network, $year, $month, $day, $hour, $min, $sec) = ([string]$episode).split('_')
    $name = $name.Replace(" - All New Episodes","")
    $name = $name.Replace("Dr Oz ","Dr Oz")
    $name = $name.Replace("K-Zone - Phineas And Ferb- Phineas And Ferb ","Phineas And Ferb")
    $name = $name.Replace("New Zealand's Next Top Model - All New E","New Zealand's Next Top Model")
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

################################################################################
#                                                                              #
# This script grabs the new tv schedule from IceTV and then alters some of the #
# show names for better matching against theTVDb.                              #
#                                                                              #
# Created Date: 26 SEP 2013                                                    #
# Updated Date: 18 FEB 2014                                                    #
# Created By: devonuto                                                         #
# Version: 1.2                                                                 #
#                                                                              #
################################################################################

function GetDropBox() {
  $hostFile = Join-Path (Split-Path (Get-ItemProperty HKCU:\Software\Dropbox).InstallPath) "host.db"
  if ($hostFile) {
    $encodedPath = [System.Convert]::FromBase64String((Get-Content $hostFile)[1])
    $string = [System.Text.Encoding]::UTF8.GetString($encodedPath).ToString()
  } else {
    $string = @(Get-ChildItem C:\ -recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "Dropbox"})[0].FullName
  }
  Write-Host "Getting dropbox path: $string"
  return $string
}

# Variables
$epg = "C:\Users\Steve\Documents\EPG"
$errorFile = $epg+"\Error Logs\"+(Get-Date).ToString("yyyy-MM-dd")+"_error_log.csv"
$webget = $epg+"\webget.exe"
$xml = $epg+'\icetv.xml'
$iceTVGuide = 'http://iceguide.icetv.com.au/cgi-bin/epg/iceguide.cgi?op=xmlguide'
$iceTVUser = 'smcmahon67'
$iceTVPW = 'ma4ha3'
$webgetParams = $iceTVGuide,'-u',$iceTVUser,'-p',$iceTVPW,'-o',$xml
$retries = 10

# Load windows form assembly, for message boxes
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

# Initialise Do/While loop.
$break = $false
$retry = 0
do {
	try {
		# Call the xml refresh
		& $webget $webgetParams | Out-Null
		$break = $true
	} catch {
		if ($retry -eq $retries) {
			$break = $true
			$errMessage = "Failed to download IctTV guide after " + $retries + " retries."
			[System.Windows.Forms.MessageBox]::Show($errMessage, "IctTV Connection Failure")
		} else {
			Start-Sleep -Seconds 30
			$retry = $retry + 1
		}
	}
} while ($break -eq $false) 

# Re-initialise Do/While loop.
$break = $false
$retry = 0
do {
	try {
		# import the contents of the xml into a variable
		$content = [IO.File]::ReadAllText($xml)
		$break = $true
	} catch {
		if ($retry -eq $retries) {
			$break = $true
			$errMessage = "Failed to import " + $xml + " after " + $retries + " retries."
			[System.Windows.Forms.MessageBox]::Show($errMessage, "IctTV Import Failure")
		} else {
			Start-Sleep -Seconds 30
			$retry = $retry + 1
		}
	}
} while ($break -eq $false)

# Replace content if it matches.
$content = $content -replace '>Big Brother<','>Big Brother (Australia)<'
$content = $content -replace 'Gap Year South America','Gap Year'

# Print output back to file.
Set-Content $xml $content

# If errors print error output to file.
if($error) {
  foreach ($err in $Error) {
    $timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss:ff"
    (New-Object PsObject -Property @{TimeStamp=$timestamp;Title='Getting EPG';Script=$err.InvocationInfo.ScriptName;Error=$err.ToString();Pos=$err.InvocationInfo.Line }) | Export-Csv -Path $errorFile -NoTypeInformation -Append
  }
}
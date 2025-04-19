
#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+
# https://stackoverflow.com/questions/44781312/determine-daylight-savings-status-for-different-time-zone-in-powershell

# collect your input (through db, or whatever mechanism you have)
$inputDateTime = Get-Date -Date "2017-06-27 00:00:00"

# pick your time zones
$fromTimeZone = "Central Europe Standard Time"  # EU
$toTimeZone   = "Central Standard Time"         # USA

# convert
$outputDateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($inputDateTime, $fromTimeZone, $toTimeZone)

# output
Write-Output $outputDateTime

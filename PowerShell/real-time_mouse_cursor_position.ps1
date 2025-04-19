
#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

Add-Type -AssemblyName System.Windows.Forms

while ($true) {

    $mousePosition = [System.Windows.Forms.Cursor]::Position

    $xCoord = $mousePosition.X
    $yCoord = $mousePosition.Y

    Clear-Host
    Write-Host "Real-time mouse cursor position x coordinate: $xCoord"
    Write-Host "Real-time mouse cursor position y coordinate: $yCoord"

    Start-Sleep -Milliseconds 100  # Adjust the delay as needed

}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

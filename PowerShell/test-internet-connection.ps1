
#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

function TestInternet {

  $Result = Test-Connection -ComputerName 8.8.8.8 -ErrorAction SilentlyContinue

  if ($? -eq $true) {
    write-output "Internet: OK"
    return $true
  }
  else {
    write-output "Internet: Error"
    return $false
  }

}

TestInternet

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+


#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+
# https://stackoverflow.com/questions/25771386/get-all-windows-of-a-process-in-powershell

$TypeDef = @"

using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace Api
{

 public class WinStruct
 {
   public string WinTitle {get; set; }
   public int WinHwnd { get; set; }
 }

 public class ApiDef
 {
   private delegate bool CallBackPtr(int hwnd, int lParam);
   private static CallBackPtr callBackPtr = Callback;
   private static List<WinStruct> _WinStructList = new List<WinStruct>();

   [DllImport("User32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   private static extern bool EnumWindows(CallBackPtr lpEnumFunc, IntPtr lParam);

   [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

   private static bool Callback(int hWnd, int lparam)
   {
       StringBuilder sb = new StringBuilder(256);
       int res = GetWindowText((IntPtr)hWnd, sb, 256);
      _WinStructList.Add(new WinStruct { WinHwnd = hWnd, WinTitle = sb.ToString() });
       return true;
   }   

   public static List<WinStruct> GetWindows()
   {
      _WinStructList = new List<WinStruct>();
      EnumWindows(callBackPtr, IntPtr.Zero);
      return _WinStructList;
   }

 }
}
"@

Add-Type -TypeDefinition $TypeDef -Language CSharpVersion3

# [Api.Apidef]::GetWindows() | Where-Object { $_.WinTitle -like "*Word" } | Sort-Object -Property WinTitle | Select-Object WinTitle,@{Name="Handle"; Expression={"{0:X0}" -f $_.WinHwnd}}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+
# https://www.delftstack.com/ko/howto/powershell/sending-a-mouse-click-event-in-powershell/

$scSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class Clicker
{
[StructLayout(LayoutKind.Sequential)]
struct INPUT
{
    public int        type; // 0 = INPUT_MOUSE,
                            // 1 = INPUT_KEYBOARD
                            // 2 = INPUT_HARDWARE
    public MOUSEINPUT mi;
}

[StructLayout(LayoutKind.Sequential)]
struct MOUSEINPUT
{
    public int    dx ;
    public int    dy ;
    public int    mouseData ;
    public int    dwFlags;
    public int    time;
    public IntPtr dwExtraInfo;
}

const int MOUSEEVENTF_MOVED      = 0x0001 ;
const int MOUSEEVENTF_LEFTDOWN   = 0x0002 ;
const int MOUSEEVENTF_LEFTUP     = 0x0004 ;
const int MOUSEEVENTF_RIGHTDOWN  = 0x0008 ;
const int MOUSEEVENTF_RIGHTUP    = 0x0010 ;
const int MOUSEEVENTF_MIDDLEDOWN = 0x0020 ;
const int MOUSEEVENTF_MIDDLEUP   = 0x0040 ;
const int MOUSEEVENTF_WHEEL      = 0x0080 ;
const int MOUSEEVENTF_XDOWN      = 0x0100 ;
const int MOUSEEVENTF_XUP        = 0x0200 ;
const int MOUSEEVENTF_ABSOLUTE   = 0x8000 ;

const int screen_length = 0x10000 ;

[System.Runtime.InteropServices.DllImport("user32.dll")]
extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

public static void LeftClickAtPoint(int x, int y)
{

    INPUT[] input = new INPUT[3];
    input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
    input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
    input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
    input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(3, input, Marshal.SizeOf(input[0]));
}
}
'@

Add-Type -TypeDefinition $scSource -ReferencedAssemblies System.Windows.Forms,System.Drawing

# [Clicker]::LeftClickAtPoint(300,300)

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

function TestInternet {

  $result = Test-Connection -ComputerName 8.8.8.8 -ErrorAction SilentlyContinue

  if ($? -eq $true) {
    write-output "Internet: OK"
    return $true
  }
  else{
    write-output "Internet: Error"
    return $false
  }

}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

function Certificate {

   $result = [Api.Apidef]::GetWindows() | Where-Object { $_.WinTitle -like "인증서*" } | Sort-Object -Property WinTitle | Select-Object WinTitle,@{Name="Handle"; Expression={"{0:X0}" -f $_.WinHwnd}}

   if ($null -eq $result) {
      Write-Host "인증서 이벤트 없음"
      return 0
   }
   else {
      Write-Host "인증서 이벤트 발생"
      return 1
   }
}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

function YesTrader {

   $result = [Api.Apidef]::GetWindows() | Where-Object { $_.WinTitle -like "예스트*" } | Sort-Object -Property WinTitle | Select-Object WinTitle,@{Name="Handle"; Expression={"{0:X0}" -f $_.WinHwnd}}

   if ($null -eq $result) {
      Write-Host "예스트레이더 실행 안됨"
      return 0
   }
   else {
      if ($null -eq $result.Count) {
        Write-Host "예스트레이더 이벤트 없음"
        return -1
      }
      else {
         Write-Host "예스트레이더 이벤트 발생"
         return 1
      }
   }
}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

function Timer($time) {

  # $sec = get-date -format "ss"
  $result = get-date -format "HHmm"

  if ($time -eq $result) {

    Write-Host "타이머 실행"
    return $true

  }

  Write-Host "타이머 패스"
  return $false
}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

$run_time = 0657

while ($true) {

   $run  = $false

   # 인증서 이벤트, 1개 창이 열린다.
   $npki = Certificate
   # 예스트레이더 이벤트, 2개 창이 열린다.
   $yes  = YesTrader

   if (1 -eq $npki) {
      [Clicker]::LeftClickAtPoint(1100,580)
   }

   elseif (1 -eq $yes) {

      $test = TestInternet

      if ($test) {
         Write-Host "60초 후 마우스 실행"
         start-sleep -seconds 60
         [Clicker]::LeftClickAtPoint(340,220)
      }
      else {
         Write-Host "인터넷 연결 안됨"
      }
   }

   $time = Timer $run_time

   if ($time) {
      $run = $true
   }

   $cur_time = get-date -format "hhHHmm"

   # Clear-Host
   Write-Host "run_time : $run_time"
   Write-Host "cur_time : $cur_time`n"

   start-sleep -seconds 15
}

#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+
<#
조건문 비교시 보통의 연산자인 =, <, > 기호 대신 약자를 사용한다.

-eq : ==
-ne : !=
-lt : <
-le : <=
-gt : >
-ge : >=

elseif 사용시 else if로 쓰면 에러난다. (빈공간 없음)
if, elseif, else 사용시 무조건 대가로 { } 가 있어야 한다.

$command = Get-Process | sort CPU | select -last 10 |ft
cls
$command

#>
#+------------------------------------------------------------------+
#|                                                                  |
#+------------------------------------------------------------------+

<#
https://iseop.tistory.com/10
#>
# mouse_event()
Add-Type -Name mouse -Namespace u32 -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flag, int x, int y, int a, int b);'

$move = 0x0001
$ldn = 0x0002
$lup = 0x0004
$rdn = 0x0008
$rup = 0x0010
$abs = 0x8000

$left_click = $ldn -bor $lup -bor $move -bor $abs
$right_click = $rdn -bor $rup -bor $move -bor $abs

[u32.mouse]::mouse_event($left_click, .5*65535, .5*65535, 0, 0)  # 클릭
[u32.mouse]::mouse_event($right_click, .5*65535, .5*65535, 0, 0) # 우클릭

# keybd_event()
Add-Type -Namespace u32 -Name keybd -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte a, byte b, int c, int d);'

[u32.keybd]::keybd_event(16,0,0,0) # SHIFT 누름
[u32.keybd]::keybd_event(65,0,0,0) # 'a' 누름
[u32.keybd]::keybd_event(65,0,2,0) # 'a' 뗌
[u32.keybd]::keybd_event(16,0,2,0) # SHIFT 뗌

# 키보드 입력은 Windows Forms의 SendWait()를 사용해도 됨.
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("ABCD")

# 파일 실행 권한 변경
Set-ExecutionPolicy RemoteSigned

# 현재 상태 확인
Get-ExecutionPolicy


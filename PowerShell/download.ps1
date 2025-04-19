
# 받운로드 받고 싶은 주소
$source = 'http://abc.def.com/01.mp4'

# 다운로드 받아서 어디에 저장 할 것인지
$destination = 'D:\Download\01.mp4'

# 다운로드 시작
Invoke-WebRequest -Uri $source -OutFile $destination

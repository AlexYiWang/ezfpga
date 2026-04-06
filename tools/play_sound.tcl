# 调用 Windows 自带的 PowerShell 播放系统提示音 (tada.wav)
# 在句尾加上 & 符号，让音频在后台异步播放，不阻塞 Vivado 进程
exec powershell -WindowStyle Hidden -command "(New-Object Media.SoundPlayer 'C:/Windows/Media/Windows Logon.wav').PlaySync()" &
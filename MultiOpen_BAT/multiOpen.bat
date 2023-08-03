@echo off

::获取管理员身份
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

setlocal enabledelayedexpansion
for /f "delims=" %%i in ('type "config.ini"^| find /i "="') do set %%i
echo 配置文件内容：
echo %srcPath%
echo %dstPath%
echo %directories%
echo -------------

::directories的副本
set remain=%directories%
:loop
for /f "tokens=1* delims=;" %%a in ("%remain%") do (
	::输出第一个分段
	::echo mklink /D %dstPath%%%a %srcPath%%%a
	mklink /D %dstPath%%%a %srcPath%%%a
	rem 将截取剩下的部分赋给变量remain，其实这里可以使用延迟变量开关
	set remain=%%b
)
::如果还有剩余,则继续分割
if defined remain goto :loop
echo -------------
echo 完成！
PAUSE
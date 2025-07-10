@echo off

::获取管理员身份
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

setlocal enabledelayedexpansion
for /f "delims=" %%i in ('type "config.ini"^| find /i "="') do set %%i
echo Content of config.ini：
echo %srcPath%
echo %dstPath%
echo %directories%
echo %files%
echo -------------
echo mklink directories

for %%i in ("%srcPath%") do set "abs_src_path=%%~fi"
for %%i in ("%dstPath%") do set "abs_dst_path=%%~fi"

echo abs_src_path = %abs_src_path%
echo abs_dst_path = %abs_dst_path%

::directories的副本
set remain=%directories%

:LoopDir
for /f "tokens=1* delims=;" %%a in ("%remain%") do (
	::输出第一个分段
	echo mklink /D %abs_dst_path%%%a %abs_src_path%%%a
		
	rem 检查路径是否存在，如果不存在则创建
	set "target_dir=%abs_dst_path%%%a"

	rem 判断目标文件夹的所有父文件夹是否存在，不存在则创建
	if not exist "!target_dir!" (
		call :CreateParentDirs "!target_dir!"
	)
	
	mklink /D %abs_dst_path%%%a %abs_src_path%%%a
	rem 将截取剩下的部分赋给变量remain，其实这里可以使用延迟变量开关
	set remain=%%b
)

::如果还有剩余,则继续分割
if defined remain goto :LoopDir

echo -------------
echo mklink files

set remain_files=%files%

:LoopFiles
for /f "tokens=1* delims=;" %%a in ("%remain_files%") do (
	::输出第一个分段
	echo mklink /H %abs_dst_path%%%a %abs_src_path%%%a
	
	mklink /H %abs_dst_path%%%a %abs_src_path%%%a
	rem 将截取剩下的部分赋给变量remain，其实这里可以使用延迟变量开关
	set remain_files=%%b
)

::如果还有剩余,则继续分割
if defined remain_files goto :LoopFiles

echo -------------
echo Complete
PAUSE

exit /b 0

:CreateParentDirs
	set "current_path=%~1"
	
	rem 如果路径是驱动器号（如 C:），则直接返回
	if "%current_path:~1,1%"==":" if "%current_path:~2%"=="" exit /b
	
	rem 检查当前路径是否存在
	if exist "%current_path%" exit /b
	
	rem 获取父路径
	for %%a in ("%current_path:~0,-1%") do set "parent_path=%%~dpa"
	
	if exist "%parent_path%" exit /b
	
	rem 创建当前目录
	echo Create directory: "%parent_path%"
	mkdir "%parent_path%" 2>nul || (
		echo error: Fail to create "%parent_path%"
		exit /b 1
	)
	
	rem 递归创建父路径
	call :CreateParentDirs "%parent_path%"

exit /b 0

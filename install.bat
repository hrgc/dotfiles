@echo off
setlocal
rem dotfiles setup for Windows (cmd version, for environments without pwsh).
rem Usage: install.bat  (enable Developer Mode, or run from an elevated cmd)
rem Creates the same symlinks as install.ps1, using only mklink.
rem NOTE: keep this file ASCII-only. cmd misparses UTF-8 batch files.

rem Repository root (directory of this script, without trailing backslash)
set "DOTFILES=%~dp0"
set "DOTFILES=%DOTFILES:~0,-1%"

call :main
set "rc=%errorlevel%"

rem Pause only when double-clicked, so the window does not close before the
rem result can be read. Explorer runs  cmd.exe /c ""<path>" "  (note the
rem trailing space), while cmd/pwsh/powershell never leave one.
setlocal EnableDelayedExpansion
set cl=!cmdcmdline:"=!
if "!cl:~-1!"==" " pause
endlocal
exit /b %rc%

:main
rem Creating symlinks requires Developer Mode or administrator rights
net session >nul 2>&1 && goto :can_symlink
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense 2>nul | "%SystemRoot%\System32\find.exe" "0x1" >nul && goto :can_symlink
echo Cannot create symbolic links. Do one of the following: 1>&2
echo   - Enable "Developer Mode" in Settings ^> Privacy ^& security ^> For developers 1>&2
echo   - Or run this script from a command prompt started with "Run as administrator" 1>&2
exit /b 1
:can_symlink

rem src (relative to repo) -> dest. See install.ps1 for why each dest is chosen.
echo dotfiles: %DOTFILES%
call :link "nvim"                    "%LOCALAPPDATA%\nvim"
call :link "wezterm"                 "%USERPROFILE%\.config\wezterm"
call :link "nushell\config.nu"       "%APPDATA%\nushell\config.nu"
call :link "nushell\env.nu"          "%APPDATA%\nushell\env.nu"
call :link "nushell\linux.nu"        "%APPDATA%\nushell\linux.nu"
call :link "nushell\windows.nu"      "%APPDATA%\nushell\windows.nu"
call :link "vscode\settings.json"    "%APPDATA%\Code\User\settings.json"
call :link "vscode\keybindings.json" "%APPDATA%\Code\User\keybindings.json"
call :link "vifm\vifmrc"             "%APPDATA%\Vifm\vifmrc"
call :link "vifm\colors"             "%APPDATA%\Vifm\colors"
call :link "vifm\scripts"            "%APPDATA%\Vifm\scripts"
echo Done. Start nvim and lazy.nvim will install the plugins automatically.
exit /b 0

rem ---------------------------------------------------------------------------
rem :link <src relative to repo> <dest>
:link
set "src=%DOTFILES%\%~1"
set "dest=%~2"
if not exist "%src%" (
    echo   skip: %src% does not exist
    exit /b 0
)

for %%I in ("%dest%") do set "parent=%%~dpI"
if not exist "%parent%" mkdir "%parent%"

rem Inspect existing dest: attribute "l" = symlink, leading "d" = directory
set "attr="
for %%I in ("%dest%") do set "attr=%%~aI"
if not defined attr goto :make_link
if not "%attr:l=%"=="%attr%" goto :remove_link

rem Back up an existing real file/directory (not a link)
if exist "%dest%.bak" (
    echo   error: %dest%.bak already exists, skipped 1>&2
    exit /b 0
)
move "%dest%" "%dest%.bak" >nul || exit /b 0
echo   backup: %dest% -^> %dest%.bak
goto :make_link

:remove_link
rem Recreate existing links (rmdir/del remove only the link, not its target)
if "%attr:~0,1%"=="d" (rmdir "%dest%") else (del "%dest%")

:make_link
if exist "%src%\*" (
    mklink /D "%dest%" "%src%" >nul
) else (
    mklink "%dest%" "%src%" >nul
)
if errorlevel 1 (
    echo   error: failed to create link %dest% 1>&2
) else (
    echo   link: %dest% -^> %src%
)
exit /b 0

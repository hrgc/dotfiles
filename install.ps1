#!/usr/bin/env pwsh
# dotfiles セットアップ (Windows)
# 使い方: pwsh install.ps1  （開発者モード有効、または管理者 PowerShell で実行）
# 各設定をリポジトリから所定の場所へシンボリックリンクする。
$ErrorActionPreference = 'Stop'

# このスクリプトが置かれているディレクトリ（リポジトリのルート）
$Dotfiles = $PSScriptRoot

# シンボリックリンク作成には開発者モードまたは管理者権限が必要
function Test-CanSymlink {
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    if ($isAdmin) { return $true }
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    $dev = (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense `
        -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    return ($dev -eq 1)
}

if (-not (Test-CanSymlink)) {
    Write-Error @"
シンボリックリンクを作成できません。
次のいずれかを行ってください:
  - 設定 > プライバシーとセキュリティ > 開発者向け で「開発者モード」を有効化する
  - もしくは PowerShell を「管理者として実行」して再度実行する
"@
    exit 1
}

# src(リポジトリ相対) -> dest(配置先) のペア。
# nvim:    %LOCALAPPDATA%\nvim
# wezterm: %USERPROFILE%\.config\wezterm （wezterm は Windows でもここを探索する）
# nushell: %APPDATA%\nushell （ファイル単位。history.txt はローカルに残す）
# vscode:  %APPDATA%\Code\User （ファイル単位。globalStorage 等は巻き込まない）
# vifm:    %APPDATA%\Vifm （vifmrc / colors / scripts のみ。実行時状態は巻き込まない）
$links = @(
    @{ src = 'nvim';             dest = (Join-Path $env:LOCALAPPDATA 'nvim') }
    @{ src = 'wezterm';          dest = (Join-Path $HOME '.config\wezterm') }
    @{ src = 'nushell\config.nu';  dest = (Join-Path $env:APPDATA 'nushell\config.nu') }
    @{ src = 'nushell\env.nu';     dest = (Join-Path $env:APPDATA 'nushell\env.nu') }
    @{ src = 'nushell\linux.nu';   dest = (Join-Path $env:APPDATA 'nushell\linux.nu') }
    @{ src = 'nushell\windows.nu'; dest = (Join-Path $env:APPDATA 'nushell\windows.nu') }
    @{ src = 'vscode\settings.json';    dest = (Join-Path $env:APPDATA 'Code\User\settings.json') }
    @{ src = 'vscode\keybindings.json'; dest = (Join-Path $env:APPDATA 'Code\User\keybindings.json') }
    @{ src = 'vifm\vifmrc';  dest = (Join-Path $env:APPDATA 'Vifm\vifmrc') }
    @{ src = 'vifm\colors';  dest = (Join-Path $env:APPDATA 'Vifm\colors') }
    @{ src = 'vifm\scripts'; dest = (Join-Path $env:APPDATA 'Vifm\scripts') }
)

function Link-One($srcRel, $dest) {
    $src = Join-Path $Dotfiles $srcRel
    if (-not (Test-Path $src)) {
        Write-Warning "  skip: $src が存在しません"
        return
    }

    $parent = Split-Path $dest -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    # 既存の実体（非リンク）はバックアップ
    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if (-not $item.LinkType) {
            Move-Item $dest "$dest.bak" -Force
            Write-Host "  backup: $dest -> $dest.bak"
        }
    }

    New-Item -ItemType SymbolicLink -Path $dest -Target $src -Force | Out-Null
    Write-Host "  link: $dest -> $src"
}

Write-Host "dotfiles: $Dotfiles"
foreach ($l in $links) { Link-One $l.src $l.dest }
Write-Host "完了。nvim を起動すると lazy.nvim がプラグインを自動導入します。"

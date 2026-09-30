# dotfiles

[Neovim](https://neovim.io/) / [Nushell](https://www.nushell.sh/) / [WezTerm](https://wezfurlong.org/wezterm/) / [VSCode](https://code.visualstudio.com/) / [vifm](https://vifm.info/) の個人設定。
Linux と Windows の両方に対応し、`git clone` してセットアップスクリプトを実行するだけで
設定をシンボリックリンクで配置する。

## 前提（事前に手動で導入しておくもの）

セットアップスクリプトは**設定の配置のみ**を行う。ツール本体は各自で導入しておくこと。

- Neovim, Nushell, WezTerm, vifm
- フォント: [Cica](https://github.com/miiton/Cica)（WezTerm が使用。未導入だと代替フォントになる）
- Windows: [winget](https://learn.microsoft.com/windows/package-manager/) で導入すると楽
  （例: `winget install Neovim.Neovim Nushell.Nushell wez.wezterm`）
- Linux: 各ディストリのパッケージマネージャ（nu は snap 等）

## セットアップ

```sh
git clone https://github.com/hrgc/dotfiles ~/dotfiles
```

### Linux

```sh
bash ~/dotfiles/install.sh
```

### Windows

シンボリックリンクの作成には**開発者モード**（設定 > プライバシーとセキュリティ > 開発者向け）
を有効にするか、**管理者として実行**した PowerShell が必要。

```powershell
pwsh ~/dotfiles/install.ps1
```

pwsh を導入できない環境では、cmd の `mklink` だけで同じ配置を行う `install.bat` を使う
（コマンドプロンプトから実行する）。

```bat
%USERPROFILE%\dotfiles\install.bat
```

`install.bat` は ASCII のみで書くこと（UTF-8 の日本語を含むと cmd が行を誤解釈する）。

スクリプトは既存の実体ファイル/フォルダがあれば `.bak` に退避してからリンクを張る。

## 配置先

| 設定     | Linux                          | Windows                          |
| -------- | ------------------------------ | -------------------------------- |
| nvim     | `~/.config/nvim`               | `%LOCALAPPDATA%\nvim`            |
| wezterm  | `~/.config/wezterm`            | `~/.config/wezterm`             |
| nushell  | `~/.config/nushell/*.nu`       | `%APPDATA%\nushell\*.nu`        |
| vscode   | `~/.config/Code/User/*.json`   | `%APPDATA%\Code\User\*.json`    |
| vifm     | `~/.config/vifm/{vifmrc,colors,scripts}` | `%APPDATA%\Vifm\{vifmrc,colors,scripts}` |

nushell はディレクトリではなくファイル単位（`config.nu` / `env.nu` / `linux.nu` / `windows.nu`）で
リンクする。`history.txt` はローカルに残すため追跡しない。

vscode も `User` フォルダ全体ではなくファイル単位（`settings.json` / `keybindings.json`）でリンクする。
`globalStorage` / `workspaceStorage` 等のマシン固有データを巻き込まないため。`keybindings.json` は
リポジトリに置けば自動でリンクされる（無ければスキップ）。

vifm もディレクトリ全体ではなく `vifmrc` / `colors` / `scripts` のみリンクする。
`vifminfo.json`（履歴・マーク等の状態）や `vifm-help.txt` といった実行時データを巻き込まないため。

## 仕組みのメモ

- **nvim**: プラグインは [lazy.nvim](https://github.com/folke/lazy.nvim) 管理。
  初回起動時に `init.lua` が lazy.nvim を自動ブートストラップし、`lazy-lock.json` に固定された
  バージョンでプラグインを導入する。
- **nushell**: `config.nu` 末尾でパース時定数 `$nu` を使って OS を判定し、
  `linux.nu` / `windows.nu` を `source` する。OS 固有の PATH やエイリアスはそちらに書く。
- **wezterm**: `wezterm.lua` 内で `wezterm.target_triple` を見て既定シェルを切り替える。

#!/usr/bin/env bash
# dotfiles セットアップ (Linux)
# 使い方: bash install.sh
# 各設定をリポジトリから ~/.config 以下へシンボリックリンクする。
set -euo pipefail

# このスクリプトが置かれているディレクトリ（リポジトリのルート）
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# src(リポジトリ相対) -> dest(配置先) のペア。
# nushell はディレクトリごとではなくファイル単位でリンクする
# （history.txt をローカルに残すため）。
# vscode も User フォルダ全体ではなく追跡したいファイルのみリンクする
# （globalStorage 等のマシン固有データを巻き込まないため）。
# vifm もディレクトリ全体ではなく vifmrc / colors / scripts のみリンクする
# （vifminfo.json や vifm-help.txt などの実行時状態を巻き込まないため）。
links=(
  "nvim:$CONFIG/nvim"
  "wezterm:$CONFIG/wezterm"
  "nushell/config.nu:$CONFIG/nushell/config.nu"
  "nushell/env.nu:$CONFIG/nushell/env.nu"
  "nushell/linux.nu:$CONFIG/nushell/linux.nu"
  "nushell/windows.nu:$CONFIG/nushell/windows.nu"
  "vscode/settings.json:$CONFIG/Code/User/settings.json"
  "vscode/keybindings.json:$CONFIG/Code/User/keybindings.json"
  "vifm/vifmrc:$CONFIG/vifm/vifmrc"
  "vifm/colors:$CONFIG/vifm/colors"
  "vifm/scripts:$CONFIG/vifm/scripts"
)

link_one() {
  local src="$DOTFILES/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    echo "  skip: $src が存在しません" >&2
    return
  fi

  mkdir -p "$(dirname "$dest")"

  # 既に正しいリンクなら何もしない
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo "  ok:   $dest"
    return
  fi

  # 既存の実体（非リンク）はバックアップ
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$dest.bak"
    echo "  backup: $dest -> $dest.bak"
  fi

  ln -sfn "$src" "$dest"
  echo "  link: $dest -> $src"
}

echo "dotfiles: $DOTFILES"
for pair in "${links[@]}"; do
  link_one "${pair%%:*}" "${pair#*:}"
done
echo "完了。nvim を起動すると lazy.nvim がプラグインを自動導入します。"

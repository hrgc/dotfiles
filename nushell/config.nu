# config.nu — Nushell 起動時の設定
# 既定値の上書きと OS 固有設定の読み込みのみを行う。
# https://www.nushell.sh/book/configuration.html

$env.config = {
  shell_integration: {
    osc2: false
    osc7: false
    osc8: false
    osc9_9: false
    osc133: false
    osc633: false
  }
}

# OS 固有設定を読み込む。
# `$nu` はパース時定数なので、source 先をOSで分岐できる
# （alias 等のパース時構文も正しく取り込まれる）。
const os_config = if $nu.os-info.name == "windows" { "windows.nu" } else { "linux.nu" }
source $os_config

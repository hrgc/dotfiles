$env.PATH = (
  $env.PATH
  | append [
      /opt/nvim
      /opt/blender-4.2.16
      /usr/local/bin
    ]
)

alias python = python3
alias pip = pip3

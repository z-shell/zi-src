if [[ ! -e ~/.zi/bin ]]; then
  git clone --depth=1 https://github.com/z-shell/zi.git ~/.zi/bin
fi

source ~/.zi/bin/zi.zsh

autoload -Uz compinit
compinit
zi cdreplay -q

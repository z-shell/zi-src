# ZI SRC

```zsh
ZI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zi"
command mkdir -p $ZI_CONFIG
```

```zsh
curl -fsSL https://git.io/zi-loader -o $ZI_CONFIG
```

```zsh
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh"
  zzinit
fi
```

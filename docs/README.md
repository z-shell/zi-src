# ZI Source

```zsh
zi_config="${XDG_CONFIG_HOME:-$HOME/.config}/zi"
command mkdir -p $zi_config
```

```zsh
curl -fsSL https://git.io/zi-loader -o ${zi_config}/init.zsh
```

```zsh
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh"
  zzinit
fi
```

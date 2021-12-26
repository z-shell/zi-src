
## Install

```zsh
# Will add minimal configuration
sh -c "$(curl -fsSL https://git.io/get-zi)" --

# Non interactive. Just clone or update repository.
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -i skip

# Skip annexes.
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -a skip
```

## Loader

```zsh
# Prepare
zi_config="${XDG_CONFIG_HOME:-$HOME/.config}/zi"
command mkdir -p $zi_config
command curl -fsSL https://git.io/zi-loader -o ${zi_config}/init.zsh
```
 

```zsh
# Add at the top of your .zshrc
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" && zzinit
fi
```

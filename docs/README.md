
## Install

```zsh
# Will add minimal configuration
sh -c "$(curl -fsSL https://git.io/get-zi)" --

# Non interactive. Just clone or update repository.
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -i skip

# Minimal configuration + annexes.
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -a annex

# Minimal configuration + annexes + zunit.
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -a zunit

# Minimal configuration with loader
sh -c "$(curl -fsSL https://git.io/get-zi)" -- -a loader
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

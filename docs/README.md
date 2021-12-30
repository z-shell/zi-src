[![Install Library](https://github.com/z-shell/zi-src/actions/workflows/check-sh.yml/badge.svg)](https://github.com/z-shell/zi-src/actions/workflows/check-sh.yml)

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
> Branch: `-b branch`

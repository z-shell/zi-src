## Install

### Links: 

Install:

- https://git.io/get-zi
- https://z-shell.pages.dev/install
- https://z-shell.github.io/zi-src/sh/install.sh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/sh/install.sh

Loader:

- https://git.io/zi-loader
- https://z-shell.pages.dev/loader
- https://z-shell.github.io/zi-src/zsh/init.zsh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh

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

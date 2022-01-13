<h2 align="center">
  <a href="https://github.com/z-shell/zi">
    <img src="https://github.com/z-shell/zi/raw/main/docs/images/logo.svg" alt="Logo" width="80" height="80">
  </a>
❮ ZI ❯ Source
</h2>

## Links: 

Install:

- https://git.io/get-zi
- https://z-shell.pages.dev/i-hub
- https://z-shell.pages.dev/i-lab
- https://z-shell.github.io/zi-src/sh/install.sh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/sh/install.sh

Loader:

- https://git.io/zi-loader
- https://z-shell.pages.dev/loader
- https://z-shell.github.io/zi-src/zsh/init.zsh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh

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

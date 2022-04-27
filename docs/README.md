<h1 align="center">
  <a href="https://github.com/z-shell/zi">
    <img src="https://github.com/z-shell/zi/raw/main/docs/images/logo.svg" alt="Logo" width="80" height="80">
  </a>
❮ ZI ❯ Source
</h1>

ZI Wiki Pages: https://z.digitalclouds.dev :sparkles:

## Links

Install:

- https://zi.zshell.dev/sh/install.sh
- https://z.digitalclouds.dev/i-hub
- https://z.digitalclouds.dev/i-lab
- https://z-shell.github.io/zi-src/sh/install.sh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/sh/install.sh

Loader:

- https://zi.zshell.dev/zsh/init.zsh
- https://z.digitalclouds.dev/loader
- https://z-shell.github.io/zi-src/zsh/init.zsh
- https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh

## Install

```zsh
# Will add minimal configuration
sh -c "$(curl -fsSL https://zi.zshell.dev/sh/install.sh)" --

# Non interactive. Just clone or update repository.
sh -c "$(curl -fsSL https://zi.zshell.dev/sh/install.sh)" -- -i skip

# Minimal configuration + annexes.
sh -c "$(curl -fsSL https://zi.zshell.dev/sh/install.sh)" -- -a annex

# Minimal configuration + annexes + zunit.
sh -c "$(curl -fsSL https://zi.zshell.dev/sh/install.sh)" -- -a zunit

# Minimal configuration with loader
sh -c "$(curl -fsSL https://zi.zshell.dev/sh/install.sh)" -- -a loader
```

> Branch: `-b branch`

#!/usr/bin/env zsh
# Variables:
local repo="https://github.com/z-shell/zi.git"
local branch="main"
local verbose_mode="${verbose_mode:-false}"
# ZI variables:
# https://z-shell.pages.dev/docs/guides/customization
declare -A ZI
# Where ZI should create all working directories, e.g.: "~/.zi"
ZI[HOME_DIR]="${HOME}/.zi"
# Where ZI code resides, e.g.: "~/.zi/bin"
ZI[BIN_DIR]="${HOME}/.zi/bin"
# Path to .zcompdump file, with the file included (i.e. its name can be different)
ZI[ZCOMPDUMP_PATH]="${HOME}/.zcompdump"
# If set to 1, then mutes some of the ZI warnings, specifically the plugin already registered warning
ZI[MUTE_WARNINGS]='0'

# Clone ZI repository if it doesn't exist
zzsetup() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Checking if ZI (zi.zsh) is available."
  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    [[ $verbose_mode == true ]] && builtin print "(ZI): ZI (zi.zsh) is not found. Installing..."
  builtin print -P "%F{33}▓▒░ %F{160}Installing interactive feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod g-rwX "${ZI[BIN_DIR]}"
  command git clone -q --progress --branch "$branch" "$repo" "${ZI[BIN_DIR]}"
    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      [[ $verbose_mode == true ]] && builtin print "(ZI): Installed and ZI (zi.zsh) is found"
      git_refs=("$(cd "${ZI[BIN_DIR]}"; command git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | head -10)")
      print -P "%F{33}▓▒░ %F{34}Successfully installed %F{160}(%F{33}z-shell/zi%F{160})%f%b"
      print -P "%F{33}▓▒░ %F{226}Last changes:%f%b"
      print -P "%F{33}▓▒░ %F{160}%F{33}\n${git_refs}%F{160}%f%b"
    else
      print -P "%F{160}▓▒░ The clone has failed…%f%b"
      print -P "%F{160}▓▒░ %F{33} Please report the issue:%f%b"
      print -P "%F{160}▓▒░ %F{33} https://github.com/z-shell/zi/issues/new%f%b"
      return 1
    fi
    return 0
  fi
}

# If setup is successful or ZI is already installed, then load ZI. Otherwise, not continue and exit.
zzsource() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): If (zzsetup) function status code 0, then load ZI."
  if zzsetup; then
  [[ $verbose_mode == true ]] && builtin print "(ZI): Loading (zi.zsh)"
  source "${ZI[BIN_DIR]}/zi.zsh"
    else
  [[ $verbose_mode == true ]] && builtin print "(ZI): (zzsetup) function status code 1, not continue and exit."
    exit 1
  fi
}

# Enebale completion (completions should be loaded after zzsource)
zzcomps() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Loading completion… (_zi)"
  autoload -Uz _zi
  (( ${+_comps} )) && _comps[zi]=_zi
}

# If ZI is installed, load ZI and enable completion.
zzinit() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Loading ZI (zi.zsh)"
  zzsource
  zzcomps
}

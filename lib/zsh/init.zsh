#!/usr/bin/env zsh
# ZI Loader (Values set: default)
#
# https://z.digitalclouds.dev/community/zsh_plugin_standard
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://z.digitalclouds.dev/docs/guides/customization
local repo="https://github.com/z-shell/zi.git"
local branch="main"
local verbose_mode="${verbose_mode:-false}"
typeset -A ZI
# Where ZI should create all working directories, e.g.: "~/.zi"
ZI[HOME_DIR]="${ZI[HOME_DIR]:-${HOME}/.zi}"
# Where ZI code resides, e.g.: "~/.zi/bin"
ZI[BIN_DIR]="$ZI[HOME_DIR]/bin"
# Zsh modules directory
ZI[ZMODULES_DIR]="$ZI[HOME_DIR]/zmodules"
# Where ZI cache is, e.g.: "~/.cache/zi"
ZI[CACHE_DIR]="${ZI[CACHE_DIR]:-$HOME/.cache/zi}"
# Path to .zcompdump file, with the file included (i.e. its name can be different)
ZI[ZCOMPDUMP_PATH]="$ZI[CACHE_DIR]/.zcompdump"
# If set to 1, then mutes some of the ZI warnings, specifically the plugin already registered warning
ZI[MUTE_WARNINGS]="${ZI[MUTE_WARNINGS]:-0}"

# Clone ZI repository if it doesn't exist
zzsetup() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Checking if ZI (zi.zsh) is available."
  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    [[ $verbose_mode == true ]] && builtin print "(ZI): ZI (zi.zsh) is not found. Installing..."
    builtin print -P "%F{33}▓▒░ %F{160}Installing interactive feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b"
    command mkdir -p "${ZI[BIN_DIR]}" && command chmod -R go-w "${ZI[HOME_DIR]}"
    command git clone -q --progress --branch "$branch" "$repo" "${ZI[BIN_DIR]}"
    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      [[ $verbose_mode == true ]] && builtin print "(ZI): Installed and ZI (zi.zsh) is found"
      local git_refs=("$(cd "${ZI[BIN_DIR]}"; command git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | head -10)")
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

# Load zi module if built
zzpmod() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Checking for ZI module."
  if [[ -f "${ZI[ZMODULES_DIR]}/zpmod/Src/zi/zpmod.so" ]]; then
    [[ $verbose_mode == true ]] && builtin print "(ZI): Loading ZI module."
    module_path+=( "${ZI[ZMODULES_DIR]}/zpmod/Src" )
    zmodload zi/zpmod &>/dev/null
    ZI[ZPMOD_ENABLED]=1
  fi
}

# Enable completion (completions should be loaded after zzsource)
zzcomps() {
  [[ $verbose_mode == true ]] && builtin print "(ZI): Loading completion… (_zi)"
  autoload -Uz _zi
  (( ${+_comps} )) && _comps[zi]=_zi
  ZI[COMPS_ENABLED]=1
}

# If ZI is installed, load ZI, enable completion and load zpmod.
zzinit() {
  (( ZI[SOURCED] )) && return
  [[ $verbose_mode == true ]] && builtin print "(ZI): Loading ZI (zi.zsh)"
  zzsource
  zzcomps
  zzpmod
}

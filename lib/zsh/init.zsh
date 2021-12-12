#!/usr/bin/env zsh
# Variables:
local repo="https://github.com/z-shell/zi.git"
local branch="main"
# Verbose output
#local verbose_mode="${verbose_mode:-1}"
# ZI variables:
declare -A ZI
# Where ZI should create all working directories, e.g.: "~/.zi"
ZI[HOME_DIR]="${HOME}/.zi"
# Where ZI code resides, e.g.: "~/.zi/bin"
ZI[BIN_DIR]="${HOME}/.zi/bin"
# Path to .zcompdump file, with the file included (i.e. its name can be different)
ZI[ZCOMPDUMP_PATH]="${HOME}/.zcompdump"
# If set to 1, then mutes some of the ZI warnings, specifically the plugin already registered warning
ZI[MUTE_WARNINGS]='0'

zzsetup() {
  if [[ $verbose_mode ]] {
    builtin print "(ZI): Checking if ZI (zi.zsh) is available."
  }
  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    if [[ $verbose_mode ]] {
      builtin print "(ZI): ZI (zi.zsh) is not found. Installing..."
    }
  builtin print -P "%F{33}▓▒░ %F{160}Installing interactive feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod g-rwX "${ZI[BIN_DIR]}"
  command git clone -q --progress --branch "$branch" "$repo" "${ZI[BIN_DIR]}"
    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      if [[ $verbose_mode ]] {
        builtin print "(ZI): Installed and ZI (zi.zsh) is found"
      }
      git_refs=("${(@f)$(cd "${ZI[BIN_DIR]}"; command git for-each-ref --format="%(refname:short):%(subject)" refs/heads refs/tags)}")
      print -P "%F{33}▓▒░ %F{34}Successfully installed %F{160}(%F{33}z-shell/zi%F{160})%f%b"
      print -P "%F{33}▓▒░ %F{34}Last changes:%f%b"
      print -P "%F{33}▓▒░ %F{160}(%F{33}$git_refs%F{160})%f%b"
    else
      print -P "%F{160}▓▒░ The clone has failed…%f%b"
      print -P "%F{160}▓▒░ %F{33} Please report the issue:%f%b"
      print -P "%F{160}▓▒░ %F{33} https://github.com/z-shell/zi/issues/new%f%b"
      return 1
    fi
    return 0
  fi
}

zzsource() {
  if [[ $verbose_mode ]] {
    builtin print "(ZI): Loading ZI (zi.zsh)"
  }
  source "${ZI[BIN_DIR]}/zi.zsh"
}

zzcomps() {
  if [[ $verbose_mode ]] {
    builtin print "(ZI): Loading ZI (_zi) completion… (_zi)"
  }
  autoload -Uz _zi
  (( ${+_comps} )) && _comps[zi]=_zi
}

zzinit() {
  if [[ $verbose_mode ]] {
    builtin print "(ZI): Checking if (zi_setup) function status code is 0, before sourcing ZI (zi.zsh)"
  }
  if [[ zzsetup ]]; then
    if [[ $verbose_mode ]] {
      builtin print "(ZI): Loading ZI (zi.zsh)"
    }
    zzsource
    zzcomps
    else
    exit 1
  fi
}

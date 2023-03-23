#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# === Zi Loader === #
trap "unset -f get_source_from check_src zzsetup 2> /dev/null" EXIT
trap "unset -f get_source_from check_src zzsetup 2> /dev/null; return 1" INT

# === Environment === #
# Set base environment for Zi
# Variables set by the user take higher priority
typeset -gA ZI

# Source repository URL.
[[ -z $ZI[REPOSITORY] ]] && ZI[REPOSITORY]="https://github.com/z-shell/zi.git"
# Track branch or tag.
[[ -z $ZI[STREAM] ]] && ZI[STREAM]="main"

# https://wiki.zshell.dev/docs/guides/customization
# Where Zi should create all working directories.
[[ -z $ZI[HOME_DIR] ]] && ZI[HOME_DIR]="${HOME}/.zi"
# Directory where Zi code resides.
[[ -z $ZI[BIN_DIR] ]] && ZI[BIN_DIR]="${ZI[HOME_DIR]}/bin"
# Cache directory.
[[ -z $ZI[CACHE_DIR] ]] && ZI[CACHE_DIR]="${HOME}/.cache/zi"
# Directory for configuration files.
[[ -z $ZI[CONFIG_DIR] ]] && ZI[CONFIG_DIR]="${HOME}/.config/zi"

# User/Device specific directory for software/data files.
# https://wiki.zshell.dev/community/zsh_plugin_standard#global-parameter-with-prefix
: ${ZPFX:=${ZI[HOME_DIR]}/polaris}
# Zsh modules directory.
: ${ZI[ZMODULES_DIR]:=${ZI[HOME_DIR]}/zmodules}
# Path to .zcompdump file, with the file included (i.e. its name can be different).
: ${ZI[ZCOMPDUMP_PATH]:=${ZI[CACHE_DIR]}/.zcompdump}
# If set to 1, then mutes some of the Zi warnings, specifically the plugin already registered warning.
: ${ZI[MUTE_WARNINGS]:=0}

# === Initiate Zi === #

typeset -i exit_code=0

get_source_from() {
  if (( $+commands[curl] )); then
    command curl -fsSL "$1"; exit_code=$?
  elif (( $+commands[wget] )); then
    command wget -qO- "$1"; exit_code=$?
  else
    exit_code=500
  fi

  return $exit_code
}

check_src() {
  typeset url="$1"
  if (( $+commands[curl] )); then
    command curl --output /dev/null --silent --show-error --location --head --fail "$url"; exit_code=$?
  elif (( $+commands[wget] )); then
    command wget --spider --quiet "$url"; exit_code=$?
  else
    exit_code=404
  fi

  return $exit_code
}

# Clone Zi repository if it doesn't exist
zzsetup() {
  (( $+functions[zi] )) && return 0

  builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
  builtin setopt extended_glob warn_create_global local_options \
    typeset_silent no_short_loops rc_quotes no_auto_pushd
  builtin autoload colors; colors

  typeset -a git_refs
  typeset tmp_dir show_process process_url

  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    tmp_dir="${TMPDIR:-/tmp}/zi"

    [[ -d $tmp_dir ]] || command mkdir -p $tmp_dir

    show_process="${tmp_dir}/git-process.zsh"
    process_url="https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh"

    if [[ ! -f $show_process ]]; then
      if check_src $process_url; then
        get_source_from $process_url > "${tmp_dir}/git-process.zsh"
        command chmod a+x "${tmp_dir}/git-process.zsh"
      else
        return 1
      fi
    fi

    (( $+commands[clear] )) && command clear
    builtin print -P "%F{33}▓▒░ %F{160}Installing interactive & feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b…\n"

    command mkdir -p "$ZI[BIN_DIR]" && \
    command chmod -R go-w "$ZI[HOME_DIR]" && command git clone --verbose --progress --branch \
      "$ZI[STREAM]" -- "$ZI[REPOSITORY]" "$ZI[BIN_DIR]" |& { command $show_process || command cat; }

    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      git_refs=("${(f@)$(builtin cd -q $ZI[BIN_DIR] && command git log --color --graph --abbrev-commit \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' | head -5)}")
      builtin print
      builtin print -P "%F{33}▓▒░ %F{34}Successfully installed %F{160}(%F{33}z-shell/zi%F{160})%f%b\n"
      builtin print -rl -- "${git_refs[@]}"
      exit_code=0
    else
      builtin print -P "%F{160}▓▒░  The clone has failed…%f%b"
      builtin print -P "%F{160}▓▒░ %F{33} Please report the issue: %F{226}https://github.com/z-shell/zi/issues/new%f%b"
      exit_code=1
    fi
  fi

  return $exit_code
}

# If the setup is successful or Zi is already installed, then load Zi. Otherwise, do not continue and exit.
zzsource() {
  (( ZI[SOURCED] )) && unset -f zzsource 2> /dev/null && return 0
  zzsetup && {
    builtin source "${ZI[BIN_DIR]}/zi.zsh"
  } || {
    return 1
  }
}

# Load zi module if built
zzpmod() {
  (( $+commands[zpmod] )) && unset -f zzpmod 2> /dev/null && return 0
  if [[ -f "${ZI[ZMODULES_DIR]}/zpmod/Src/zi/zpmod.so" ]]; then
    module_path+=( ${ZI[ZMODULES_DIR]}/zpmod/Src );
    zmodload zi/zpmod 2> /dev/null && return 0
  fi
}

# Enable completion (completions should be loaded after zzsource)
zzcomps() {
  (( $+_comps[zi] )) && unset -f zzcomps 2> /dev/null && return 0
  builtin autoload -Uz _zi && {
    (( ${+_comps} )) && _comps[zi]=_zi
    return 0
  } || {
    return 1
  }
}

# If Zi is installed, then load source, enable completion and if available load zpmod.
zzinit() { zzsource && zzcomps; zzpmod; unset -f zzinit 2> /dev/null && return 0; }

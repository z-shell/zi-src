#!/usr/bin/env sh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Temporary work directory
trap 'rm -rf "$WORKDIR"' EXIT INT

# Variables
WORKDIR="$(mktemp -d)"
SET_TIME="$(date '+%Y-%m-%d_%H:%M:%S')"
ZI_REPO="https://github.com/z-shell/zi"
MOD_REPO="https://github.com/z-shell/zpmod"
GIT_BAR="${WORKDIR}/git-progress-bar.zsh"
GIT_BAR_URL="https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh"
LOADER_URL="https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh"

# Messages
say() {
  while [ -n "$1" ]; do
    case "$1" in
    -normal) col="\033[00m" ;;
    -black) col="\033[30;01m" ;;
    -red) col="\033[31;01m" ;;
    -green) col="\033[32;01m" ;;
    -yellow) col="\033[33;01m" ;;
    -blue) col="\033[34;01m" ;;
    -magenta) col="\033[35;01m" ;;
    -cyan) col="\033[36;01m" ;;
    -white) col="\033[37;01m" ;;
    -n)
      one_line=1
      shift
      continue
      ;;
    *)
      printf '%s' "$1"
      shift
      continue
      ;;
    esac
    shift
    printf "%s${col}"
    printf '%s' "$1"
    printf "\033[00m"
    shift
  done
  [ -z "${one_line}" ] && printf "\n"
}

ask() {
  question="$1"
  printf "\033[34;1m▓▒░ \033[00m» "
  say -yellow "$question" -n
  printf " \033[00m[y/N]: "
  read -r answer
  case $answer in
  [yY]*)
    true
    ;;
  *)
    false
    ;;
  esac
}

err() {
  say -red "$1" >&2
  exit 1
}

say_ok() {
  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -green "$1"
  printf "\033[00m"
}

say_err() {
  printf "\033[34;01m▓▒░\033[31;01m ✘ \033[00m» "
  say -red "$*" >&2
  printf "\033[00m"
  exit 1
}

say_info() {
  printf "\033[34;1m▓▒░\033[36;01m ⚡\033[00m» "
  say -cyan "$1"
  printf "\033[00m"
}

while getopts ":i:a:b:" opt; do
  case ${opt} in
  i)
    ZOPT="${ZOPT}${OPTARG}"
    ;;
  a)
    AOPT="${AOPT}${OPTARG}"
    ;;
  b)
    BOPT="${OPTARG}"
    ;;
  \?)
    say_err "Invalid option: ${OPTARG}"
    ;;
  :)
    say_err "Invalid option: ${OPTARG} requires an argument"
    ;;
  *)
    say_err "Invalid option: ${OPTARG}"
    ;;
  esac
done
shift $((OPTIND - 1))

# Default options
[ -z "$BOPT" ] && BOPT="main"

# Functions
is_cmd() { command -v "$1" >/dev/null 2>&1; }

check_cmd() {
  if ! is_cmd "$1"; then
    say_err "$1 not found. Please install it and try again."
  fi
}

download() {
  # Set download command
  if is_cmd curl; then
    command curl -fsSL "$1" -o "$2" && command chmod a+x "$2"
  elif is_cmd wget; then
    command wget -qO "$2" "$1" && command chmod a+x "$2"
  else
    say_err "curl or wget is required. Please install it and try again."
  fi
}

git_clone() {
  command git clone --progress --depth 1 --branch "$BOPT" "$1" "$2" 2>&1 | { "$GIT_BAR" || cat; } 2>/dev/null
}

prepare_installer() {
  # Check for required commands
  say_info "Checking for dependencies..."
  check_cmd git
  check_cmd zsh
  # Establish Zi home directory
  if [ -z "$ZI_HOME" ]; then
    if [ -d "${HOME}" ]; then
      ZSH_HOME_DIR="$HOME"
      ZI_HOME="${HOME}/.zi"
    elif [ -d "${ZDOTDIR}" ]; then
      ZSH_HOME_DIR="$ZDOTDIR"
      ZI_HOME="${ZDOTDIR}/.zi"
    elif [ -d "${XDG_DATA_HOME}" ]; then
      ZSH_HOME_DIR="$XDG_DATA_HOME"
      ZI_HOME="${XDG_DATA_HOME}/.zi"
    fi
  fi
  if [ ! -d "$ZI_HOME" ]; then
    command mkdir -p "$ZI_HOME"
  fi
  if [ ! -w "$ZI_HOME" ]; then
    command chown -R "$(whoami)"
    command chmod -R go-w "$ZI_HOME"
  fi
  if [ -z "$ZI_BIN_DIR" ]; then
    ZI_BIN_DIR="${ZI_HOME}/bin"
  fi
  if [ ! -d "$ZI_BIN_DIR" ]; then
    command mkdir -p "$ZI_BIN_DIR"
  fi
  if [ ! -w "$ZI_BIN_DIR" ]; then
    command chown -R "$(whoami)"
    command chmod -R go-w "$ZI_BIN_DIR"
  fi
  if [ -z "$ZSH_CACHE_DIR" ]; then
    ZSH_CACHE_DIR="${ZSH_HOME_DIR}/.cache/zi"
  fi
  if [ ! -d "$ZSH_CACHE_DIR" ]; then
    command mkdir -p "$ZSH_CACHE_DIR"
  fi
  if [ ! -w "$ZSH_CACHE_DIR" ]; then
    command chown -R "$(whoami)"
    command chmod -R go-w "$ZSH_CACHE_DIR"
  fi
  if [ -z "$ZSH_LOG_DIR" ]; then
    ZSH_LOG_DIR="${ZSH_HOME_DIR}/.cache/zi/logs"
  fi
  if [ -z "$ZSH_LOG_FILE" ]; then
    ZSH_LOG_FILE="${ZSH_LOG_DIR}/$(date +%Y-%m-%d).log"
  fi
  if [ ! -f "$GIT_BAR" ]; then
    download "$GIT_BAR_URL" "$GIT_BAR"
  fi
}

check_zshrc() {
  # Check if Zi is already installed
  if [ -f "${ZSH_HOME_DIR}/.zshrc" ]; then
    if grep -E '(zi|init|zinit)\.zsh' "${ZSH_HOME_DIR}/.zshrc" >/dev/null 2>&1; then
      say_info "Zi already set in .zshrc, backing up to .zshrc.bak-${SET_TIME}"
      command mv "${ZSH_HOME_DIR}/.zshrc" "${ZSH_HOME_DIR}/.zshrc.bak-${SET_TIME}"
      return 0
    fi
    say_info "Backing up to current .zshrc to .zshrc.bak-${SET_TIME}"
    command mv "${ZSH_HOME_DIR}/.zshrc" "${ZSH_HOME_DIR}/.zshrc.bak-${SET_TIME}"
    return 0
  else
    say_info "No .zshrc found, skipping configuration..."
    return 0
  fi
}

set_repository() {
  prepare_installer "$@"
  if [ -d "${ZI_BIN_DIR}/.git" ]; then
    builtin cd "${ZI_BIN_DIR}" && say_info "Found Zi at $ZI_BIN_DIR, updating..."
    command git clean --quiet -d -f -f
    command git reset --quiet --hard HEAD
    command git pull --quiet origin HEAD
    say_ok "■■■■■■■■■■■■■■■■■ Update successful! ■■■■■■■■■■■■■■■"
  elif [ -d "$ZI_BIN_DIR" ]; then
    git_clone "$ZI_REPO" "$ZI_BIN_DIR" || say_err "Failed to clone Zi!"
    if [ -f "${ZI_BIN_DIR}/zi.zsh" ]; then
      say_ok "■■■■■■■■■■■■■■■■ Install successful! ■■■■■■■■■■■■■■■"
      if [ "$ZOPT" = skip ]; then
        exit 0
      fi
      return 0
    fi
  fi
}

set_loader() {
  # Establish Zi config directory
  if [ -z "$ZI_CONFIG_DIR" ]; then
    ZI_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/zi"
  fi

  if [ ! -d "$ZI_CONFIG_DIR" ]; then
    command mkdir -p "$ZI_CONFIG_DIR"
  fi

  if [ ! -w "$ZI_CONFIG_DIR" ]; then
    command chmod go-w "$ZI_CONFIG_DIR"
  fi

  if [ ! -f "${ZI_CONFIG_DIR}/init.zsh" ]; then
    download "$LOADER_URL" "${ZI_CONFIG_DIR}/init.zsh"
    command sed -i "s/branch=\"main\"/branch=\"${BOPT}\"/g" "${ZI_CONFIG_DIR}/init.zsh"
  else
    download "$LOADER_URL" "${ZI_CONFIG_DIR}/init.zsh"
    command sed -i "s/branch=\"main\"/branch=\"${BOPT}\"/g" "${ZI_CONFIG_DIR}/init.zsh"
  fi
  check_zshrc
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Zi Loader ========================================================================================================= #
# https://wiki.zshell.dev/docs/getting_started/installation
if [[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" && zzinit
fi

EOF
  zsh -ilc "@zi-scheduler burst"
  say_ok "■■■■■■■■■■■■■■■■ Successfully created .zshrc ■■■■■■■■■■■■"
  return 0
}

set_installer() {
  check_zshrc
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Zi source directory =============================================================================================== #
# https://wiki.zshell.dev/docs/guides/customization#customizing-paths
typeset -A ZI
ZI[BIN_DIR]="$ZI_BIN_DIR"

# Auto install Zi =================================================================================================== #
if [[ ! -f \${ZI[BIN_DIR]}/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "\$ZI[BIN_DIR]" && \\
  command git clone -q --branch "${BOPT}" $ZI_REPO "\${ZI[BIN_DIR]}" && \\
  print -P "%F{33}▓▒░ %F{34}Installation successful…%f%b" || print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Enable Zi ========================================================================================================= #
# https://wiki.zshell.dev/docs/getting_started/installation#manual-setup
source "\${ZI[BIN_DIR]}/zi.zsh"
autoload -Uz _zi
(( \${+_comps} )) && _comps[zi]=_zi

EOF
  zsh -ilc "@zi-scheduler burst"
  say_ok "■■■■■■■■■■■■■■■■ Successfully created .zshrc ■■■■■■■■■■■■"
  return 0
}

set_omz_lib() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Oh-My-Zsh lib ===================================================================================================== #
# https://wiki.zshell.dev/docs/getting_started/migration#omz-library
zi is-snippet wait lucid for \\
    OMZL::{git,theme-and-appearance,prompt_info_functions,vcs_info}.zsh \\
  atinit'COMPLETION_WAITING_DOTS=true' \\
    OMZL::completion.zsh \\
  atinit'typeset -gx HISTSIZE=290000 SAVEHIST=290000 HISTFILE=${ZSH_CACHE_DIR}/.history' \\
    OMZL::history.zsh

EOF
}

set_omz_plugins() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Oh-My-Zsh plugins ================================================================================================= #
# https://wiki.zshell.dev/docs/getting_started/migration#omz-plugins
zi is-snippet wait lucid for \\
  atload"unalias grv" \\
    OMZP::git \\
  if'[[ -d ~/.ssh ]]' \\
    OMZP::ssh-agent \\
  if'[[ -d ~/.gnupg ]]' \\
    OMZP::gpg-agent

EOF
}

set_omz_themes() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Oh-My-Zsh theme =================================================================================================== #
# https://wiki.zshell.dev/community/gallery/collection/themes
# https://wiki.zshell.dev/docs/getting_started/migration#omz-themes
zi wait'!' lucid for \\
  atinit'setopt prompt_subst' \\
    OMZT::robbyrussell

EOF
}

set_plugins() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Popular plugins =================================================================================================== #
# https://wiki.zshell.dev/ecosystem
# https://wiki.zshell.dev/community/gallery/collection/plugins
zi wait lucid for \\
  atinit'ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \\
    z-shell/F-Sy-H \\
  atload'!_zsh_autosuggest_start' \\
    zsh-users/zsh-autosuggestions \\
  # blockf atpull' zi creinstall -q .' \\
    zsh-users/zsh-completions \\
  atinit'zstyle ":history-search-multi-word" page-size "7"' \\
    z-shell/H-S-MW
EOF
}

set_themes() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
# Popular themes ==================================================================================================== #
# https://wiki.zshell.dev/community/gallery/collection/themes

EOF
}

set_annexes() {
  command cat <<-EOF >>"$ZSH_HOME_DIR/.zshrc"
#  Meta-plugins & annexes =========================================================================================== #
# https://wiki.zshell.dev/ecosystem/category/-annexes
zi for \\
  z-shell/z-a-meta-plugins \\
    @annexes

EOF
}

set_zpmod() {
  check_cmd make

  # Establish zpmod directory
  if [ -z "$MOD_HOME" ]; then
    MOD_HOME="${ZI_HOME}/zmodules/zpmod"
  fi

  if [ ! -d "$MOD_HOME" ]; then
    command mkdir -p "$MOD_HOME"
  fi

  if [ ! -w "$MOD_HOME" ]; then
    command chmod go-w "$MOD_HOME"
  fi

  if [ -d "${MOD_HOME}/.git" ]; then
    say_info "Updating ZPMOD at $MOD_HOME"
    builtin cd "$MOD_HOME" && command git pull -q --ff-only origin main
  else
    say_info "Downloading ZPMOD to $MOD_HOME"
    command git clone -q "$MOD_REPO" "$MOD_HOME"
  fi

  say_info "Checking version for zsh..."
  ZSH_CURRENT=$(zsh --version </dev/null | head -n1 | cut -d" " -f2,6- | tr -d '-')
  ZSH_REQUIRED="5.8.1"
  if expr "${ZSH_CURRENT}" \< "${ZSH_REQUIRED}" >/dev/null; then
    say_err "Zsh version 5.8.1 and above required."
  else
    say_info "Zsh version ${ZSH_CURRENT} is compatible."
    builtin cd "$MOD_HOME" || err "Failed to change directory to $MOD_HOME."
    say_info "Building module ZPMOD, running: a make clean, then ./configure and then make."
    say_info "The module source are located at: $MOD_HOME"
    if test -f Makefile; then
      if [ "$1" = "--clean" ]; then
        say_info "Running: make distclean..."
        make distclean
        true
      else
        say_info "Running: make clean (pass --clean to invoke \`make distclean')..."
        make clean
      fi
    fi
    say_info "Configuring..."
    if CPPFLAGS=-I/usr/local/include CFLAGS="-g -Wall -O3" LDFLAGS=-L/usr/local/lib ./configure --disable-gdbm --without-tcsetpgrp; then
      say_info "Building..."
      if make -s; then
        command cat <<-EOF
[38;5;219m▓▒░[0m [38;5;220mModule [38;5;177mhas been built correctly.
[38;5;219m▓▒░[0m [38;5;220mTo [38;5;160mload the module, add following [38;5;220m2 lines to [38;5;172m.zshrc, at top:
[0m [38;5;51m module_path+=( "${MOD_HOME}/Src" )
[0m [38;5;51m zmodload zi/zpmod
[38;5;219m▓▒░[0m [38;5;220mSee 'zpmod -h' for more information.
[38;5;219m▓▒░[0m [38;5;220mRun 'zpmod source-study' to see profile data,
[38;5;219m▓▒░[0m [38;5;177mGuaranteed, automatic compilation of any sourced script.
EOF
      else
        say_err "Module failed build. Please report error at: ${MOD_REPO}/issues"
      fi
    fi
  fi
}

interactive_zshrc() {
  if [ "$ZOPT" != skip ] && [ "$AOPT" = interactive ]; then
    say_info "Creating .zshrc interactively..."
    if ask "Install Zi Loader?"; then
      set_loader
    else
      set_installer
    fi

    if ask "Install annexes?"; then
      set_annexes
    fi

    if ask "Add recommended Oh-My-Zsh library?"; then
      set_omz_lib
    fi

    if ask "Add recommended Oh-My-Zsh plugins?"; then
      set_omz_plugins
    fi

    if ask "Add recommended Oh-My-Zsh theme?"; then
      set_omz_themes
    fi

    if ask "Add recommended plugins?"; then
      set_plugins
    fi

    zsh -ilc "@zi-scheduler burst"
    command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■ Successfully created .zshrc ■■■■■■■■■■■■[0m
EOF
    return 0
  fi
}

default_zshrc() {
  if [ "$ZOPT" != skip ] && [ "$AOPT" = default ]; then
    say_info "Creating .zshrc file..."
    set_loader
    set_annexes
    set_omz_lib
    set_omz_plugins
    set_omz_themes
    set_plugins

    zsh -ilc "@zi-scheduler burst"
    command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■ Successfully created .zshrc ■■■■■■■■■■■■[0m
EOF
    return 0
  fi
}

MAIN() {
  set_repository "$@"
  if [ "$AOPT" = loader ]; then
    set_loader
  fi
  command cat <<-EOF
[34m▓▒░[0m[38;5;226m Wiki:         https://wiki.zshell.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://discussions.zshell.dev[0m
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■[0m
EOF
  exit_code=$?
  exit $exit_code
}

while true; do
  MAIN "${@}"
done

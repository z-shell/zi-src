#!/usr/bin/env sh
# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=sh sw=2 ts=2 et
trap 'rm -rf "$WORKDIR"' EXIT INT
WORKDIR="$(mktemp -d)"

col_pname="[33m"
col_error="[31m"
col_info="[32m"
col_rst="[0m"
zsh_current=$(zsh --version </dev/null | head -n1 | cut -d" " -f2,6- | tr -d '-')
zsh_required="5.8.1"

usage() {
  cat 1>&2 <<EOF
The installer for ZI
EOF
}

info() { printf '[0m❮ [32mZI [0m❯: %s\n' "$1"; }
say() { printf '%s\n' "$1"; }
err() {
  say "${col_error}${1}" >&2
  exit 1
}

_os_type() {
  OS="$(command -v uname)"
  case $("${OS}" | tr '[:upper:]' '[:lower:]') in
  android*)
    OS='android'
    ;;
  darwin*)
    OS='darwin'
    ;;
  linux*)
    OS='linux'
    ;;
  freebsd*)
    OS='freebsd'
    ;;
  netbsd*)
    OS='netbsd'
    ;;
  openbsd*)
    OS='openbsd'
    ;;
  sunos*)
    OS='solaris'
    ;;
  msys* | cygwin* | mingw*)
    OS='windows'
    ;;
  nt | win*)
    OS='windows'
    ;;
  *)
    echo 'OS not supported'
    ;;
  esac
}

_cpu_type() {
  case "$(uname -m)" in
  x86_64 | x86-64 | x64 | amd64)
    ARCH='amd64'
    ;;
  i?86 | x86)
    ARCH='386'
    ;;
  armv8* | aarch64 | arm64)
    ARCH='arm64'
    ;;
  armv7*)
    ARCH='armv7'
    ;;
  armv6*)
    ARCH='armv6'
    ;;
  arm*)
    ARCH='arm'
    ;;
  mips64le*)
    ARCH='mips64le'
    ;;
  mips64*)
    ARCH='mips64'
    ;;
  mipsle*)
    ARCH='mipsle'
    ;;
  mips*)
    ARCH='mips'
    ;;
  ppc64le*)
    ARCH='ppc64le'
    ;;
  ppc64*)
    ARCH='ppc64'
    ;;
  ppcle*)
    ARCH='ppcle'
    ;;
  ppc*)
    ARCH='ppc'
    ;;
  s390*)
    ARCH='s390x'
    ;;
  *)
    echo 'OS architecture not supported'
    ;;
  esac
}

# Synopsis:
#
# annex: (available: recommended)
#   -a recommended
# branch: (available: main or any other existing branch)
#   -b main
# configuration directory: (default: ~/.config/zi, can be overridden to prefered location)
#   -c ${HOME}/.config/zi
# ZI home directory (default: ~/.zi, can be overriden prefered location)
#   -d ${HOME}/.zi
# zshrc header: (available loader, installer)
#   -e loader
# clone options: (default: --progress, can be overridden to prefered git clone options)
#   -o --progress
# make/build options: (build, make additonal. Available: zpmod)
#   -m zpmod
# host to use: (default: host to use. Available: github.com, gitlab.com)
#   -h github.com
# install profile: (profile to run: install, uninstall)
#   -p install
# snippets: (group of snippets to install: not-available yet)
#   -s not-available yet
# plugins: group of plugins to install: not-available yet)
#   -s not-available yet
#
# Example: ./install.sh -p install -c ~/.config/zi -d ~/.zi -e loader -o --progress -m zpmod -h github.com

while getopts ":a:b:c:d:e:o:m:h:p:z:s:" opt; do
  case ${opt} in
  a)
    ANNEX="${ANNEX}${OPTARG}"
    ;;
  b)
    BRANCH="${BRANCH}${OPTARG}"
    ;;
  c)
    CONFIG_DIR="${CONFIG_DIR}${OPTARG}"
    ;;
  d)
    ZI_HOME="${ZI_HOME}${OPTARG}"
    ;;
  e)
    ZHEADER="${ZHEADER}${OPTARG}"
    ;;
  o)
    CLONE_OPTS="${CLONE_OPTS}${OPTARG}"
    ;;
  m)
    MAKE="${MAKE}${OPTARG}"
    ;;
  h)
    HOST="${HOST}${OPTARG}"
    ;;
  p)
    PROFILE="${PROFILE}${OPTARG}"
    ;;
  z)
    OMZ="${OMZ}${OPTARG}"
    ;;
  s)
    STD="${STD}${OPTARG}"
    ;;
  \?)
    err "Invalid option: ${OPTARG}" 1>&2
    ;;
  :)
    err "Invalid option: ${OPTARG} requires an argument" 1>&2
    ;;
  *)
    err "Invalid option: ${OPTARG}" 1>&2

    ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${PROFILE}" ]; then
  # Available profiles: install, uninstall, main.
  PROFILE="main"
fi
if [ -z "${HOST}" ]; then
  # Default host
  HOST="github.com"
fi
if [ -z "${BRANCH}" ]; then
  # Default branch
  BRANCH="main"
fi
if [ -z "${CLONE_OPTS}" ]; then
  # Default git clone options
  CLONE_OPTS="--progress"
fi
if [ -z "${ZI_HOME}" ]; then
  # Installiation time ZI home directory
  ZI_HOME="${ZDOTDIR:-${HOME}}/.zi"
fi
if [ -z "${ZI_BIN_DIR_NAME}" ]; then
  # ZI bin directory
  ZI_BIN_DIR_NAME="bin"
fi
if [ -z "${CONFIG_DIR}" ]; then
  # Default configuration directory
  CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/zi"
fi
if [ -z "${ZHEADER}" ]; then
  # Default header script
  ZHEADER="loader"
fi

_set_externals() {
  if ! command -v git >/dev/null 2>&1; then
    err "[1;31m▓▒░[0m Something went wrong: [1;32mgit[0m not available, cannot proceed."
  fi
  if [ "${HOST}" = github.com ]; then
    if curl -fsL https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh >/dev/null; then
      RAW_LOADER_URL="https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh"
      if curl -fsL https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh >/dev/null; then
        RAW_GIT_OUPUT="https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh"
      else
        err "Git process script at GitHub is not reachable"
      fi
    else
      err "GitLab and GitHub repositories are unreachable"
    fi
  elif [ "${HOST}" = gitlab.com ]; then
    if curl -fsL https://gitlab.com/ss-o/zi-src/-/raw/main/lib/zsh/init.zsh >/dev/null; then
      RAW_LOADER_URL="https://gitlab.com/ss-o/zi-src/-/raw/main/lib/zsh/init.zsh"
      if curl -fsL https://gitlab.com/ss-o/zi/-/raw/main/lib/zsh/git-process-output.zsh >/dev/null; then
        RAW_GIT_OUPUT="https://gitlab.com/ss-o/zi/-/raw/main/lib/zsh/git-process-output.zsh"
      else
        err "Git process script at GitLab is not reachable"
      fi
    fi
  fi
  # Get the download-progress bar tool
  if command -v curl >/dev/null 2>&1; then
    command mkdir -p "${WORKDIR}"
    cd "${WORKDIR}" || return
    command curl -fsSLO "${RAW_GIT_OUPUT}" && command chmod a+x "${WORKDIR}"/git-process-output.zsh
  elif command -v wget >/dev/null 2>&1; then
    command mkdir -p "${WORKDIR}"
    cd "${WORKDIR}" || return
    command wget -q "${RAW_GIT_OUPUT}" && command chmod a+x "${WORKDIR}"/git-process-output.zsh
  else
    say "[1;31m▓▒░[0m Something went wrong:"
    err "[1;32mcurl[0m or [1;32mwget[0m not available or failed to create temp directory, cannot proceed."
  fi
}

_check_zshrc() {
  THE_ZDOTDIR="${ZDOTDIR:-${HOME}}"
  say "[34m▓▒░[0m[1;36m Updating ${THE_ZDOTDIR}/.zshrc"
  if grep -E '(zi|init|zinit)\.zsh' "${THE_ZDOTDIR}/.zshrc" >/dev/null 2>&1; then
    say "[34m▓▒░[34m File .zshrc have conflicting commands, backuping..."
    say "[34m▓▒░[34m creating backup at ${CONFIG_DIR}/zshrc..."
    date=$(date +%H%M%S) && command mv -f "${THE_ZDOTDIR}/.zshrc" "${CONFIG_DIR}/zshrc.${date}"
  fi
}

_set_zshrc_header() {
  # current zshrc headers: (loader, installer)
  _check_zshrc
  if [ "${ZHEADER}" = loader ]; then
    if command -v curl >/dev/null 2>&1; then
      command curl -fsSL "${RAW_LOADER_URL}" -o "${CONFIG_DIR}/init.zsh"
    elif command -v wget >/dev/null 2>&1; then
      command wget -qO "${CONFIG_DIR}/init.zsh" "${RAW_LOADER_URL}"
    else
      err "[1;31m▓▒░[0m Something went wrong:[1;32m curl and wget[0m not available, cannot proceed."
    fi
    command chmod a+x "${CONFIG_DIR}/init.zsh"
    command sed -i "s/branch=\"main\"/branch=\"${BRANCH}\"/g" "${CONFIG_DIR}/init.zsh"
    command cat <<-EOF >>"${THE_ZDOTDIR}/.zshrc"
if [[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" && zzinit
fi
EOF
    say "[34m▓▒░[0m[1;36m Loader added successfully.[0m"
  elif [ "${ZHEADER}" = installer ]; then
    command cat <<-EOF >>"${THE_ZDOTDIR}/.zshrc"
if [[ ! -f ${ZI_HOME}/${ZI_BIN_DIR_NAME}/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "${ZI_HOME}" && command chmod g-rwX "${ZI_HOME}"
  command git clone ${CLONE_OPTS} --branch "${BRANCH}" https://${HOST}/z-shell/zi "${ZI_HOME}/${ZI_BIN_DIR_NAME}" && \\
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \\
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "${ZI_HOME}/${ZI_BIN_DIR_NAME}/zi.zsh"
autoload -Uz _zi
(( \${+_comps} )) && _comps[zi]=_zi
EOF
  else
    true
  fi
}

_setup_directories() {
  _set_externals "$@"
  if ! test -d "${ZI_HOME}"; then
    command mkdir "${ZI_HOME}"
    command chmod g-w "${ZI_HOME}"
    command chmod o-w "${ZI_HOME}"
  fi
  if ! test -d "${ZI_HOME}/${ZI_BIN_DIR_NAME}"; then
    command mkdir "${ZI_HOME}/${ZI_BIN_DIR_NAME}"
    command chmod g-w "${ZI_HOME}/${ZI_BIN_DIR_NAME}"
    command chmod o-w "${ZI_HOME}/${ZI_BIN_DIR_NAME}"
  fi
  if ! test -d "${CONFIG_DIR}"; then
    command mkdir "${CONFIG_DIR}"
    command chmod g-w "${CONFIG_DIR}"
    command chmod o-w "${CONFIG_DIR}"
  fi
  _set_zshrc_header "$@"
}

_setup_profile() {
  _setup_directories "$@"
  if [ "${PROFILE}" = install ]; then
    if test -d "${ZI_HOME}/${ZI_BIN_DIR_NAME}/.git"; then
      cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || return
      say "[34m▓▒░[0m Updating [1;36m(z-shell/zi)[1;33m plugin manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      command git clean -d -f -f
      command git reset --hard HEAD
      command git pull -q origin HEAD
      command git submodule update --init --recursive
      command git submodule update --recursive --remote
      say "[34m▓▒░[0m [1;32mSuccessfully installed [1;36m(z-shell/zi)[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
    else
      cd "${ZI_HOME}" || return
      say "[34m▓▒░[0m Installing [1;36m(z-shell/zi)[1;33m plugin manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      { git clone "${CLONE_OPTS}" --branch "${BRANCH}" https://"${HOST}"/z-shell/zi.git "${ZI_BIN_DIR_NAME}" \
        2>&1 | { "${WORKDIR}/out/git-process-output.zsh" || cat; }; } 2>/dev/null
      if [ -d "${ZI_BIN_DIR_NAME}" ]; then
        say "[34m▓▒░[0m Successfully installed at [1;32m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m".
      else
        err "[1;31m▓▒░[0m Something went wrong, couldn't install ZI at [1;33m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      fi
    fi
  elif [ "${PROFILE}" = uninstall ]; then
    clear
    say "▓▒░ Remove ❮ ZI ❯? [y/N]"
    read -r confirmation
    if [ "${confirmation}" != y ] && [ "${confirmation}" != Y ]; then
      echo "Uninstall process cancelled"
      exit 0
    fi
    clear
    say "Removing ❮ ZI ❯ home directory"
    sleep 2
    if [ -d "${HOME}/.zi" ]; then
      rm -rvf "${HOME}/.zi"
    elif [ -d "${ZDOTDIR}/.zi" ]; then
      rm -rvf "${ZDOTDIR}/.zi"
    elif [ -d "${XDG_DATA_HOME}/.zi" ]; then
      rm -rvf "${XDG_DATA_HOME}/.zi"
    fi
    clear
    echo "▓▒░ Clean ❮ ZI ❯ cache?  [y/N]"
    read -r confirmation
    if [ "${confirmation}" != y ] && [ "${confirmation}" != Y ]; then
      echo "Cleaning ❮ ZI ❯ cache"
      sleep 2
      if [ -d "${HOME}/.cache/zi" ]; then
        rm -rvf "${HOME}/.cache/zi"
      elif [ -d "${ZDOTDIR}/.cache/zi" ]; then
        rm -rvf "${ZDOTDIR}/.cache/zi"
      elif [ -d "${XDG_DATA_HOME}/.cache/zi" ]; then
        rm -rvf "${XDG_DATA_HOME}/.cache/zi"
      fi
    fi
    clear
    echo "▓▒░ Remove ❮ ZI ❯ config directory?  [y/N]"
    read -r confirmation
    if [ "${confirmation}" != y ] && [ "${confirmation}" != Y ]; then
      echo "Removing ❮ ZI ❯ config directory"
      sleep 2
      if [ -d "${XDG_CONFIG_HOME}/zi" ]; then
        rm -rvf "${XDG_CONFIG_HOME}/zi"
      else
        if [ -d "${HOME}/.config/zi" ]; then
          rm -rvf "${HOME}/.config/zi"
        elif [ -d "${XDG_DATA_HOME}/zi" ]; then
          rm -rvf "${XDG_DATA_HOME}/zi"
        fi
      fi
    fi
    clear
    echo "▓▒░ Reload shell?  [y/N]"
    read -r confirmation
    if [ "${confirmation}" != y ] && [ "${confirmation}" != Y ]; then
      say "[34m▓▒░[0m Uninstall successful"
      command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ ❮ ZI ❯[0m
[34m▓▒░[0m[38;5;226m Wiki:         https://wiki.zshell.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://discussions.zshell.dev[0m"
EOF
      rm -rf "${WORKDIR}"
      exit 0
    else
      rm -rf "${WORKDIR}"
      exec "${SHELL}" -l
    fi
  elif [ "${PROFILE}" = main ]; then
    true
  else
    err "Invalid profile: ${PROFILE}" 1>&2
  fi
}

_make_build() {
  if [ "${MAKE}" = zpmod ]; then
    ZI_HOME="${ZI_HOME:-${ZDOTDIR:-${HOME}}/.zi}"
    MOD_HOME="${MOD_HOME:-zmodules}/zpmod"
    if ! test -d "${ZI_HOME}/${MOD_HOME}"; then
      mkdir -p "${ZI_HOME}/${MOD_HOME}"
      chmod g-rwX "${ZI_HOME}/${MOD_HOME}"
    fi
    say "${col_pname}== Downloading ZPMOD module to ${ZI_HOME}/${MOD_HOME}"
    if test -d "${ZI_HOME}/${MOD_HOME}/.git"; then
      cd "${ZI_HOME}/${MOD_HOME}" || return
      git pull -q origin main
    else
      cd "${ZI_HOME}" || return
      git clone "${CLONE_OPTS}" https://"${HOST}"/z-shell/zpmod.git "${MOD_HOME}"
    fi
    say "${col_pname}== Done"
    if command -v zsh >/dev/null; then
      say "${col_info}-- Checkig version --${col_rst}"
      if expr "${zsh_current}" \< "${zsh_required}" >/dev/null; then
        say "${col_error}-- Zsh version 5.8.1 and above required --${col_rst}"

      else
        say "${col_info}-- Zsh version ${zsh_current} --${col_rst}"
        cd "${ZI_HOME}/${MOD_HOME}" || return
        say "${col_pname}== Building module ZPMOD, running: a make clean, then ./configure and then make ==${col_rst}"
        say "${col_pname}== The module sources are located at: ${ZI_HOME}/${MOD_HOME} ==${col_rst}"
        if test -f Makefile; then
          if [ "$1" = "--clean" ]; then
            say "${col_info}-- make distclean --${col_rst}"
            make -s distclean
            true
          else
            say "${col_info}-- make clean (pass --clean to invoke \`make distclean') --${col_rst}"
            make -s clean
          fi
        fi
        say "${col_info}-- Configuring --${col_rst}"
        if CPPFLAGS=-I/usr/local/include CFLAGS="-g -Wall -O3" LDFLAGS=-L/usr/local/lib ./configure --disable-gdbm --without-tcsetpgrp; then
          say "${col_info}-- Running make --${col_rst}"
          if make -s; then
            command cat <<-EOF
[38;5;219m▓▒░[0m [38;5;220mModule [38;5;177mhas been built correctly.
[38;5;219m▓▒░[0m [38;5;220mSee 'zpmod -h' for more information.
[38;5;219m▓▒░[0m [38;5;220mRun 'zpmod source-study' to see profile data,
[38;5;219m▓▒░[0m [38;5;177mGuaranteed, automatic compilation of any sourced script.
EOF
            zpmod_file="${WORKDIR}/zpmod"
            command cat <<-EOF >>"${zpmod_file}"
module_path+=( "${ZI_HOME}/${MOD_HOME}/Src" )
zmodload zi/zpmod
EOF
            say "[34m▓▒░[0m[1;36m Enabling zpmod[0m"
            command cat "${zpmod_file}" >>"${THE_ZDOTDIR}/.zshrc"
            zsh -ic "@zi-scheduler burst"
          else
            say "${col_error}Module did not build.${col_rst}. You can copy the error messages and submit"
            err "error-report at: https://${HOST}/z-shell/zpmod/issues"
          fi
        fi
      fi
    else
      err "${col_error} Zsh is not installed. Please install zsh and try again.${col_rst}"
    fi
  else
    true
  fi
}

_set_annexes() {
  if [ "${ANNEX}" = recommended ]; then
    file="${WORKDIR}/annex_recommended"
    command cat <<-EOF >>"${file}"
zi light-mode for \\
  z-shell/z-a-meta-plugins \\
  @annexes # <- https://wiki.zshell.dev/ecosystem/category/-annexes
# examples here -> https://wiki.zshell.dev/community/gallery/collection
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands
EOF
    say "[34m▓▒░[0m[1;36m Installing annexes[0m"
    command cat "${file}" >>"${THE_ZDOTDIR}/.zshrc"
    zsh -ic "@zi-scheduler burst"
  else
    true
  fi
}

_finish_install() {
  git_refs="$(
    command cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || true
    command git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | head -3
  )"
  say "[34m▓▒░[0m[38;5;226m Latest changes:[0m"
  say "${git_refs}"
}

_system() {
  _os_type
  _cpu_type
  _setup_profile "$@"
  _make_build "$@"
  _set_annexes "$@"
  _finish_install "$@"
}

MAIN() {
  _system "$@"
  say "[34m▓▒░[0m[1;36m System: ${OS} - ${ARCH}"
  command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■ Successfully installed ❮ ZI ❯ ■■■■■■■■■[0m
[34m▓▒░[0m[38;5;226m Wiki:         https://wiki.zshell.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://discussions.zshell.dev[0m
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■[0m
EOF
  exit 0
}

while true; do
  MAIN "${@}"
done

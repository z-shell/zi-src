#!/usr/bin/env sh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

trap 'rm -rf "$WORKDIR"' EXIT INT
WORKDIR="$(ensure mktemp -d)/tmp"

col_pname="[33m"
col_error="[31m"
#col_info="[32m"
col_info2="[32m"
col_rst="[0m"

_get_ostype() {
	case $("$(command -v uname)" | tr '[:upper:]' '[:lower:]') in
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

while getopts ":a:b:c:d:e:f:g:h:i:j:k:l:" opt; do
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
  f)
    CLONE_OPTS="${CLONE_OPTS}${OPTARG}"
    ;;
  g)
    MAKE="${MAKE}${OPTARG}"
    ;;
  h)
    HOST="${HOST}${OPTARG}"
    ;;
  i)
    PROFILE="${PROFILE}${OPTARG}"
    ;;
  j)
    OMZ="${OMZ}${OPTARG}"
    ;;
  k)
    STD="${STD}${OPTARG}"
    ;;
  \?)
    echo "Invalid option: ${OPTARG}" 1>&2
    exit 1
    ;;
  :)
    echo "Invalid option: ${OPTARG} requires an argument" 1>&2
    exit 1
    ;;
  *)
    echo "Invalid option: ${OPTARG}" 1>&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${PROFILE}" ]; then
  PROFILE="main"
fi
if [ -z "${HOST}" ]; then
  HOST="github.com"
fi
if [ -z "${BRANCH}" ]; then
  BRANCH="main"
fi
if [ -z "${CLONE_OPTS}" ]; then
  CLONE_OPTS="--progress"
fi
if [ -z "${ZI_HOME}" ]; then
  ZI_HOME="${ZDOTDIR:-${HOME}}/.zi"
fi
if [ -z "${ZI_BIN_DIR_NAME}" ]; then
  ZI_BIN_DIR_NAME="bin"
fi
if [ -z "${CONFIG_DIR}" ]; then
  CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/zi"
fi
if [ -z "${ZHEADER}" ]; then
  ZHEADER="loader"
fi
if test -d "${WORKDIR}/test"; then
  echo "ERROR: Failed to set working directory: ${WORKDIR}/test" 1>&2
  exit 1
fi

DOWNLOAD_SET() {
  if ! command -v git >/dev/null 2>&1; then
    printf '%s\n' "[1;31m▓▒░[0m Something went wrong: [1;32mgit[0m not available, cannot proceed."
    exit 1
  fi
  if [ "${HOST}" = github.com ]; then
    if curl -fsL https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh >/dev/null; then
      RAW_LOADER_URL="https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh"
      if curl -fsL https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh >/dev/null; then
        RAW_GIT_OUPUT="https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh"
      else
        printf '%s\n' "Git process script at GitHub is not reachable"
        exit 1
      fi
    else
      printf '%s\n' "GitLab and GitHub repositories are unreachable"
      exit 1
    fi
  elif [ "${HOST}" = gitlab.com ]; then
    if curl -fsL https://gitlab.com/ss-o/zi-src/-/raw/main/lib/zsh/init.zsh >/dev/null; then
      RAW_LOADER_URL="https://gitlab.com/ss-o/zi-src/-/raw/main/lib/zsh/init.zsh"
      if curl -fsL https://gitlab.com/ss-o/zi/-/raw/main/lib/zsh/git-process-output.zsh >/dev/null; then
        RAW_GIT_OUPUT="https://gitlab.com/ss-o/zi/-/raw/main/lib/zsh/git-process-output.zsh"
      else
        printf '%s\n' "Git process script at GitLab is not reachable"
        exit 1
      fi
    fi
  fi
  # Get the download-progress bar tool
  if command -v curl >/dev/null 2>&1; then
    command mkdir -p "${WORKDIR}"/out
    cd "${WORKDIR}"/out || return
    command curl -fsSLO "${RAW_GIT_OUPUT}" && command chmod a+x "${WORKDIR}"/out/git-process-output.zsh
  elif command -v wget >/dev/null 2>&1; then
    command mkdir -p "${WORKDIR}"/out
    cd "${WORKDIR}"/out || return
    command wget -q "${RAW_GIT_OUPUT}" && command chmod a+x "${WORKDIR}"/out/git-process-output.zsh
  else
    printf '%s\n' "[1;31m▓▒░[0m Something went wrong:"
    printf '%s\n' "[1;32mcurl[0m or [1;32mwget[0m not available or failed to create temp directory, cannot proceed."
    exit 1
  fi
}

CHECK_ZSRC_FILE() {
  THE_ZDOTDIR="${ZDOTDIR:-${HOME}}"
  printf '%s\n' "[34m▓▒░[0m[1;36m Updating ${THE_ZDOTDIR}/.zshrc"
  if grep -E '(zi|init|zinit)\.zsh' "${THE_ZDOTDIR}/.zshrc" >/dev/null 2>&1; then
    printf '%s\n' "[34m▓▒░[34m File .zshrc have conflicting commands, backuping..."
    printf '%s\n' "[34m▓▒░[34m creating backup at ${CONFIG_DIR}/zshrc..."
    command mv -f "${THE_ZDOTDIR}/.zshrc" "${CONFIG_DIR}/zshrc.`date +%H%M%S`.bak"
  fi
}

SET_ZSHRC_HEADER() {
  CHECK_ZSRC_FILE || return
  if [ "${ZHEADER}" = loader ]; then
    if command -v curl >/dev/null 2>&1; then
      command curl -fsSL "${RAW_LOADER_URL}" -o "${CONFIG_DIR}/init.zsh"
    elif command -v wget >/dev/null 2>&1; then
      command wget -qO "${CONFIG_DIR}/init.zsh" "${RAW_LOADER_URL}"
    else
      printf '%s\n' "[1;31m▓▒░[0m Something went wrong:[1;32m curl and wget[0m not available, cannot proceed."
      exit 1
    fi
    command chmod a+x "${CONFIG_DIR}/init.zsh"
    command sed -i "s/branch=\"main\"/branch=\"${BRANCH}\"/g" "${CONFIG_DIR}/init.zsh"
    command cat <<-EOF >>"${THE_ZDOTDIR}/.zshrc"
if [[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" && zzinit
fi
EOF
    printf '%s\n' "[34m▓▒░[0m[1;36m Loader added successfully.[0m"
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
  fi
}

ENVIRONMENT_SET() {
  DOWNLOAD_SET "$@"
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
  SET_ZSHRC_HEADER "$@"
}

PROFILE_SET() {
  ENVIRONMENT_SET "$@"
  if [ "${PROFILE}" = update ]; then
    if test -d "${ZI_HOME}/${ZI_BIN_DIR_NAME}/.git"; then
      cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || return
      printf '%s\n' "[1;34m▓▒░[0m Reseting [1;36m(z-shell/zi)[1;33m repository[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      command git clean -d -f -f
      command git reset --hard HEAD
      command git pull -q origin HEAD
      command git submodule update --init --recursive
      command git submodule update --recursive --remote
      printf '%s\n' "[34m▓▒░[0m [1;32mSuccesfully updated[0m [1;36m(z-shell/zi)[0m repository at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
    else
      printf '%s\n' "[34m▓▒░[0m Update of [1;36m(z-shell/zi)[1;33m failed [0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      exit 1
    fi
  elif [ "${PROFILE}" = install ]; then
    if test -d "${ZI_HOME}/${ZI_BIN_DIR_NAME}/.git"; then
      cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || return
      printf '%s\n' "[34m▓▒░[0m Updating [1;36m(z-shell/zi)[1;33m plugin manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      command git clean -d -f -f
      command git reset --hard HEAD
      command git pull -q origin HEAD
      command git submodule update --init --recursive
      command git submodule update --recursive --remote
      printf '%s\n' "[34m▓▒░[0m [1;32mSuccessfully installed [1;36m(z-shell/zi)[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
    else
      cd "${ZI_HOME}" || return
      printf '%s\n' "[34m▓▒░[0m Installing [1;36m(z-shell/zi)[1;33m plugin manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      { git clone "${CLONE_OPTS}" --branch "${BRANCH}" https://"${HOST}"/z-shell/zi.git "${ZI_BIN_DIR_NAME}" \
        2>&1 | { "${WORKDIR}/out/git-process-output.zsh" || cat; }; } 2>/dev/null
      if [ -d "${ZI_BIN_DIR_NAME}" ]; then
        printf '%s\n' "[34m▓▒░[0m Successfully installed at [1;32m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m".
      else
        printf '%s\n' "[1;31m▓▒░[0m Something went wrong, couldn't install ZI at [1;33m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
      fi
    fi
  elif [ "${PROFILE}" = uninstall ]; then
    clear
    printf '%s\n' "▓▒░ Remove ❮ ZI ❯? [y/N]"
    read -r confirmation
    if [ "${confirmation}" != y ] && [ "${confirmation}" != Y ]; then
      echo "Uninstall process cancelled"
      exit 0
    fi
    clear
    printf '%s\n' "Removing ❮ ZI ❯ home directory"
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
      printf '%s\n' "[34m▓▒░[0m Uninstall successful"
      command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ ❮ ZI ❯[0m
[34m▓▒░[0m[38;5;226m Wiki:         https://z.digitalclouds.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://z.digitalclouds.dev/discussions[0m"
EOF
      rm -rf "${WORKDIR}"
      exit 0
    else
      rm -rf "${WORKDIR}"
      exec "${SHELL}" -l
    fi
  elif [ "${PROFILE}" = main ]; then
    # Main ZI
    true
  else
    echo "Invalid profile: ${PROFILE}" 1>&2
    exit 1
  fi
}

MAKE_BUILD() {
  if [ "${MAKE}" = zpmod ]; then
    ZI_HOME="${ZI_HOME:-${ZDOTDIR:-${HOME}}/.zi}"
    MOD_HOME="${MOD_HOME:-zmodules}/zpmod"
    if ! test -d "${ZI_HOME}/${MOD_HOME}"; then
      mkdir -p "${ZI_HOME}/${MOD_HOME}"
      chmod g-rwX "${ZI_HOME}/${MOD_HOME}"
    fi
    printf '%s\n' "${col_pname}== Downloading ZPMOD module to ${ZI_HOME}/${MOD_HOME}"
    if test -d "${ZI_HOME}/${MOD_HOME}/.git"; then
      cd "${ZI_HOME}/${MOD_HOME}" || return
      git pull -q origin main
    else
      cd "${ZI_HOME}" || return
      git clone "${CLONE_OPTS}" https://"${HOST}"/z-shell/zpmod.git "${MOD_HOME}"
    fi
    printf '%s\n' "${col_pname}== Done"
    if command -v zsh >/dev/null; then
      printf '%s\n' "${col_info2}-- Checkig version --${col_rst}"
      ZSH_CURRENT=$(zsh --version </dev/null | head -n1 | cut -d" " -f2,6- | tr -d '-')
      ZSH_REQUIRED="5.8.1"
      if expr "${ZSH_CURRENT}" \< "${ZSH_REQUIRED}" >/dev/null; then
        printf '%s\n' "${col_error}-- Zsh version 5.8.1 and above required --${col_rst}"
        exit 1
      else
        printf '%s\n' "${col_info2}-- Zsh version ${ZSH_CURRENT} --${col_rst}"
        cd "${ZI_HOME}/${MOD_HOME}" || return
        printf '%s\n' "${col_pname}== Building module ZPMOD, running: a make clean, then ./configure and then make ==${col_rst}"
        printf '%s\n' "${col_pname}== The module sources are located at: ${ZI_HOME}/${MOD_HOME} ==${col_rst}"
        if test -f Makefile; then
          if [ "$1" = "--clean" ]; then
            printf '%s\n' "${col_info2}-- make distclean --${col_rst}"
            make -s distclean
            true
          else
            printf '%s\n' "${col_info2}-- make clean (pass --clean to invoke \`make distclean') --${col_rst}"
            make -s clean
          fi
        fi
        printf '%s\n' "${col_info2}-- Configuring --${col_rst}"
        if CPPFLAGS=-I/usr/local/include CFLAGS="-g -Wall -O3" LDFLAGS=-L/usr/local/lib ./configure --disable-gdbm --without-tcsetpgrp; then
          printf '%s\n' "${col_info2}-- Running make --${col_rst}"
          if make -s; then
            command cat <<-EOF
[38;5;219m▓▒░[0m [38;5;220mModule [38;5;177mhas been built correctly.
[38;5;219m▓▒░[0m [38;5;220mTo [38;5;160mload the module, add following [38;5;220m2 lines to [38;5;172m.zshrc, at top:
[0m [38;5;51m module_path+=( "${ZI_HOME}/${MOD_HOME}/Src" )
[0m [38;5;51m zmodload zi/zpmod
[38;5;219m▓▒░[0m [38;5;220mSee 'zpmod -h' for more information.
[38;5;219m▓▒░[0m [38;5;220mRun 'zpmod source-study' to see profile data,
[38;5;219m▓▒░[0m [38;5;177mGuaranteed, automatic compilation of any sourced script.
EOF
          else
            printf '%s\n' "${col_error}Module didn't build.${col_rst}. You can copy the error messages and submit"
            printf '%s\n' "error-report at: https://${HOST}/z-shell/zpmod/issues"
          fi
        fi
      fi
    else
      printf '%s\n' "${col_error} Zsh is not installed. Please install zsh and try again.${col_rst}"
    fi
  else
    true
  fi
}

ANNEX_PROFILE() {
  if [ "${AOPT}" = annex ]; then
    file="${WORKDIR}/annex/temp-zsh-config"
    command cat <<-EOF >>"${file}"
zi light-mode for \\
  z-shell/z-a-meta-plugins \\
  @annexes # <- https://z.digitalclouds.dev/ecosystem/annexes
# examples here -> https://z.digitalclouds.dev/docs/gallery/collection
zicompinit # <- https://z.digitalclouds.dev/docs/guides/commands
EOF
    printf '%s\n' "[34m▓▒░[0m[1;36m Installing annexes[0m"
    command cat "${file}" >>"${THE_ZDOTDIR}/.zshrc"
    zsh -ic "@zi-scheduler burst"
  elif [ "${AOPT}" = zunit ]; then
    file2="${WORKDIR}/annex/temp-zunit-config"
    command cat <<-EOF >>"${file2}"
zi light-mode for \\
  z-shell/z-a-meta-plugins \\
  @annexes @zunit
EOF
    printf '%s\n' "[34m▓▒░[0m[1;36m Installing annexes + zunit[0m"
    command cat "${file2}" >>"${THE_ZDOTDIR}/.zshrc"
    zsh -ic "@zi-scheduler burst"
  else
    printf '%s\n' "[34m▓▒░[0m[1;36m Skipped all annexes[0m"
  fi
}

CLOSE_PROFILE() {
  git_refs="$(
    command cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || true
    command git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | head -10
  )"
  printf '%s\n' "[34m▓▒░[0m[38;5;226m Latest changes:[0m"
  printf '%s\n' "${git_refs}"
}

MAIN() {
  PROFILE_SET "$@"
  MAKE_BUILD "$@"
  command cat <<-EOF
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■ Successfully installed ❮ ZI ❯ ■■■■■■■■■[0m
[34m▓▒░[0m[38;5;226m Wiki:         https://z.digitalclouds.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://z.digitalclouds.dev/discussions[0m
[34m▓▒░[0m[1;36m ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■[0m
EOF
  exit 0
}

while true; do
  MAIN "${@}"
done

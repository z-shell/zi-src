#!/usr/bin/env sh

WORKDIR="$(mktemp -d)"

if [ -z "$ZI_HOME" ]; then
  ZI_HOME="${ZDOTDIR:-$HOME}/.zi"
fi

if [ -z "$ZI_BIN_DIR_NAME" ]; then
  ZI_BIN_DIR_NAME="bin"
fi

if ! test -d "$ZI_HOME"; then
  command mkdir "$ZI_HOME"
  command chmod g-w "$ZI_HOME"
  command chmod o-w "$ZI_HOME"
fi

if ! command -v git >/dev/null 2>&1; then
  echo "[1;31m▓▒░[0m Something went wrong: no [1;32mgit[0m available, cannot proceed."
  exit 1
fi

# Get the download-progress bar tool
if command -v curl >/dev/null 2>&1; then
  command mkdir -p /tmp/zi
  cd /tmp/zi || return
  command curl -fsSLO https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh &&
    command chmod a+x /tmp/zi/git-process-output.zsh
elif command -v wget >/dev/null 2>&1; then
  command mkdir -p /tmp/zi
  cd /tmp/zi || return
  command wget -q https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh &&
    command chmod a+x /tmp/zi/git-process-output.zsh
fi

echo
if test -d "${ZI_HOME}/${ZI_BIN_DIR_NAME}/.git"; then
  cd "${ZI_HOME}/${ZI_BIN_DIR_NAME}" || return
  echo "[1;34m▓▒░[0m Updating [1;36mZI[1;33m Initiative Plugin Manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
  command git pull -q origin HEAD
else
  cd "$ZI_HOME" || return
  echo "[1;34m▓▒░[0m Installing [1;36mZI[1;33m Initiative Plugin Manager[0m at [1;35m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
  { git clone --progress --depth=1 --single-branch https://github.com/z-shell/zi.git "$ZI_BIN_DIR_NAME" \
    2>&1 | { /tmp/zi/git-process-output.zsh || cat; }; } 2>/dev/null
  if [ -d "$ZI_BIN_DIR_NAME" ]; then
    echo
    echo "[1;34m▓▒░[0m ZI Succesfully installed at [1;32m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m".
  else
    echo
    echo "[1;31m▓▒░[0m Something went wrong, couldn't install ZI at [1;33m${ZI_HOME}/${ZI_BIN_DIR_NAME}[0m"
  fi
fi

#
# Modify .zshrc
#
THE_ZDOTDIR="${ZDOTDIR:-$HOME}"
RCUPDATE=1
if grep -E '(zi|init|zinit)\.zsh' "${THE_ZDOTDIR}/.zshrc" >/dev/null 2>&1; then
  echo "[34m▓▒░[0m Seems that .zshrc already has content– not making changes."
  RCUPDATE=0
fi
if [ $RCUPDATE -eq 1 ]; then
  echo "[34m▓▒░[0m Updating ${THE_ZDOTDIR}/.zshrc (10 lines of code, at the bottom)"
  ZI_HOME="$(echo "$ZI_HOME" | sed "s|$HOME|\$HOME|")"
  command cat <<-EOF >>"${THE_ZDOTDIR}/.zshrc"
if [[ ! -f ${ZI_HOME}/${ZI_BIN_DIR_NAME}/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$ZI_HOME" && command chmod g-rwX "$ZI_HOME"
  command git clone -q --depth=1 --single-branch https://github.com/z-shell/zi "${ZI_HOME}/${ZI_BIN_DIR_NAME}" && \\
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \\
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "${ZI_HOME}/${ZI_BIN_DIR_NAME}/zi.zsh"
autoload -Uz _zi
(( \${+_comps} )) && _comps[zi]=_zi
EOF
  file="${WORKDIR}/temp-file"
  command cat <<-EOF >>"$file"
zi light-mode for \\
  z-shell/z-a-meta-plugins
  annexes                #  <- https://github.com/z-shell/zi/wiki/Annexes

zicompinit
zicdreplay -q      #  <- https://github.com/z-shell/zi/wiki/Minimal-Setup
EOF
  printf '%s\n' "[34m▓▒░[0m Would you like to add annexes to the zshrc?"
  command cat "$file"
  printf "[34m▓▒░[0m Enter y/N and press Return: "
  read -r input
  if [ "$input" = y ] || [ "$input" = Y ]; then
    command cat "$file" >>"${THE_ZDOTDIR}/.zshrc"
    printf '%s\n' "[34m▓▒░[0m Done."
  else
    printf '%s\n' "[34m▓▒░[0m Done (skipped the annexes chunk)."
  fi
  command cat <<-EOF >>"${THE_ZDOTDIR}/.zshrc"
EOF
fi
command cat <<-EOF
[34m▓▒░[0m Successfully installed!
[34m▓▒░[0m [38;5;226m Wiki:         https://github.com/z-shell/zi/wiki
[34m▓▒░[0m [38;5;226m Discussions:  https://github.com/z-shell/zi/discussions
[34m▓▒░[0m [38;5;226m Issues:       https://github.com/z-shell/zi/issues
EOF

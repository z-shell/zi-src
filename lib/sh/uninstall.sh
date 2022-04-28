#!/usr/bin/env sh
#
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

trap '$(exit_script)' EXIT INT

rm_zi_home() {
  clear
  echo -e "Remove ❮ ZI ❯? [y/N]"
  read -r confirmation
  if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
    echo -e "Uninstall process cancelled"
    exit 0
  fi

  clear
  echo -e "Removing ❮ ZI ❯ home directory"
  sleep 2

  if [ -d "${HOME}/.zi" ]; then
    rm -rvf "${HOME}/.zi"
  elif [ -d "${ZDOTDIR}/.zi" ]; then
    rm -rvf "${ZDOTDIR}/.zi"
  elif [ -d "${XDG_DATA_HOME}/.zi" ]; then
    rm -rvf "${XDG_DATA_HOME}/.zi"
  fi
}

rm_zi_cache() {
  clear
  echo -e "Cleaning ❮ ZI ❯ cache"
  sleep 2

  if [ -d "${HOME}/.cache/zi" ]; then
    rm -rvf "${HOME}/.cache/zi"
  elif [ -d "${ZDOTDIR}/.cache/zi" ]; then
    rm -rvf "${ZDOTDIR}/.cache/zi"
  elif [ -d "${XDG_DATA_HOME}/.cache/zi" ]; then
    rm -rvf "${XDG_DATA_HOME}/.cache/zi"
  fi
}

rm_zi_config() {
  clear
  echo -e "Removing ❮ ZI ❯ config directory"
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
}

reload_shell() {
  clear
  echo -e "Reload shell?  [y/N]"
  read -r confirmation
  if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
    clear
    echo -e "Reload skipped"
  else
    exec "$SHELL" -l
  fi
}

exit_script() {
  clear
  command cat <<-EOF
[34m▓▒░[0m[1;36m Successfully uninstalled![0m
[34m▓▒░[0m[38;5;226m Wiki:         https://z.digitalclouds.dev[0m
[34m▓▒░[0m[38;5;226m Issues:       https://github.com/z-shell/zi/issues[0m
[34m▓▒░[0m[38;5;226m Discussions:  https://z.digitalclouds.dev/discussions[0m
EOF
  exit 0
}

MAIN() {
  rm_zi_home
  rm_zi_cache
  rm_zi_config
  reload_shell
  exit 0
}

while true; do
  MAIN "${@}"
done

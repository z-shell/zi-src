# Variables:
ZI_REPO="https://github.com/z-shell/zi.git"
ZI_BRANCH="main"
# Verbose output
ZI_VERBOSE="${ZI_VERBOSE:-off}"
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

git_exec() { builtin cd "${ZI[BIN_DIR]}"; command git "${@}"; }
zzversion() { git_exec describe --tags 2>/dev/null; }
zzsetup() {
  if [[ $ZI_VERBOSE = on ]]; then
    echo "(ZI): Checking if ZI (zi.zsh) is available."
  fi
  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    if [[ $ZI_VERBOSE = on ]]; then
      echo "(ZI): ZI (zi.zsh) is not found. Installing..."
    fi
  print -P "%F{33}▓▒░ %F{160}Installing interactive feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod g-rwX "${ZI[BIN_DIR]}"
  command git clone -q --progress --branch "$ZI_BRANCH" "$ZI_REPO" "${ZI[BIN_DIR]}"
    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      if [[ $ZI_VERBOSE = on ]]; then
        echo "(ZI): Installed and ZI (zi.zsh) is found"
      fi
      print -P "%F{33}▓▒░ %F{34}Successfully installed %F{160}(%F{33}z-shell/zi%F{160}) %F{34} Version:%F{160} (%F{33}$(zzversion)%F{160})%f%b"
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
  if [[ $ZI_VERBOSE = on ]]; then
    echo "(ZI): Loading ZI (zi.zsh)"
  fi
  source "${ZI[BIN_DIR]}/zi.zsh"
}

zzcomps() {
  if [[ $ZI_VERBOSE = on ]]; then
    echo "(ZI): Loading ZI (_zi) completion… (_zi)"
  fi
  autoload -Uz _zi
  (( ${+_comps} )) && _comps[zi]=_zi
}

zzinit() {
  if [[ $ZI_VERBOSE = on ]]; then
    echo "(ZI): Checking if (zi_setup) function status code is 0, before sourcing ZI (zi.zsh)"
  fi
  if zzsetup; then
  if [[ ${ZI_VERBOSE} = on ]]; then
    echo "(ZI): Loading ZI (zi.zsh)"
  fi
    zzsource
    zzcomps
    else
    exit 1
  fi
}

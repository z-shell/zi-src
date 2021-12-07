declare -A ZI
# Where ZI code resides, e.g.: "~/.zi/bin"
ZI[BIN_DIR]="${HOME}/.zi/bin"
# Where ZI should create all working directories, e.g.: "~/.zi"
ZI[HOME_DIR]="${HOME}/.zi"
# Which options should be loaded.
ZISRC="${ZISRC:-off}"
ZICOMPS="${ZICOMPS:-off}"
ZISETUP="${ZISETUP:-off}"
ZIVERBOSE="${ZIVERBOSE:-off}"

if [[ $ZISETUP = on ]]; then
if [[ $ZIVERBOSE = on ]]; then
  echo "Loading ZI setup..."
fi
  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{160}Installing interactive feature-rich plugin manager (%F{33}z-shell/zi%F{160})…%f%b"
    command mkdir -p "${ZI[BIN_DIR]}" && command chmod g-rwX "${ZI[BIN_DIR]}"
    command git clone -q https://github.com/ss-o/zi.git "${ZI[BIN_DIR]}"
    if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      print -P "%F{33}▓▒░ %F{34}Successfully installed (%F{33}z-shell/zi%F{160})%f%b"
    else
      print -P "%F{160}▓▒░ The clone has failed.%f%b"
      print -P "%F{160}▓▒░ Please report the issue:%f%b"
      print -P "%F{160}▓▒░ https://github.com/z-shell/zi/issues/new%f%b"
    fi
  fi
fi
if [[ $ZISRC = on ]]; then
if [[ $ZIVERBOSE = on ]]; then
  echo "Initializing ZI (zi.zsh)"
fi
  source "${ZI[BIN_DIR]}/zi.zsh"
fi
if [[ $ZICOMPS = on ]]; then
if [[ $ZIVERBOSE = on ]]; then
  echo "Initializing ZI completion…"
fi
  autoload -Uz _zi
  (( ${+_comps} )) && _comps[zi]=_zi
fi
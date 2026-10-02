# Two-line powerline bash prompt: #   (username) > folder > github branch > last command status (tick / error code)
#   ╰─❯❯ _
# Needs: Nerd Font, truecolor terminal.
# Icons are UTF-8 bytes, so this works in any locale.
# Use:  echo 'source ~/fancy-ps1-status.sh' >> ~/.bashrc

# RGB colors (edit to taste)
_BLUE="30;150;255"; _ORG="255;140;40"; _YEL="255;235;0"; _PUR="140;100;200"; _TEAL="0;188;212"
_RED="229;57;53";   _WHITE="255;255;255"; _BLACK="0;0;0"

_fg() { printf '\\[\\e[38;2;%sm\\]' "$1"; }
_bg() { printf '\\[\\e[48;2;%sm\\]' "$1"; }

__set_ps1() {
  local code=$?

  local rs='\[\e[0m\]'
  local sep=$'\356\202\260' lcap=$'\356\202\266' rcap=$'\356\202\264'
  local ps prev branch mark

  # Segment 1: username (blue) with rounded left cap
  ps="$(_fg $_BLUE)${lcap}$(_bg $_BLUE)$(_fg $_BLACK) "$'\357\204\240'" \033[1m $(_fg $_BLACK )\u \033[0m"
  prev=$_BLUE

  # Segment 2: folder (orange)
  ps+="$(_fg $prev)$(_bg $_ORG)${sep}$(_fg $_BLACK) "$'\357\201\273'" \W "
  prev=$_ORG

  # Segment 3: git branch (yellow), only inside a repo. ≡ = clean, pencil = changes
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git status --porcelain 2>/dev/null | head -n1)" ]; then
      mark=$'\357\201\204'      # pencil
    else
      mark=$'\342\211\241'      # ≡
    fi
    ps+="$(_fg $prev)$(_bg $_YEL)${sep}$(_fg $_BLACK) "$'\357\202\233'" "$'\356\202\240'" ${branch} ${mark} "
    prev=$_YEL
  fi

  # Segment 4: last command status (teal tick, or red cross + exit code) with rounded right cap
  local st=$_TEAL icon=$'\357\200\214'      # tick
  if [ "$code" -ne 0 ]; then st=$_RED; icon=$'\357\200\215'" $code"; fi   # cross + code
  ps+="$(_fg $prev)$(_bg $st)${sep}$(_fg $_WHITE) ${icon} "
  ps+="${rs}$(_fg $st)${rcap}${rs} "

  # Line 2: connector + chevrons (turn red if the last command failed)
  local c=$_BLUE
  ps+="\n$(_fg $c)"$'\342\225\260\342\224\200\342\235\257\342\235\257'" ${rs}" 

  PS1="$ps"
}

# Register once, even if this file gets sourced twice: a duplicate __set_ps1 in
# PROMPT_COMMAND would see $?=0 on its second run and always show the tick.
__pc=${PROMPT_COMMAND//__set_ps1/}
while [[ $__pc == *";;"* ]]; do __pc=${__pc//;;/;}; done
__pc=${__pc#;}; __pc=${__pc%;}
PROMPT_COMMAND="__set_ps1${__pc:+;$__pc}"
unset __pc

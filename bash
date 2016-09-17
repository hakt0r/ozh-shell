#!/bin/sh

_copyright(){ echo "
  ozh lightweight shell extensions
  2008-2016 - anx @ ulzq de (Sebastian Glaser)
  Licensed under GNU GPL v3"; }
_license(){ echo "
  ozh is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.

  ozh is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this software; see the file COPYING.  If not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA 02111-1307 USA

  http://www.gnu.org/licenses/gpl.html"; }

OZ_SHELL='bash'
OZ_SHELL_COLOR=true

shopt -s histappend
shopt -s checkwinsize
HISTSIZE=1000
HISTCONTROL=ignoredups:ignorespace
HISTFILESIZE=2000

export INTERACTIVE=
preexec_invoke_exec () {
  [ -z "$INTERACTIVE" ] && return
  [ -n "$COMP_LINE" -o "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return
  local this_command=$(history 1 | cut -f 4- -d ' ');
  preexec "$this_command";
  export INTERACTIVE=; true; }

set -o functrace > /dev/null 2>&1
shopt -s extdebug > /dev/null 2>&1
trap 'preexec_invoke_exec' DEBUG

PS1="\$ "
PS2="$(oz hook run uprompt)"
PROMPT_COMMAND='precmd; INTERACTIVE="yes"'

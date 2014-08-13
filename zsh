#!/bin/sh

_copyright(){ echo "
  ozh lightweight shell extensions
  2008-2014 - anx @ ulzq de (Sebastian Glaser)
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

OZ_SHELL='zsh'
OZ_SHELL_COLOR=true
OZ_SHELL_GLOBAL_ALIASES=true
OZ_SHELL_SUFFIX_ALIASES=true
PS2="$(oz hook run uprompt)"

_prompt_escape(){ awk 'BEGIN{RS="\x1b"}{for(i=0;i<length($0)+1;i++){b=substr($0,0,i);e=substr($0,i+1);if(match(substr(b,i,1),/[a-zA-Z]/))break};printf "%s%s%s%s",s,b,q,e;s="%{\x1b";q="%}"}'; }


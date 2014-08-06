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

git_make_bare(){
  pushd $1 || exit 1
  dirname=$(basename $PWD)
  pushd .git || exit 1
  git config --bool core.bare true
  popd
  cd ..
  mv $dirname $dirname.worktree
  mv $dirname.worktree/.git $dirname
  popd; }

git_lastcommit_color(){
  git log --abbrev-commit | awk '
    /^commit/{printf "'"$byellow$white$bold"'"$2"'"$R"'"}
    /^Author:/{printf "'"$bblue$white$bold"'"$2"'"$R"'";exit(0)}'; }

git_lastcommit(){
  git log --abbrev-commit | awk '/^commit/{printf $2}/^Author:/{printf $2;exit(0)}'; }

git_dirname(){
  # http://stackoverflow.com/questions/957928/is-there-a-way-to-get-to-the-git-root-directory-in-one-command
  echo $(basename $(git rev-parse --show-toplevel)); }

git_branch(){
  git branch --no-color 2> /dev/null | \
    sed '/^[^*]/d;s/* \(.*\)/(\1)/'; }

git_veryshortstat(){
  echo $(git status -s | cut -c 2 | uniq -c) | tr -d ' '; }

########

has_git(){ which git >/dev/null 2>/dev/null; }
is_scm(){ is_git || is_svn; }
is_git(){ test -d ./.git || git status >/dev/null 2>&1; }
is_svn(){ test -d "$PWD/.svn"; }

has_git && {
  Stage(){ is_git && git add $@; }
  Untrack(){ is_git && git rm --cache $@ && Commit "untrack: $*"; }
  Status(){ is_git && git status $@; }
  Diff(){ is_git && git diff $@ && return 0; }
  Commit(){ is_git && git commit -m "$*"; }
  CommitAll(){ is_git && git commit -a -m "$*"; }
  Push(){ is_git && git push origin master; }
  Pull(){ is_git && git pull; }
  Remove(){ is_git && git rm $@ && Commit "remove: $*"; }
  Amend(){ is_git && git commit --amend -m "$*"; }
  Checkout(){ is_git && git checkout $@; }
  Stash(){ is_git && git stash $@; }
  Reset(){ is_git && git reset $@; }
  Branch(){ is_git && git branch $@; }
  scm_longwidget(){
    is_git && printf "$byellow$black${bold}g$red%s$black%s$R%s" $(git_dirname) $(git_branch) $(git_lastcommit_color); }
  scm_shortwidget(){
    is_git && printf "${bred}$(git_dirname)${yellow}$(git_branch)${R}${red}$(git_veryshortstat)${R}"; }
} || {
  scm_longwidget(){  printf "${bred}g$R"; }
  scm_shortwidget(){ printf "${bred}g$R"; }; }

export _scm_last_state=""
scm_updated(){
  new="$(scm_longwidget)";
  if is_scm;then
    if [ "$_scm_last_state" = "$new" ];then
      return 1;
    else
      export _scm_last_state="$new";
      notify-send "$new"
      return 0;
    fi
  fi
  return 1; }

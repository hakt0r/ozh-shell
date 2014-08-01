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
  echo $(
  git log --abbrev-commit|head -n 5|sed "
    s/commit \(.*\)/${yellow}\1${R}/;
    s/Author: \(.*\) <\(.*\)>/${blue}\2${R}:/;
    s/Date: .*//;
    s/^[ ]\+//;s/\n\n/\n/g"
  );}

git_lastcommit(){
  echo $(
  git log --abbrev-commit|head -n 5|sed "
    s/commit \(.*\)/\1/;
    s/Author: \(.*\) <\(.*\)>/\2:/;
    s/Date: .*//;
    s/^[ ]\+//;s/\n\n/\n/g");}

git_dirname(){
  # http://stackoverflow.com/questions/957928/is-there-a-way-to-get-to-the-git-root-directory-in-one-command
  echo $(basename $(git rev-parse --show-toplevel)); }

git_branch(){
  git branch --no-color 2> /dev/null | \
    sed '/^[^*]/d;s/* \(.*\)/(\1)/'; }

git_veryshortstat(){
  echo $(git status -s | cut -c 2 | uniq -c) | tr -d ' ';}

########

has_git(){ which git >/dev/null 2>/dev/null; }

is_scm(){ is_git || is_svn; }

is_git(){ test -d ./.git || git status >/dev/null 2>&1; }

is_svn(){ test -d "$PWD/.svn"; }

Stage(){ is_git && git add $@;}

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

########

if has_git; then
  scm_longwidget(){ is_git \
    && printf "git:%{${red}%}$(git_dirname)${yellow}$(git_branch)${R}:$(git_lastcommit_color)";}

  scm_shortwidget(){ is_git \
      && printf "${red}$(git_dirname)${yellow}$(git_branch)${R}${red}$(git_veryshortstat)${R}";}
else
  scm_longwidget(){ is_git && print "$bgreen git $R"; return 0 ; }
  scm_shortwidget(){ is_git && print "$bgreen git $R"; return 0 ; }
fi

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
  return 1;}

########

prompt_xscope(){
  test ! -z "$M_SCOPE" && \
    printf "scope:$(mccyan)$M_SCOPE${R}"
  test ! -z "$M_DIR" && \
    printf "/$M_DIR";}

scm_install_notifier(){
  ozh_notify add chdir devel/scm scm_longwidget;}
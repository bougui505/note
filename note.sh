#!/usr/bin/env zsh
# -*- coding: UTF8 -*-

# Author: Guillaume Bouvier -- guillaume.bouvier@pasteur.fr
# https://research.pasteur.fr/en/member/guillaume-bouvier/
# 2020-01-24 10:52:12 (UTC+0100)

NOTEDIR="$HOME/notes/notes"
NOTEGIT="https://github.com/bougui505/notes/blob/master/notes"

# Colored output: (see: https://unix.stackexchange.com/a/276487/68794)
autoload colors; colors
for color (${(k)fg})
    eval "$color() {print -n \$fg[$color]; cat; print -n \$reset_color}"

function note-update () {
    CWD=$(pwd)
    cd $NOTEDIR && git pull
    cd $CWD
}

function note-push () {
    CWD=$(pwd)
    cd $NOTEDIR && git add -A && git commit -a -m "Note updated" && git push
    cd $CWD
}

function note-add () {
    note-update
    TIMESTAMP=$(date -Is | awk -F'+' '{print $1}' | tr ':' '-')
    FILENAME=$NOTEDIR/$TIMESTAMP.md
    nvim -c ":MarkdownPreview" -c ":ToggleAutosave" $FILENAME
    note-push
}

function _note-str () {
    printf "$1:t: " && cat $1 | tr '\n' ' '
    print ""
}

function _note-strings () {
    for X in $(ls $NOTEDIR/*.md); do
        _note-str $X
    done | sort -t:
}

function _note-search () {
    _note-strings | fzf -e --tac | awk -F: '{print $1}'
}

function note-search () {
    note-update
    OUT=$(_note-search)
    if [ ! -z "$OUT" ]; then
        nvim -c ":MarkdownPreview" -c ":ToggleAutosave" $NOTEDIR/$OUT
        note-push
    fi
}

function note-web () {
    note-update
    OUT=$(_note-search)
    if [ ! -z "$OUT" ]; then
        google-chrome $NOTEGIT/$OUT
    fi
}

function note-rm () {
    note-update
    CWD=$(pwd)
    cd $NOTEDIR
    OUT=$(_note-search)
    if [ ! -z "$OUT" ]; then
        git rm $OUT
        note-push
    fi
    cd $CWD
}

#!/usr/bin/env bash
printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' | grep -v "\(PPID\|SHELL\|BASH\|PATH\|\LS_COLORS|\PWD\|HOME)"  >  /root/env.sh
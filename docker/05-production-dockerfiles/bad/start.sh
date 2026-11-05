#!/bin/sh
# ⚠️ No `exec`: the shell stays as PID 1 and python runs as its child.
# The shell does not forward SIGTERM, so `docker stop` waits 10s and then SIGKILLs.
echo "starting app..."
python app.py

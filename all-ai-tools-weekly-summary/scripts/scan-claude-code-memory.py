#!/usr/bin/env python3
import glob
import os
from datetime import datetime, timedelta

start = (datetime.now() - timedelta(days=6)).replace(hour=0, minute=0, second=0)
for i in range(7):
    d = (start + timedelta(days=i)).strftime("%Y-%m-%d")
    for f in glob.glob(os.path.expanduser(f"~/.claude/projects/*/memory/{d}.md")):
        print(f)

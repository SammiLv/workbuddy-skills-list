#!/usr/bin/env python3
import json
import os
from datetime import datetime, timedelta

end = datetime.now().replace(hour=23, minute=59, second=59, microsecond=999000)
start = (end - timedelta(days=6)).replace(hour=0, minute=0, second=0, microsecond=0)
start_ms, end_ms = int(start.timestamp() * 1000), int(end.timestamp() * 1000)

seen = set()
with open(os.path.expanduser("~/.claude/history.jsonl")) as f:
    for line in f:
        d = json.loads(line)
        ts = d.get("timestamp", 0)
        if start_ms <= ts <= end_ms:
            sid = d["sessionId"]
            if sid in seen:
                continue
            seen.add(sid)
            if len(seen) > 30:
                break
            t = datetime.fromtimestamp(ts / 1000).strftime("%Y-%m-%d %H:%M")
            print(f"{sid}\t{t}\t{d.get('display', '')[:80]}\t{d.get('project', '')}")
print(f"TOTAL_SESSIONS={len(seen)}")

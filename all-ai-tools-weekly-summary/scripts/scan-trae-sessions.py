#!/usr/bin/env python3
import glob
import json
import os
import sqlite3
from datetime import datetime, timedelta

end = datetime.now().replace(hour=23, minute=59, second=59)
start = (end - timedelta(days=6)).replace(hour=0, minute=0, second=0)
start_s, end_s = int(start.timestamp()), int(end.timestamp())

TRAe_CN_MARKER = os.path.join("Application Support", "Trae CN")


def install_label(db_path):
    return "Trae CN" if TRAe_CN_MARKER in db_path else "Trae"


def oid_ts(session_id):
    try:
        return int(session_id[:8], 16)
    except Exception:
        return 0


bases = [
    ("Trae", os.path.expanduser("~/Library/Application Support/Trae/User/workspaceStorage")),
    (
        "Trae CN",
        os.path.expanduser("~/Library/Application Support/Trae CN/User/workspaceStorage"),
    ),
]

db_paths = []
for _label, base in bases:
    if os.path.isdir(base):
        for path in glob.glob(os.path.join(base, "*/state.vscdb")):
            db_paths.append(path)
db_paths.sort(key=os.path.getmtime, reverse=True)

seen = set()
by_install = {"Trae": 0, "Trae CN": 0}
scanned_installs = set()

for db_path in db_paths[:30]:
    label = install_label(db_path)
    scanned_installs.add(label)
    ws_id = os.path.basename(os.path.dirname(db_path))
    ws_json = os.path.join(os.path.dirname(db_path), "workspace.json")
    folder = ""
    if os.path.exists(ws_json):
        try:
            folder = json.loads(open(ws_json).read()).get("folder", "")
        except Exception:
            pass
    try:
        conn = sqlite3.connect(db_path)
        ws_hit = False
        row = conn.execute(
            "SELECT value FROM ItemTable WHERE key='memento/icube-ai-agent-storage'"
        ).fetchone()
        if row:
            for item in json.loads(row[0]).get("list", []):
                sid = item.get("sessionId") or item.get("id", "")
                ts = item.get("updatedAt") or item.get("createdAt") or oid_ts(sid)
                if ts > 1e12:
                    ts = int(ts / 1000)
                if start_s <= ts <= end_s and sid and sid not in seen:
                    seen.add(sid)
                    by_install[label] += 1
                    ws_hit = True
                    agent = ""
                    am = conn.execute(
                        "SELECT value FROM ItemTable WHERE key='icube_session_agent_map'"
                    ).fetchone()
                    if am:
                        agent = json.loads(am[0]).get(sid, "")
                    print(
                        f"SESSION\t{sid}\t{datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M')}\t{agent}\t{label}\t{ws_id}\t{folder[:60]}"
                    )
        hist = conn.execute(
            "SELECT value FROM ItemTable WHERE key='icube-ai-agent-storage-input-history'"
        ).fetchone()
        if hist and ws_hit:
            for item in json.loads(hist[0])[-8:]:
                text = (item.get("inputText") or "").replace("\n", " ")[:100]
                if text:
                    print(f"INPUT\t{text}\t{label}\t{ws_id}")
        conn.close()
    except Exception:
        pass

for name in ("Trae", "Trae CN"):
    status = "scanned" if name in scanned_installs else "missing"
    print(f"BY_INSTALL\t{name}\t{by_install[name]}\t{status}")
print(f"TOTAL_SESSIONS={len(seen)}")

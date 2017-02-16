#!/usr/bin/env python
import json
import os

fp = os.path.join(os.path.expanduser("~"), 'fbcode', 'compile_commands.json')
with open(fp) as fh:
    db = json.loads(fh.read())
for entry in db:
    entry.pop('arguments', None)
with open(fp, 'w') as fh:
    fh.write(json.dumps(db))

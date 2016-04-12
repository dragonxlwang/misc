#!/usr/bin/env python
import psutil
import sys

cpu_pct = psutil.cpu_percent(interval=1)
cpu_cnt = psutil.cpu_count()
mem_pct = psutil.virtual_memory().percent
mem_all = int(float(psutil.virtual_memory().total) / float(2**30))


if len(sys.argv) == 1:
    print u"\u24D2 {0:4}%:{1} \u24Dc {2:4}%:{3}".format(
        cpu_pct, cpu_cnt, mem_pct, mem_all).encode('utf-8')
elif sys.argv[1] == 'cpu':
    print u"\u24D2 {0:4}%:{1}".format(cpu_pct, cpu_cnt).encode('utf-8')
elif sys.argv[1] == 'mem':
    print u"\u24Dc {0:4}%:{1}".format(mem_pct, mem_all).encode('utf-8')
else:
    print "cpu_mem_lookup [mem, cpu]"

#!/usr/bin/python3

import os
import sys

import psutil

cpu_pct = psutil.cpu_percent(interval=1)
cpu_cnt = psutil.cpu_count()
mem_pct = psutil.virtual_memory().percent
mem_all = int(float(psutil.virtual_memory().total) / float(2 ** 30))
load = os.getloadavg()
load1min = load[0]

if load1min > 0.5 * cpu_cnt:
    color = "#[fg=red,bright]"
elif load1min > 0.1 * cpu_cnt:
    color = "#[fg=yellow,bright]"
else:
    color = "#[fg=cyan,bright]"


if len(sys.argv) == 1:
    print(
        "{0}"
        u"\u24C1 {1:04}"
        "#[default]"
        " "
        "#[fg=blue]"
        u"\u24D2 {2:04}%:{3}"
        "#[default]"
        " "
        "#[fg=yellow]"
        "\u24Dc {4:04}%:{5}"
        "#[default]".format(color, load1min, cpu_pct, cpu_cnt, mem_pct, mem_all)
    )
elif sys.argv[1] == "cpu":
    print(u"\u24D2 {0:04}%:{1}".format(cpu_pct, cpu_cnt))
elif sys.argv[1] == "mem":
    print(u"\u24Dc {0:04}%:{1}".format(mem_pct, mem_all))
else:
    print("cpu_mem_lookup [mem, cpu]")

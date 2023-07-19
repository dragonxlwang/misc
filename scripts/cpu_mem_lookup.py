#!/usr/bin/python3

import os
import shutil
import subprocess
import sys

import psutil

cpu_pct = psutil.cpu_percent(interval=1)
cpu_cnt = psutil.cpu_count()
mem_pct = psutil.virtual_memory().percent
mem_all = int(float(psutil.virtual_memory().total) / float(2**30))
load = os.getloadavg()
load1min = load[0]

if load1min > 0.5 * cpu_cnt:
    load_color = "#[fg=red,bright]"
elif load1min > 0.1 * cpu_cnt:
    load_color = "#[fg=yellow,bright]"
else:
    load_color = "#[fg=cyan,bright]"


if cpu_pct > 50:
    cpu_color = "#[fg=red,bright]"
else:
    cpu_color = "#[fg=blue]"
if mem_pct > 50:
    mem_color = "#[fg=red,bright]"
else:
    mem_color = "#[fg=yellow]"

gpus = 0
if shutil.which("nvidia-smi"):
    out = subprocess.check_output(
        [
            "nvidia-smi",
            "--query-gpu=utilization.gpu,utilization.memory,memory.total",
            "--format=csv,noheader,nounits",
        ]
    )
    out = [float(x) for ln in out.splits("\n") for x in ln.split(",")]
    gpus = len(out)
    gpu_mem = int(sum(g[2] for g in out)) / 1024
    util_gpu = sum(g[0] for g in out) / gpus
    util_mem = sum(g[1] for g in out) / gpus
    util_gpu_pct = int(util_gpu * 100)
    util_mem_pct = int(util_mem * 100)


if len(sys.argv) == 1:
    output = ""
    if gpus > 0:
        output += ("{}" "\u24BC {:04}%:{},{:04}%:{}" "#[default]" " ").format(
            util_gpu_pct, gpus, util_mem_pct, gpu_mem
        )
    output += (
        "{}"
        "\u24C1 {:04.2f}"
        "#[default]"
        " "
        "{}"
        "\u24D2 {:04}%:{}"
        "#[default]"
        " "
        "{}"
        "\u24Dc {:04}%:{}"
        "#[default]".format(
            load_color,
            load1min,
            cpu_color,
            cpu_pct,
            cpu_cnt,
            mem_color,
            mem_pct,
            mem_all,
        )
    )
    print(output)
elif sys.argv[1] == "cpu":
    print("\u24D2 {0:04}%:{1}".format(cpu_pct, cpu_cnt))
elif sys.argv[1] == "mem":
    print("\u24Dc {0:04}%:{1}".format(mem_pct, mem_all))
else:
    print("cpu_mem_lookup [mem, cpu]")

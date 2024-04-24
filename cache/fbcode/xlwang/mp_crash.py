import multiprocessing
import time

# from multiprocessing.context import SpawnProcess as Process
from multiprocessing import Process


def f(i: int):
    j = 0
    while True:
        print(f"==> f({i}), {j=}", flush=True)
        time.sleep(1)
        j += 1


def main():
    # procs = {i: Process(target=ff, args=[i]) for i in range(2)}
    procs = {i: Process(target=f, args=[i]) for i in range(2)}

    for p in procs.values():
        p.start()

    time.sleep(3)
    for i, p in procs.items():
        print(f"{i=}, {p.pid=}, {p.is_alive()=}", flush=True)
    raise Exception()
    # exit(1)

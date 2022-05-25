import time
from concurrent.futures import ProcessPoolExecutor

import click
import six
from pathos.pools import ProcessPool

x = 0


def mp(func):
    @click.option("-j", "nprocs", default=1)
    def wrapper(nprocs, **kwargs):
        # with ProcessPoolExecutor() as executor:
        #     for pid in range(nprocs):
        #         print(pid)
        #         print(kwargs)
        #         executor.submit(func, **kwargs)
        #         print("======>" + str(pid))
        #     executor.shutdown()

        # for pid in range(nprocs):
        #     print(pid)
        #     func(**kwargs)
        #     print("======>" + str(pid))

        pool = ProcessPool(nodes=nprocs)
        for pid in range(nprocs):
            print(pid)
            print(kwargs)
            pool.apipe(func, **kwargs)
            print("======>" + str(pid))

        pool.close()
        pool.join()
        pool.clear()

    return wrapper


@click.command()
@click.option("-n", "n", default=1)
@mp
def main(n):
    global x
    print(f"===> {n=}, {x=}")
    x += 100


if __name__ == "__main__":
    main()

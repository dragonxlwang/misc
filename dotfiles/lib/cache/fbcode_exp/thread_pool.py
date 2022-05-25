import random
import time
from concurrent.futures import ThreadPoolExecutor

import click
import six


class A:
    def __init__(self):
        self.data = list(range(100))

    def work(self, i):
        print(f"{i = }")
        self.data[i] = self.data[i] * 2

    def dispatch(self):
        executor = ThreadPoolExecutor()
        for i in range(100):
            executor.submit(self.work, i)
        # executor.shutdown()


def main():
    a = A()
    a.dispatch()
    print(a.data)


if __name__ == "__main__":
    main()

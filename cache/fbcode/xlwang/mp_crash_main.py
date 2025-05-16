# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

import multiprocessing

import click
from scripts.xlwang.mp_crash import main


def good_main():
    try:
        main()
    except Exception as e:
        print(f"re-raise Exception {e}")
        raise e
    finally:
        # Get all active children
        print("Going to terminate all child processes")
        children = multiprocessing.active_children()

        # Kill all active children
        for child in children:
            print(f"Going to terminate a child process. PID: {child.pid}")
            child.kill()
        print("All child processes are terminated.")


def bad_main():
    try:
        main()
    except Exception as e:
        print(f"re-raise Exception {e}")
        raise e


@click.command
@click.option(
    "--bad",
    is_flag=True,
    default=False,
)
def crash_main(bad: bool) -> None:
    if bad:
        bad_main()
    else:
        good_main()


if __name__ == "__main__":
    crash_main()

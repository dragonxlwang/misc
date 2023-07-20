#!/usr/bin/python3

import click


@click.command()
@click.argument("runs", required=True, nargs=-1, type=str)
def gen(runs: str) -> None:
    url = "https://www.internalfb.com/intern/tensorboard/?dir="
    """Simple program that greets NAME for a total of COUNT times."""
    parts = []
    for i, r in enumerate(runs):
        if "," in r:
            a, r = r.split(",")
        else:
            a = i
        parts += [f"{a}:{r}"]
    url = url + ",".join(parts)
    print(url)


if __name__ == "__main__":
    gen()

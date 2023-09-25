#!/usr/bin/python3

import click


@click.group()
def main() -> None:
    pass


@main.command()
@click.argument("runs", required=True, nargs=-1, type=str)
def gen(runs: str) -> None:
    url = "https://www.internalfb.com/intern/tensorboard/?dir="
    parts = []
    for i, r in enumerate(runs):
        if "," in r:
            a, r = r.split(",")
        else:
            a = i
        parts += [f"{a}:{r}"]
    url = url + ",".join(parts)
    print(url)

@main.command()
@click.argument("runs", required=True, nargs=-1, type=str)
def gen_dr(runs: str) -> None:
    url = "https://www.internalfb.com/intern/tensorboard/?dir="
    parts = []
    for i, r in enumerate(runs):
        if "," in r:
            a, r = r.split(",")
        else:
            a = i
        parts += [f"{a}:manifold://deep_retrieval/tree/jobs/{r}/tensorboard"]
    url = url + ",".join(parts)
    print(url)

if __name__ == "__main__":
    main()

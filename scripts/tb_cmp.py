#!/usr/bin/python3

import datetime

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
        r = r.replace("https://www.internalfb.com/mast/job/", "")

        if "," in r:
            a, r = r.split(",")
        else:
            a = f"{i}/{r}"

        if not r.startswith("manifold://"):
            r = f"manifold://deep_retrieval/tree/jobs/{r}/tensorboard"
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
            a = f"{i}/{r}"
        parts += [f"{a}:manifold://deep_retrieval/tree/jobs/{r}/tensorboard"]
    url = url + ",".join(parts)
    print(url)


@main.command()
@click.option("-s", type=int)
@click.argument("fp", required=True, nargs=1, type=str)
def sort_dedup(s: int, fp: str) -> None:
    with open(fp, "r") as f:
        lines = f.readlines()

    seen = set()

    def is_duplicate(key: str) -> bool:
        if key in seen:
            return True
        seen.add(key)
        return False

    lines = {
        int(
            datetime.datetime.strptime(
                ln.split("\t")[0], "%Y-%m-%d+%H:%M:%S"
            ).timestamp()
        ): ln
        for ln in lines
        if ln and not is_duplicate(ln.split("\t")[s])
    }
    lines = [lines[dt] for dt in reversed(sorted(lines))]

    with open(fp, "w") as f:
        f.writelines(lines)


if __name__ == "__main__":
    main()

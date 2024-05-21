from typing import Optional

import click
import torch
import torch.distributed as dist
from mrs.fm.utils import logger


@click.command()
@click.option("--variable", default=None, type=int)
def main(variable: Optional[int]):
    logger.info(f"[cyan] {variable=}")
    dist.init_process_group(backend="nccl")
    pg = dist.new_group(backend="gloo")

    d = [[1, 2, 3]] if dist.get_rank() == 0 else [None]
    dist.broadcast_object_list(d, src=0, group=pg)

    logger.info(f"[red]{d=}")
    logger.info("[red]====")


if __name__ == "__main__":
    main()

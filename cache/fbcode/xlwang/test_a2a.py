import os
import threading

import torch
import torch.distributed as dist

from minimal_viable_ai.core.utils.utils import init_all

from mrs.fm.utils import logger

if __name__ == "__main__":
    device, pg = init_all()
    rank = pg.rank()

    logger.info(
        f"[red] Rank: {rank} Process: {os.getpid()} Thread: {threading.currentThread().ident}, {device=}, {pg=}"
    )

    if rank == 0:
        input = torch.arange(8).to(dtype=torch.int32, device=device)
        output = torch.empty(2, 3).to(dtype=torch.int32, device=device)
        input_split = torch.tensor([6, 2]).to(dtype=torch.int64, device=device)
        output_split = torch.tensor([6, 0]).to(dtype=torch.int64, device=device)
    else:
        input = torch.tensor([]).to(dtype=torch.int32, device=device)
        output = torch.empty(1, 2).to(dtype=torch.int32, device=device)
        input_split = torch.tensor([0, 0], dtype=torch.int64)
        output_split = torch.tensor([2, 0], dtype=torch.int64)

    logger.info(
        f"[cyan] {input=}, \n "
        f"{output=}, \n"
        f"{input_split=}, \n"
        f"{output_split=}, \n"
    )

    dist.all_to_all_single(
        output=output.reshape(-1),
        input=input,
        input_split_sizes=input_split.tolist(),
        output_split_sizes=output_split.tolist(),
        group=pg,
        async_op=False,
    )

    logger.info(
        f"[red] {input=}, \n "
        f"{output=}, \n"
        f"{input_split=}, \n"
        f"{output_split=}, \n"
    )

    dist.barrier(group=pg)
    logger.info("=================")

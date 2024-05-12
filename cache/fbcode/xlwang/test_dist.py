import torch
import torch.distributed as dist
from mrs.fm.utils import logger

dist.init_process_group(backend="nccl")
pg = dist.new_group(backend="gloo")

d = [[1, 2, 3]] if dist.get_rank() == 0 else [None]
dist.broadcast_object_list(d, src=0, group=pg)

logger.info(f"[red]{d=}")
logger.info("[red]====")

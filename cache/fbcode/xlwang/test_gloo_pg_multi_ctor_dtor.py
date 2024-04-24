# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

import gc
import os
import socket
import sys
import time
from contextlib import closing, contextmanager
from datetime import datetime

import torch
import torch.distributed as dist
from torch.testing._internal.common_distributed import MultiProcessTestCase
from torch.testing._internal.common_utils import find_free_port
from torchrec.test_utils import skip_if_asan


def is_port_in_use(addr: str, port: str) -> bool:
    try:
        with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
            return s.connect_ex((addr, int(port))) == 0
    except Exception as e:
        print(f"is_port_in_use exc: {e=}, {addr=}, {port=}")
        return False


class GlooPgMultiCtorDtorTest(MultiProcessTestCase):
    def __init__(self, methodName: str = "runTest") -> None:
        super().__init__(method_name=methodName)

    @property
    def world_size(self) -> int:
        return 2

    def setUp(self) -> None:
        super().setUp()
        os.environ["NCCL_ENABLE_TIMING"] = "1"
        os.environ["MASTER_ADDR"] = "localhost"
        os.environ["MASTER_PORT"] = str(find_free_port())
        os.environ["MASTER_PORT_BACKUP"] = str(find_free_port())
        self._spawn_processes()

    def tearDown(self) -> None:
        super().tearDown()
        del os.environ["NCCL_ENABLE_TIMING"]
        del os.environ["MASTER_ADDR"]
        del os.environ["MASTER_PORT"]
        try:
            os.remove(self.file_name)
        except OSError:
            pass

    def test_with_proc_lifetime_pg(self) -> None:
        # this won't timeout and is safe
        assert not dist.is_initialized()
        dist.init_process_group(
            backend="gloo",
            rank=self.rank,
            world_size=self.world_size,
        )
        backend = "gloo"
        for i in range(2):
            print(f"{self.rank=} start {i}, {os.getenv('MASTER_PORT')=}")
            print(
                f"{self.rank=} before init {backend=} pg, {os.environ['MASTER_PORT']=}"
            )
            sys.stdout.flush()
            pg = dist.new_group(backend=backend)
            print(f"{self.rank=} after init {backend=} pg")
            dist.destroy_process_group(pg)

            assert not is_port_in_use(
                os.environ["MASTER_ADDR"],
                os.environ["MASTER_PORT"],
            )
            print(f"{self.rank=} pg destroyed")

    def test_default_pg_twice_init(self) -> None:
        # this will timeout with high chance
        backend = "gloo"
        for i in range(2):
            print(f"{self.rank=} start {i}")
            print(
                f"{self.rank=} before init {backend=} pg, {os.environ['MASTER_PORT']=}"
            )
            sys.stdout.flush()
            assert not dist.is_initialized()
            dist.init_process_group(
                backend=backend,
                rank=self.rank,
                world_size=self.world_size,
            )
            pg = dist.distributed_c10d._get_default_group()
            print(f"{self.rank=} after init {backend=} {pg=}")
            dist.destroy_process_group(pg)

            assert not is_port_in_use(
                os.environ["MASTER_ADDR"],
                os.environ["MASTER_PORT"],
            )
            print(f"{self.rank=} pg destroyed")

    def test_with_unique_port(self) -> None:
        # this also works, it's best to rely on sync mechanism to find free port
        backend = "gloo"
        for i in range(2):
            if i != 0:
                os.environ["MASTER_PORT"] = os.environ["MASTER_PORT_BACKUP"]

            print(f"{self.rank=} start {i}")
            print(
                f"{self.rank=} before init {backend=} pg, {os.environ['MASTER_PORT']=}"
            )
            sys.stdout.flush()
            assert not dist.is_initialized()
            dist.init_process_group(
                backend=backend,
                rank=self.rank,
                world_size=self.world_size,
            )
            pg = dist.distributed_c10d._get_default_group()
            print(f"{self.rank=} after init {backend=} {pg=}")
            dist.destroy_process_group(pg)

            print(f"{self.rank=} pg destroyed")

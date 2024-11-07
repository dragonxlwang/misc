import torch
from scripts.xlwang.test_fx_lib import func


def myfunc(x: torch.Tensor) -> torch.Tensor:
    return func(x)


class MyModule(torch.nn.Module):
    def __init__(self) -> None:
        super().__init__()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return func(x)

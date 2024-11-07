import torch


@torch.fx.wrap
def _switch_to_contiguous_if_needed(x: torch.Tensor) -> torch.Tensor:
    if x.stride(-1) == 1:
        return x
    return x.contiguous()


def func(x: torch.Tensor) -> torch.Tensor:
    return _switch_to_contiguous_if_needed(x)

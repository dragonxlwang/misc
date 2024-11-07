import torch
from mrs.fm.utils import logger
from scripts.xlwang.test_fx_lib2 import MyModule


if __name__ == "__main__":
    m = MyModule()
    x = torch.rand(5)
    y = m(x)
    logger.info(f"[red]==> {y}")
    gm = torch.fx.Tracer().trace(m)
    logger.info(f"[red]==> {gm}")

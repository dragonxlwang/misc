import io
import logging
from typing import NamedTuple

import torch
from data_preproc.types.types import HiveSplitShuffleOrder
from minimal_viable_ai.core.dataloader.dataloader import (
    create_dataloader,
    OnboxDPPDataLoaderConfig,
)
from minimal_viable_ai.core.utils.utils import init_all
from pytorch.data.fb.arrow_datapipe_factory import (
    arrow_datapipe_from_hive,
    arrow_datapipe_from_scribe,
)
from pytorch.data.fb.hive_dataset import HiveShuffleSpec
from scripts.xlwang.koski_output_to_tensor_batch import koski_output_to_tensor_batch

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(asctime)s:%(message)s")
logger: logging.Logger = logging.getLogger(__name__)


def get_datapipe():
    arrow_datapipe = (
        arrow_datapipe_from_hive(
            namespace="feed_fblearner",
            table="fbr_unique_video_id_with_video_transform_decord",
            partitions=["ds=2023-12-08/ts=2023-12-08+19:00:99"],
            schema=[
                "object_id",
                "everstore_handle",
                "clips",
            ],
        )
        .batch(5)
        .shuffle(HiveShuffleSpec(HiveSplitShuffleOrder.NONE))
        .collate()
        .map(koski_output_to_tensor_batch)
    )

    return arrow_datapipe


def main():
    device, pg = init_all()

    datapipe = get_datapipe()
    data_loader = create_dataloader(
        OnboxDPPDataLoaderConfig(),
        datapipe,
    )

    data_iter = iter(data_loader)

    while True:
        data_batch = next(data_iter)
        logging.info(f"{data_batch=}")

        break


if __name__ == "__main__":
    main()

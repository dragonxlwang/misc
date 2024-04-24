import base64
import io

import torch
from caffe2.torch.fb.koski.attr_dict import AttrDict


def uint8_tensor_from_b64(b64_bytes: bytes) -> torch.Tensor:
    buf = io.BytesIO(base64.b64decode(b64_bytes))
    t = torch.load(buf)
    return t


def koski_output_to_tensor_batch(input: AttrDict):
    object_id = input.object_id[0]
    clips = [uint8_tensor_from_b64(c) for c in input.clips]
    return object_id, clips

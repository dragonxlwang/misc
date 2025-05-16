# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.


import inspect
from typing import List, Optional, Tuple

import click
import mrs.fm.video.transforms as vt
import torch
import torchmultimodal.fb.utils.decord_utils as vu
from libfb.py.asyncio.await_utils import await_sync
from mrs.fm.logging import logger
from mrs.fm.utils import rgb_to_grayscale
from mrs.fm.video import utils
from phabricator.new_phabricator_graphql_helpers import PhabricatorPaste
from phabricator.phabricator_auth_strategy_factory import PhabricatorAuthStrategyFactory
from rfe.py.lib.sql import query_sql
from scripts.xlwang.koski_output_to_tensor_batch import uint8_tensor_from_b64


@click.group()
def main() -> None:
    pass


@main.command()
@click.option("--handle", type=str, default="")
@click.option("--frame-dilation-sec", type=float, default=0.125)
@click.option("--clips", type=str, default="")
def process(
    handle: str,
    frame_dilation_sec: float,
    clips: str,
) -> None:
    """
    Example:

    video_sampler --handle GICWmAAKsjdrAm4DAH6p2xy2sOVWbq_EAAAF
    video_sampler --handle remux://KLUv/SCoDQUAIgomJBBtzAOgFnplP5XWt/9ob90+xz2/ASagFthwcgOA8okTADBHAs4hiYP2EZCrVjNsYf2O1a2bSSXnmQ1sKCSg0YDAE8EpaQRBToEDZ3zYX9tZc816XLeNHe63NzvRjUopS3RI4hCklFJHXMxXC4ZZMBhRQVJ/TbJyeIBgaLimX0h4fj/j65t31pD4m2WMLfuegaP+gbJEAEUBAM4yhCg=
    video_sampler --handle everstore://GICWmAAKsjdrAm4DAH6p2xy2sOVWbq_EAAAF
    """
    mf_dir = utils.create_mf_dir()

    if handle:
        video_byte_tensor = utils.download_video(handle)
        clip_sampler = vu.VideoClipSamplerDecord(
            clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="PERIODIC"),
            frames_per_clip=4,
            clips_per_video=-1,
            frame_dilation_sec=frame_dilation_sec,
            clips_start_second=1,
            clips_end_second=-1,
            clips_per_second=0.1,
            video_min_dimension=-1,
            video_max_dimension=-1,
        )
        av_clips = clip_sampler(video_byte_tensor)
        # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but got
        #  `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
        #  VideoMetaData]]`.
        v_clips = vt.extract_video(av_clips)
        h, w = v_clips.shape[2:4]
        utils.upload_clip_to_manifold(
            v_clips, file_name=f"original_{h}x{w}", mf_dir=mf_dir
        )

        clip_sampler = vu.VideoClipSamplerDecord(
            clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="PERIODIC"),
            frames_per_clip=4,
            clips_per_video=-1,
            frame_dilation_sec=frame_dilation_sec,
            clips_start_second=1,
            clips_end_second=-1,
            clips_per_second=0.1,
            video_min_dimension=64,
            video_max_dimension=64,
        )
        av_clips = clip_sampler(video_byte_tensor)
        # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but got
        #  `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
        #  VideoMetaData]]`.
        v_clips = vt.extract_video(av_clips)
        utils.upload_clip_to_manifold(v_clips, file_name="64x64", mf_dir=mf_dir)

        clip_sampler = vu.VideoClipSamplerDecord(
            clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="PERIODIC"),
            frames_per_clip=4,
            clips_per_video=-1,
            frame_dilation_sec=frame_dilation_sec,
            clips_start_second=1,
            clips_end_second=-1,
            clips_per_second=0.1,
            video_min_dimension=32,
            video_max_dimension=32,
        )
        av_clips = clip_sampler(video_byte_tensor)
        # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but got
        #  `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
        #  VideoMetaData]]`.
        v_clips = vt.extract_video(av_clips)
        utils.upload_clip_to_manifold(v_clips, file_name="32x32", mf_dir=mf_dir)

        clip_sampler = vu.VideoClipSamplerDecord(
            clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="PERIODIC"),
            frames_per_clip=4,
            clips_per_video=-1,
            frame_dilation_sec=frame_dilation_sec,
            clips_start_second=1,
            clips_end_second=-1,
            clips_per_second=0.1,
            video_min_dimension=-1,
            video_max_dimension=-1,
        )
        av_clips = clip_sampler(video_byte_tensor)
        # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but got
        #  `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
        #  VideoMetaData]]`.
        v_clips = vt.extract_video(av_clips)

        for scale in [0.5, 0.25, (0.5, 0.125, 0.125), (0.25, 0.0625, 0.0625)]:
            # pyre-fixme[6]: For 2nd argument expected `Union[Tuple[float], float]`
            #  but got `Union[Tuple[float, float, float], float]`.
            interpolate_v_clips = vt.downsample_interpolate_video(v_clips, scale=scale)
            h, w = interpolate_v_clips.shape[2:4]
            utils.upload_clip_to_manifold(
                interpolate_v_clips,
                file_name=f"interpolate_scale_{scale}_{h}x{w}",
                mf_dir=mf_dir,
            )

        cropped_v_clips = vt.center_crop_video(v_clips, 0.5)
        h, w = cropped_v_clips.shape[2:4]
        utils.upload_clip_to_manifold(
            cropped_v_clips,
            file_name=f"cropped_0.5_{h}x{w}",
            mf_dir=mf_dir,
        )

        transformed_v_clips = vt.downsample_interpolate_video(
            v_clips,
            # pyre-fixme[6]: For 2nd argument expected `Union[Tuple[float], float]`
            #  but got `Tuple[float, float, float]`.
            scale=(0.25, 0.0625, 0.0625),
        )
        transformed_v_clips = vt.center_crop_video(transformed_v_clips, 0.5)
        h, w = transformed_v_clips.shape[2:4]
        utils.upload_clip_to_manifold(
            transformed_v_clips,
            file_name=f"interpolate_scale_(0.25, 0.0625, 0.0625)_cropped_0.5_{h}x{w}",
            mf_dir=mf_dir,
        )
    elif clips:
        # pyre-fixme[9]: clips has type `str`; used as `Tensor`.
        # pyre-fixme[6]: For 1st argument expected `bytes` but got `str`.
        clips = uint8_tensor_from_b64(clips)
        utils.upload_clip_to_manifold(
            # pyre-fixme[6]: For 1st argument expected `Tensor` but got `str`.
            clips,
            # pyre-fixme[16]: `str` has no attribute `shape`.
            file_name="_".join(["clips"] + [str(x) for x in clips.shape]),
            mf_dir=mf_dir,
        )


def sample_top_resolution(num: int) -> List[Tuple[str, int, int, float]]:
    """
    Returns
        handle
        h, resolution
        w, resolution
        prevelance
    """
    res_samples = await_sync(
        query_sql(
            table="mrs_fm_video_sampler",
            sql=inspect.cleandoc(
                f"""
    SELECT
        h,
        w,
        MIN((h + 0.0) / w) AS ratio,
        MIN(handle) AS sample_handle,
        COUNT(*) AS cnt
    FROM mrs_fm_video_sampler
    WHERE
        h IS NOT NULL
        AND new_h IS NOT NULL
        AND error != 1
    GROUP BY
        h,
        w
    ORDER BY
        cnt DESC
    LIMIT {num}
    """
            ),
            user_id=346028543863956,
            source="minimal_viable_ai",
        )
    )
    res_count = await_sync(
        query_sql(
            table="mrs_fm_video_sampler",
            sql=inspect.cleandoc(
                """
    SELECT
        COUNT(*) AS cnt
    FROM mrs_fm_video_sampler
    WHERE
        h IS NOT NULL
    """
            ),
            user_id=346028543863956,
            source="minimal_viable_ai",
        )
    )

    count = float(res_count.value[0][0])
    samples = []

    for row in res_samples.value:
        samples.append([str(row[3]), int(row[0]), int(row[1]), float(row[4]) / count])

    return samples


@main.command()
@click.option("--handle", type=str, default="")
def process_16x9(
    handle: str,
) -> None:
    # https://fburl.com/daiquery/ro32j6mb
    # https://fburl.com/daiquery/mxvf0i06

    mf_dir = utils.create_mf_dir()

    video_byte_tensor = utils.download_video(handle)
    clip_sampler = vu.VideoClipSamplerDecord(
        clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="UNIFORM"),
        frames_per_clip=1,
        clips_per_video=3,
        frame_dilation_sec=1,  # dummy
        clips_start_second=0,
        clips_end_second=-1,
        video_min_dimension=-1,
        video_max_dimension=-1,
    )
    av_clips = clip_sampler(video_byte_tensor)
    # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but got
    #  `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
    #  VideoMetaData]]`.
    v_clips = vt.extract_video(av_clips)
    utils.upload_clip_to_manifold(v_clips, file_name="original", mf_dir=mf_dir)
    logger.info(f"[RED] {v_clips.shape=}")

    v_clips = vt.resize_to_16x9(v_clips)
    utils.upload_clip_to_manifold(v_clips, file_name="resized", mf_dir=mf_dir)
    logger.info(f"[RED] {v_clips.shape=}")


@main.command()
@click.option("--num", type=int, default=20)
def process_16x9_sampled(
    num: int,
) -> None:
    mf_dir = utils.create_mf_dir()

    samples = sample_top_resolution(num)
    tensors = []
    for sample in samples:
        try:
            handle, h, w, p = sample
            logger.info(f"[GREEN]processing {handle=}, {h}x{w}, {p=}")

            video_byte_tensor = utils.download_video(handle)
            clip_sampler = vu.VideoClipSamplerDecord(
                clip_sampler_type=vu.ClipSamplerType(clip_sampler_type="UNIFORM"),
                frames_per_clip=1,
                clips_per_video=3,
                frame_dilation_sec=1,  # dummy
                clips_start_second=0,
                clips_end_second=-1,
                video_min_dimension=-1,
                video_max_dimension=-1,
            )
            av_clips = clip_sampler(video_byte_tensor)

            # pyre-fixme[6]: For 1st argument expected `List[Dict[str, Tensor]]` but
            #  got `Union[None, List[Dict[str, Tensor]], Tuple[List[Dict[str, Tensor]],
            #  VideoMetaData]]`.
            v_clips = vt.extract_video(av_clips)
            utils.upload_clip_to_manifold(
                v_clips,
                file_name=f"{h}x{w}_original",
                mf_dir=mf_dir,
                title=f"original: {h}x{w},{p=:.4},{v_clips.shape}",
            )

            v_clips = vt.resize_to_16x9(v_clips)
            utils.upload_clip_to_manifold(
                v_clips,
                file_name=f"{h}x{w}_resized",
                mf_dir=mf_dir,
                title=f"resized: {h}x{w},{p=:.4},{v_clips.shape}",
            )
            tensors.append(v_clips)

            v_clips = rgb_to_grayscale(v_clips)
            utils.upload_clip_to_manifold(
                v_clips,
                file_name=f"{h}x{w}_grayscaled",
                mf_dir=mf_dir,
                title=f"grayscaled: {h}x{w},{p=:.4},{v_clips.shape}",
                grayscale=True,
            )
            tensors.append(v_clips)
        except Exception as e:
            logger.info(f"[RED]{e=}")
            raise e

    std_mean = torch.std_mean(torch.stack(tensors).view(-1, 3).float(), dim=0)
    logger.info(f"[GREEN]{std_mean=}")


def get_paste(paste_id: str) -> Optional[str]:
    try:
        paste_client = PhabricatorPaste(
            PhabricatorAuthStrategyFactory.paste_bot(),
            "mvai",
        )
        return paste_client.get_by_number(paste_id[1:])["raw_content"]
    except Exception:
        logger.exception("Failed to get paste info using the paste_id.")
        return None


@main.command()
@click.option("--paste", type=str, default="")
def renders(
    paste: str,
) -> None:
    mf_dir = utils.create_mf_dir()
    # pyre-fixme[16]: `Optional` has no attribute `split`.
    handle, clips = get_paste(paste).split()[-2:]
    handle = handle[1:-1] if handle[0] == "'" else handle
    clips = clips[1:-1] if clips[0] == "'" else clips
    logger.info(f"[GREEN]{handle=}")

    clips = uint8_tensor_from_b64(clips)
    utils.upload_clip_to_manifold(
        clips,
        file_name="_".join(["clips"] + [str(x) for x in clips.shape]),
        mf_dir=mf_dir,
    )


if __name__ == "__main__":
    main()

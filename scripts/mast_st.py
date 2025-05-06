#!/usr/bin/python3

import json
import time
import urllib
from pprint import pprint
from typing import List, Optional

import click
import sh

_color_codes: dict[str, str] = {
    "black": "\033[0;30m",
    "red": "\033[0;31m",
    "green": "\033[0;32m",
    "yellow": "\033[0;33m",
    "blue": "\033[0;34m",
    "magenta": "\033[0;35m",
    "cyan": "\033[0;36m",
    "white": "\033[0;37m",
    "none": "\033[m",
    "black_bold": "\033[1;30m",
    "red_bold": "\033[1;31m",
    "green_bold": "\033[1;32m",
    "yellow_bold": "\033[1;33m",
    "blue_bold": "\033[1;34m",
    "magenta_bold": "\033[1;35m",
    "cyan_bold": "\033[1;36m",
    "white_bold": "\033[1;37m",
}


def color_print(c: str, s: str, bold=True) -> None:
    if bold:
        c = f"{c}_bold"
    print(f"{_color_codes[c]}{s}{_color_codes['none']}")


def get_ods_url(
    entities: List[str],
    keys: str,
    start_ts: int,
    end_ts: int,
    transformation: Optional[str] = None,
    reduction: Optional[str] = None,
):
    period = {
        "static_start": start_ts,
        "static_end": end_ts,
        "time_type": "static",
    }

    chart_params = {
        "type": "linechart",
        "renderer": "highcharts",
        "no_relative_scale": True,
        "chart_title": ",".join(keys),
        "reload_interval": "0",
        "h_marks": "",
        # "superimpose": 7 * 24 * 60,
    }

    queries = {
        "enabled": True,
        "active": True,
        "entity": ",".join(entities),
        "key": ",".join(keys),
        "source": "ods",
        "reduce_keys": False,
        "datatypes": ["raw"],
        "table": "auto",
    }

    if transformation is not None:
        queries["transform"] = transformation

    if reduction is not None:
        queries["reduce"] = reduction

    params = {
        "submitted": 1,
        "period": json.dumps(period),
        "chart_params": json.dumps(chart_params),
        "queries[0]": json.dumps(queries),
    }
    query = urllib.parse.urlencode(params)
    return "https://our.intern.facebook.com/intern/ods/chart/?" + query


@click.group()
def main() -> None:
    pass


@main.command()
@click.argument("run", required=True, nargs=1, type=str)
@click.option("-n", "--num", type=int, default=4)
def mem(run: str, num: int) -> None:
    job_status = json.loads(sh.mast("get-status", run, json=True))
    attempts = job_status["latestAttempt"]["taskGroupExecutionAttempts"]["trainer"]
    # pprint(attempts)
    for att in attempts:
        idx = att["attemptIndex"]
        start_ts, end_ts = [
            att["taskGroupStateTransitionTimestampSecs"]["RUNNING"],
            att["taskGroupStateTransitionTimestampSecs"].get(
                "STOPPING", int(time.time())
            ),
        ]
        final_status = ",".join(
            {
                k
                for k, v in att["taskGroupStateTransitionTimestampSecs"].items()
                if v > end_ts
            }
        )
        hosts = sorted(
            [
                (int(k.split("/")[-1]), t["hostname"])
                for k, v in att["taskExecutionAttempts"].items()
                for t in v
            ]
        )

        start_ts_str = sh.date("+%Y-%m-%d %H:%M:%S", d=f"@{start_ts}").strip()
        end_ts_str = sh.date("+%Y-%m-%d %H:%M:%S", d=f"@{end_ts}").strip()
        color_print("yellow", f"ATTEMPT     [{idx}]")
        color_print("yellow", f"START_TS:   {start_ts_str}")
        color_print("yellow", f"END_TS:     {end_ts_str}    {final_status}")

        color_print("yellow", f"HOSTS:")
        for r, h in hosts:
            url = ""
            if r < num:
                url = get_ods_url(
                    entities=[h],
                    keys=[
                        "system.mem_free_nobuffer_nocache",
                        "system.mem_free",
                        "system.swap_used",
                    ],
                    start_ts=start_ts,
                    end_ts=end_ts,
                )
                url = sh.fburl(url).strip()
            color_print("yellow", f"            rank {r}\t{h}\t{url}")

        url = get_ods_url(
            entities=[h for r, h in hosts if r < num],
            keys=[
                "system.mem_free_nobuffer_nocache",
                "system.mem_free",
                "system.swap_used",
            ],
            start_ts=start_ts,
            end_ts=end_ts,
        )
        url = sh.fburl(url).strip()
        color_print("cyan", f"ODS:        {url}")

    color_print("green", ">>>>>>")


if __name__ == "__main__":
    main()

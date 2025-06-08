#!/usr/bin/python3

import json
import re
import subprocess
import sys
import time
import urllib
from pprint import pprint
from typing import Any, Dict, List, Optional, Tuple

import click
import sh

_color_codes: Dict[str, str] = {
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
    title: Optional[str] = None,
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
        "chart_title": ",".join(keys) if title is None else title,
        "reload_interval": "0",
        "h_marks": "",
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


def get_start_end_ts(job_status: Dict[str, Any]) -> Tuple[int, int]:
    attempts = job_status["latestAttempt"]["taskGroupExecutionAttempts"]["trainer"]
    att = attempts[0]
    start_ts, end_ts = [
        att["taskGroupStateTransitionTimestampSecs"]["RUNNING"],
        att["taskGroupStateTransitionTimestampSecs"].get("STOPPING", int(time.time())),
    ]
    return start_ts, end_ts


@main.command()
@click.argument("run", required=True, nargs=1, type=str)
@click.option("-n", "--num", type=int, default=4)
@click.option("--per-host-details", type=bool, default=False)
@click.option("--mem-free", type=bool, default=False)
def mem(run: str, num: int, per_host_details: bool, mem_free: bool) -> None:
    hosts, start_ts, end_ts = get_job_info(run)

    ods_keys = (
        [
            "system.mem_free_nobuffer_nocache",
            "system.mem_free",
            "system.swap_used",
        ]
        if mem_free
        else [
            "system.mem_used",
        ]
    )

    color_print("green", f"https://www.internalfb.com/mast/job/{run}")

    url = get_ods_url(
        entities=hosts,
        keys=ods_keys,
        start_ts=start_ts,
        end_ts=end_ts,
        title=f"cpu mem: {run}",
    )
    url = sh.fburl(url).strip()

    color_print("cyan", f"ODS:        {url}")
    color_print("green", ">>>>>>")


def get_job_info(run: str) -> Tuple[List[str], int, int]:
    attempt_index = -1
    if ":" in run:
        parts = run.split(":")
        run = parts[0]
        attempt_index = int(parts[1])
    res = json.loads(
        sh.mast("get-job-history", run, attempt_index=attempt_index, json=True)
    )
    res = res["jobExecutionAttempt"]["taskGroupExecutionAttempts"]["trainer"][0][
        "taskExecutionAttempts"
    ]

    hosts = []
    start_ts = sys.maxsize
    end_ts = -1
    for task in res.values():
        hosts.append(task[0]["hostname"])
        start_ts = min(start_ts, task[0]["startTimestamp"])
        end_ts = max(end_ts, task[0]["endTimestamp"])

    return hosts, start_ts, end_ts


@main.command()
@click.argument("run", required=True, nargs=1, type=str)
def job_resolver_paste(run: str) -> None:
    job_status = json.loads(sh.mast("get-status", run, json=True))
    attempts = job_status["latestAttempt"]["taskGroupExecutionAttempts"]["trainer"]
    tw_tasks = sorted(attempts[0]["taskExecutionAttempts"].keys())

    tw0 = tw_tasks[0]
    start_ts, end_ts = get_start_end_ts(job_status)
    cmd = (
        f"tw log {tw0} --start-time {start_ts} --end-time {end_ts} | "
        'grep -m 1 "Configs after resolve:"'
    )

    color_print("green", f"https://www.internalfb.com/mast/job/{run}")
    color_print("yellow", f"TW:         {tw0}")
    color_print("yellow", f"START_TS:   {start_ts}")
    color_print("yellow", f"END_TS:     {end_ts}")
    color_print("yellow", f"CMD:        {cmd}")

    pastry = subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL)
    pastry = re.search(r"P\d{9,}", pastry.decode("utf-8"))[0]

    color_print("green", "resolved pastry: (first appearance)")
    print(pastry)


@main.command()
@click.argument("run", required=True, nargs=1, type=str)
def job_meta(run: str) -> None:
    job_def = json.loads(sh.mast("get-job-definition", run, json=True))
    for k, v in job_def["applicationMetadata"].items():
        print(f"{k:<40}: {v}")


@main.command()
@click.argument("run1", required=True, nargs=1, type=str)
@click.argument("run2", required=True, nargs=1, type=str)
def job_diff(run1: str, run2: str) -> None:
    def _get_resolver_paste(run: str) -> str:
        job_status = json.loads(sh.mast("get-status", run, json=True))
        attempts = job_status["latestAttempt"]["taskGroupExecutionAttempts"]["trainer"]
        tw_tasks = sorted(attempts[0]["taskExecutionAttempts"].keys())

        tw0 = tw_tasks[0]
        start_ts, end_ts = get_start_end_ts(job_status)
        cmd = (
            f"tw log {tw0} --start-time {start_ts} --end-time {end_ts} | "
            'grep -m 1 "Configs after resolve:"'
        )

        pastry = subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL)
        pastry = re.search(r"P\d{9,}", pastry.decode("utf-8"))[0]

        return pastry

    def _get_local_diff(run: str) -> str:
        job_def = json.loads(sh.mast("get-job-definition", run, json=True))
        return job_def["applicationMetadata"]["local_diff"]

    def _diff_pastry(pastry1: str, pastry2: str) -> None:
        subprocess.check_call("mkdir -p /tmp", shell=True)
        subprocess.check_call(f"pastry {pastry1} > /tmp/{pastry1}", shell=True)
        subprocess.check_call(f"pastry {pastry2} > /tmp/{pastry2}", shell=True)
        cmd = f"diff /tmp/{pastry1} /tmp/{pastry2}"

        color_print("green", cmd)

        subprocess.check_call(
            f"diff -wbBdu --color=always /tmp/{pastry1} /tmp/{pastry2} | less -R",
            shell=True,
        )

    color_print("green", ">>>>>>>   diff job resolver")
    pastry1 = _get_resolver_paste(run1)
    pastry2 = _get_resolver_paste(run2)
    _diff_pastry(pastry1, pastry2)
    color_print("yellow", "<<<<<<<   diff job resolver")

    color_print("green", ">>>>>>>   diff local diff")
    pastry1 = _get_local_diff(run1)
    pastry2 = _get_local_diff(run2)
    _diff_pastry(pastry1, pastry2)
    color_print("yellow", "<<<<<<<   diff local diff")


@main.command()
@click.argument("runs", required=True, nargs=-1, type=str)
def tb(runs: List[str]) -> None:
    url = "https://www.internalfb.com/intern/tensorboard/?dir="
    parts = []
    for i, r in enumerate(runs):
        r = r.replace("https://www.internalfb.com/mast/job/", "")

        if "," in r:
            a, r = r.split(",")
        else:
            a = f"{i}/{r}"

        if not r.startswith("manifold://"):
            r = f"manifold://deep_retrieval/tree/jobs/{r}/tensorboard"
        parts += [f"{a}:{r}"]

    url = url + ",".join(parts)
    url = sh.fburl(url).strip()
    print(url)


@main.command()
@click.argument("run", required=True, nargs=1, type=str)
@click.argument("key", required=True, nargs=1, type=str)
def log_grep(run: str, key: str) -> None:
    job_status = json.loads(sh.mast("get-status", run, json=True))
    attempts = job_status["latestAttempt"]["taskGroupExecutionAttempts"]["trainer"]
    tw_tasks = sorted(attempts[0]["taskExecutionAttempts"].keys())

    tw0 = tw_tasks[0]
    start_ts, end_ts = get_start_end_ts(job_status)
    cmd = (
        f'tw log {tw0} --start-time {start_ts} --end-time {end_ts} | grep -E -i "{key}"'
    )

    color_print("green", ">>>>>>>   start grep")
    subprocess.check_call(cmd, shell=True)
    color_print("green", ">>>>>>>   end grep")


if __name__ == "__main__":
    main()

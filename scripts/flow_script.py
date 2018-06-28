from __future__ import (absolute_import, division, print_function,
                        unicode_literals)

import collections
import datetime
import getpass
import json
import logging
import os
import pprint as py_pprint
import re
import shutil
import subprocess
import time
import uuid
from collections import Iterable, OrderedDict, namedtuple
from copy import deepcopy
from itertools import islice

import caffe2.caffe2.fb.predictor.predictor_py_utils as pred_utils
import caffe2.caffe2.fb.predictor.sigrid.constants as sc
import caffe2.python.fb.dper.layer_models.utils.utils as utils
import caffe2.python.fb.dper.utils as dper_utils
# add this to enable get default input
import fblearner.flow.facebook.plugins.all_plugins  # noqa
import fblearner.flow.projects.dper.flow_types as T
import matplotlib.pyplot as plt
import numpy as np
from caffe2.caffe2.fb.predictor import predictor_exporter as pe
from caffe2.caffe2.fb.predictor.model_exporter import ModelExporter
from caffe2.fb.python.fb_predictor_constants import \
    fb_predictor_constants as fpc
from caffe2.proto import caffe2_pb2
from caffe2.python import core, dyndep, memonger, net_drawer, workspace
from caffe2.python.fb.dper.layer_models.model_definition import ttypes
from caffe2.python.fb.dper.layer_models.utils import vis_utils
# from caffe2.caffe2.fb.predictor.Predic tor import constants as predictor_constants
from caffe2.python.fb.predictor import serde
from caffe2.python.predictor_constants import predictor_constants as pc
from fblearner.flow.core.attrdict import from_dict
from fblearner.flow.core.types_lib.gettype import gettype
from fblearner.flow.core.types_lib.type import encode as encode_flow_type
from fblearner.flow.external_api import FlowSession, WorkflowRun
from fblearner.flow.ml.runners.chronosscheduler import get_workflow_run_status
from fblearner.flow.plugin_definitions.driver import Drivers
from fblearner.flow.service.flow_client import get_flow_indexing_client
from fblearner.flow.storage.models import (ModelType, Session, SessionContext,
                                           Workflow, WorkflowRegistration,
                                           WorkflowRun, initialize_session)
from fblearner.flow.thrift.indexing.ttypes import WorkflowRunMetadataMutation
from fblearner.flow.util.runner_utilities import load_config
from future.utils import viewitems, viewkeys, viewvalues
from libfb.py import fburl
from libfb.py.decorators import memoize_timed, retryable
from metastore import metastore
from model_id.ttypes import ModelId
from six import string_types
from thrift.protocol import TSimpleJSONProtocol
from thrift.transport.TTransport import TMemoryBuffer

dyndep.InitOpsLibrary("@/caffe2/caffe2/fb/transforms:sigrid_transforms_ops")
dyndep.InitOpsLibrary("@/caffe2/caffe2/fb:hdfs_log_file_db")
core.GlobalInit(["python", "--caffe2_log_level=-3", "--vmodule=load_save_op=3"])

# -------------------------------- decorator ----------------------------------


def email():
    def decorator(func):
        def wrapper(*args, **kwargs):
            email_return = kwargs.pop("email_return", False)
            func_name = func.__name__
            ret = func(*args, **kwargs)
            if email_return:
                send_email(
                    subject="Return from {}".format(func_name),
                    to=my_email_addr(),
                    body=str(ret),
                    auto_sig=True,
                )
            return ret

        return wrapper

    return decorator


# --------------------------------- system ------------------------------------


def whoami():
    return getpass.getuser()


def my_email_addr():
    return "{}@fb.com".format(whoami())


def everpaste_publish(body):
    return get_fburl(vis_utils.get_everpaste_url(str(body)))


def timedelta_rep(td):
    return str(td).replace(" day, ", ":").replace(" days, ", ":")


def now_str():
    return str(datetime.datetime.now().replace(microsecond=0)).replace(" ", ".")


today = datetime.date.today


def short_today():
    return datetime.date.today().strftime("%m-%d")


# --------------------------------- logging -----------------------------------
logger = logging.getLogger(__name__)
formatter = logging.Formatter("%(levelname)s %(asctime)s : %(message)s")


def log_clean(logger):
    handlers = logger.handlers[:]
    for h in handlers:
        h.close()
        logger.removeHandler(h)


def log_add_fh(file_name):
    fh = logging.FileHandler(file_name)
    fh.setFormatter(formatter)
    logger.addHandler(fh)


def log_blank():
    logger.info("## ---------------------------------------")
    logger.info("## ---------------------------------------")
    logger.info("## ---------------------------------------")
    logger.info("## ---------------------------------------")
    logger.info("## ---------------------------------------\n\n\n")


def log_reset(file_names=None, max_ln_num=1e5):
    log_clean(logger)
    logger.setLevel(logging.INFO)
    if file_names is None:
        file_names = [
            r"/home/{0}/fbcode/experimental/{0}/ipy_flow_debug.log".format(whoami())
        ]
    elif isinstance(file_names, str):
        file_names = [file_names]
    for f in file_names:
        file_purge(f, max_ln_num)
        log_add_fh(f)
    for h in logging.root.handlers:
        h.setFormatter(formatter)
    logger.info("==========================================")
    logger.info("========== NEW IPYTHON, START LOG ========")
    logger.info("==========================================")


def pprint(obj, add_log=False, to_std=True, lvl="info", raw=False, multiline=False):
    if not isinstance(obj, string_types):
        obj = py_pprint.pformat(obj) if not raw else str(obj)
    if not multiline:
        lns = obj.split("\n")
    else:
        lns = [obj]
    for ln in lns:
        if add_log:
            getattr(logger, lvl)(ln)
        if to_std:
            print(ln)


def format_tabular(fields, fmt={}, title={}, col_sep="\n", row_sep=" "):
    def add_max_width_to_fmt(fmt, width):
        i = fmt.find(":")
        if fmt[i + 1] == "-" or fmt[i + 1] == "^":
            i = i + 1
        return fmt[: i + 1] + str(width) + fmt[i + 1 :]

    def max_col_width(fields, title="", fmt="{:}"):
        llen = fmt.find("{")
        rlen = fmt[::-1].find("}")
        width = max([len(fmt.format(f)) for f in fields] + [len(title)])
        return width - (llen + rlen), width

    def fmt_col(fields, fmt="{:}", title=None):
        width, title_width = max_col_width(fields, title or "", fmt)
        fmt = add_max_width_to_fmt(fmt, width)
        return (
            [add_max_width_to_fmt("{:^}", title_width).format(title)]
            if title is not None
            else []
        ) + [fmt.format(f) for f in fields]

    def fmt_tbl(fields, fmt={}):
        def transpose(fields):
            r = len(fields)
            c = len(fields[0])
            return [[fields[j][i] for j in range(r)] for i in range(c)]

        tf = transpose(fields)
        default_title = None if len(title) == 0 else ""
        columns = [
            fmt_col(col, fmt.get(j, "{:}"), title.get(j, default_title))
            for j, col in enumerate(tf)
        ]
        return transpose(columns)

    def rep_tbl(fields, c_sep="\n", r_sep=" "):
        return c_sep.join([r_sep.join(r) for r in fields])

    formatted_fields = fmt_tbl(fields, fmt)
    return rep_tbl(formatted_fields, col_sep, row_sep)


def pprint_tabular(fields, fmt={}, title={}, col_sep="\n", row_sep=" ", add_log=False):
    pprint(
        format_tabular(fields, fmt, title, col_sep, row_sep), add_log=add_log, raw=True
    )


# --------------------------------- utility ----------------------------------


def tt_to_json(obj):
    """thrift to json"""
    trans = TMemoryBuffer()
    proto = TSimpleJSONProtocol.TSimpleJSONProtocol(trans)
    obj.write(proto)
    return trans.getvalue()


def tt_to_dict(obj):
    """thrift to dictionary, as for flow input argument"""
    return json.loads(tt_to_json(obj))


def ft_to_dict(obj):
    """flow type to dictionary"""
    return encode_flow_type(None, obj)


@retryable(num_tries=3, sleep_time=1)
def get_fburl(raw_url):
    return fburl.get_fburl(raw_url)


@retryable(num_tries=3, sleep_time=1)
def resolve_fburl(url):
    return fburl.resolve_fburl(url)


def file_st_time(f, mode):
    try:
        st = os.stat(f)
        return getattr(st, "st_%stime" % mode, -1)
    except Exception:
        return -1


def file_delete(f):
    try:
        shutil.rmtree(f)
        logger.info("delete directory: %s" % f)
    except Exception:
        os.remove(f)
        logger.info("delete file: %s" % f)


def file_life_days(f):
    st_time = max(file_st_time(f, "c"), file_st_time(f, "m"))
    td = datetime.datetime.now() - datetime.datetime.fromtimestamp(st_time)
    one_day = datetime.timedelta(days=1)
    return td.total_seconds() / one_day.total_seconds()


def file_touch(f):
    """update file modify/access time"""
    with open(f, "a"):
        os.utime(f, None)


def file_purge(f, ln_num=1e5):
    if ln_num is None or ln_num < 0:
        return
    ln_num = max(int(ln_num), 1000)
    file_touch(f)
    with open(f, "r") as fh:
        lines = fh.readlines()
    lines = lines[-ln_num:]
    with open(f, "w") as fh:
        fh.writelines(lines)


def dir_purge(dir, max_file_num=1000, min_retention_days=30):
    days = {}
    for f in os.listdir(dir):
        fp = os.path.join(dir, f)
        days[fp] = file_life_days(fp)
    for i, f in enumerate(sorted(days, key=lambda k: days[k])):
        if i >= max_file_num and days[f] > min_retention_days:
            file_delete(f)


def center_with_padding(s, pad="=", length=80):
    if len(s) > 0:
        s = " " + s + " "
    pad_len = length - len(s)
    assert pad_len > 0
    assert len(pad) == 1
    lp_len = int(pad_len / 2)
    rp_len = pad_len - lp_len
    return "{}{}{}".format(pad * lp_len, s, pad * rp_len)


def gen_home_file(filename="", purge_home=True):
    # home
    dump_dir = "/home/{}/public_html/flows/".format(whoami())

    filename, ext = os.path.splitext(filename)
    filename = "%s%s%s" % (filename, uuid.uuid4(), ext)
    if purge_home:
        dir_purge(dump_dir)

    filepath = os.path.join(dump_dir, filename)
    url = get_fburl("https://home.fburl.com/~{}/flows/".format(whoami()) + filename)
    return filepath, url


def get_home_file_from_url(url):
    # home
    dump_dir = "/home/{}/public_html/flows/".format(whoami())
    prefix = "https://home.fburl.com/~{}/flows/".format(whoami())
    try:
        url = fburl.resolve_fburl(url)
    except Exception:
        pass
    assert url.startswith(prefix), url
    filepath = os.path.join(dump_dir, url.replace(prefix, ""))
    return filepath


def url_touch(url):
    filepath = get_home_file_from_url(url)
    file_touch(filepath)
    return


def map_inv(m):
    return {v: k for k, v in m.items()}


def human_readable_file_size_str(fp):
    fs = os.path.getsize(fp)
    for count in ["Bytes", "KB", "MB", "GB"]:
        if fs > -1024.0 and fs < 1024.0:
            return "%3.1f%s" % (fs, count)
        fs /= 1024.0
    return "%3.1f%s" % (fs, "TB")


APOLLO_XIII_TAG_ID = 325182364673414

# --------------------------------- Flow Lib ---------------------------------


def flow_run(
    args,
    title="test",
    owner=None,
    entitlement="ads_ftw",
    package="aml.dper2:73",
    workflow="dper.workflows.ads.train_eval_workflow",
    model_type_id=None,
):
    owner = owner if owner is not None else whoami()
    """schedule a flow run, and return the WorkflowRun instance"""
    fl = FlowSession()
    run = fl.schedule_workflow(
        owner=owner,
        workflow_name=workflow,
        input_arguments=args,
        entitlement=entitlement,
        package_version=package,
        metadata=WorkflowRunMetadataMutation(
            name=title,
            notes="",
            add_tags=[APOLLO_XIII_TAG_ID],
            model_type_id=model_type_id,
        ),
    )
    logger.info(
        'flow "%s" launched: id=f%s \n    %s'
        % (
            title,
            str(run.id),
            ("https://our.intern.facebook.com/intern/fblearner/details/%s" % run.id),
        )
    )
    return run


def flow_result(workflow_run_id, print_return=False):
    """return flow result, such as 'model_id', 'checkpoint_path',
    'model_tb_graph', 'adv_eval_metrics', 'training_metrics',
    'model_predictor_path', 'model_graph', 'model_path', 'eval_metrics',
    'eval_learning_curves', 'training_learning_curves'"""
    fl = FlowSession()
    result = fl.get_workflow_run_results_summary(
        workflow_run_id, update_gluster_access_time_for_output=False
    )
    if print_return:
        pprint(result)
    return result


def flow_input_args(workflow_run_id, print_return=False):
    """input arguments for flow"""
    fl = FlowSession()
    input_args = fl.get_workflow_run_inputs_summary(workflow_run_id=workflow_run_id)
    input_args = deepcopy(input_args)
    if print_return:
        pprint(input_args)
    return input_args


def flow_info(workflow_run_id):
    """return flow info, e.g., owner, packageVersion, childrenRunIDs,
    workflow_name, entitlement"""
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id)


def flow_parent_id(workflow_run_id):
    """return parent id"""
    return flow_info(workflow_run_id).parentID


def flow_ancestor_id(workflow_run_id):
    """return top level flow id"""
    while True:
        p = flow_parent_id(workflow_run_id)
        if p is None:
            return workflow_run_id
        else:
            workflow_run_id = p


def flow_children_ids(workflow_run_id):
    """return children flow ids as a set"""
    return flow_info(workflow_run_id).childrenRunIDs


def flow_offspring_ids(workflow_run_id):
    """return offspring ids as a set"""
    children = flow_children_ids(workflow_run_id)
    offspring = deepcopy(list(children))
    for c in children:
        offspring += list(flow_offspring_ids(c))
    return set(offspring)


def flow_rep(workflow_run_id):
    return "f%d" % workflow_run_id


def flow_name(workflow_run_id):
    """return workflow_name in flow_info"""
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).workflow_name


def flow_entitlement(workflow_run_id):
    """return entitlement in flow_info"""
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).entitlement


def flow_package(workflow_run_id):
    """return packageVersion in flow_info"""
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).packageVersion


def flow_owner(workflow_run_id):
    """return owner in flow_info"""
    return flow_info(workflow_run_id).owner


def flow_title(workflow_run_id):
    """return flow name/title in WorkflowRunMetadata, e.g. name, notes, tags,
    subscriber_ids"""
    fl = FlowSession()
    title = fl.get_workflow_run_metadata(workflow_run_id).name
    # could be None if canary
    return str(title)


def flow_metadata(workflow_run_id):
    """return flow metadata (name, notes, tags, model type id)"""
    fl = FlowSession()
    metadata = fl.get_workflow_run_metadata(workflow_run_id)
    return metadata


def flow_model_type_id(workflow_run_id):
    """return flow model type id in metadata"""
    return flow_metadata(workflow_run_id).model_type_id


def flow_set_model_type_id(workflow_run_id, model_type_id):
    """set flow model type id"""
    fl = FlowSession()
    fl.set_model_type_id(workflow_run_id, model_type_id)


def flow_set_title(workflow_run_id, title):
    """set flow title"""
    fl = FlowSession()
    fl.set_name(workflow_run_id, title)


@retryable(num_tries=3, sleep_time=1)
def flow_training_progress(workflow_run_id):
    """if a flow is a training workflow such as _train_workflow_impl, and is
    still running in progress, it returns ne, cali, and example num as a string
    to show its progress"""
    try:
        fl = FlowSession()
        result = fl.get_workflow_run_results_summary(workflow_run_id)
        ne = result["learning_curves"]["model/ne"]["data"][-1][1]
        num = result["learning_curves"]["model/ne"]["data"][-1][0]
        cali = 1.0 - (result["learning_curves"]["model/calibration"]["data"][-1][1])
        progress = "ne=%.6f, cali=%+.2g, example=%.2fM" % (ne, cali, num * 1e-6)
        return progress
    except Exception:
        return None


_FLOW_STATUS_MAP = {
    1: "SCHEDULED",
    2: "RUNNING",
    3: "SUCCEEDED",
    4: "FAILED",
    6: "KILLED",
    5: "NOT_AVAILABLE",
}


def flow_status(workflow_run_id):
    """flow status"""
    fl = FlowSession()
    st = fl.get_workflow_run_status(workflow_run_id)
    status_map = _FLOW_STATUS_MAP
    status = status_map[st]
    return status


@email()
def flow_summary(
    workflow_run_id,
    with_fburl=False,
    inspect_children=False,
    add_log=False,
    to_std=False,
):
    status = flow_status(workflow_run_id)
    lines = '%s, # %s, "%s", %s%s' % (
        workflow_run_id,
        status,
        flow_title(workflow_run_id),
        flow_elapsed_time_str(workflow_run_id),
        " " + fbl_flow_link(workflow_run_id) + " " if with_fburl else "",
    )
    indent = "#   |"
    arrow = "-> "
    sub_indent = " " * (len(arrow) + len("%s, # " % workflow_run_id))
    if status == "RUNNING" and inspect_children:
        for child in flow_children_ids(workflow_run_id):
            lines += "\n%s%s%s" % (
                indent,
                arrow,
                flow_summary(child, with_fburl=with_fburl),
            )
            if "train_workflow" in flow_name(child):
                child_progress = flow_training_progress(child)
                if child_progress is not None:
                    lines += "\n%s%s%s" % (indent, sub_indent, child_progress)
                for gc in flow_children_ids(child):
                    if "run_dist_job" in flow_name(
                        gc
                    ) and "Distributed Trainer" in flow_title(gc):
                        lines += "\n%s%s%s" % (
                            indent,
                            arrow,
                            flow_summary(gc, with_fburl=with_fburl),
                        )
                        gc_progress = flow_training_progress(gc)
                        if gc_progress is not None:
                            lines += "\n%s%s%s" % (indent, sub_indent, gc_progress)
    pprint(lines, add_log=add_log, to_std=to_std)
    return lines


@email()
def flow_one_line_summary(workflow_run_id_or_ids, **kwargs):
    add_log = kwargs.pop("add_log", False)
    to_std = kwargs.pop("to_std", False)
    workflow_run_ids = (
        [workflow_run_id_or_ids]
        if isinstance(workflow_run_id_or_ids, int)
        else workflow_run_id_or_ids
    )
    return "\n".join(
        [
            flow_summary(
                workflow_run_id,
                with_fburl=True,
                inspect_children=False,
                add_log=add_log,
                to_std=to_std,
                **kwargs
            )
            for workflow_run_id in workflow_run_ids
        ]
    )


@email()
def flow_detailed_summary(workflow_run_id_or_ids, **kwargs):
    add_log = kwargs.pop("add_log", False)
    to_std = kwargs.pop("to_std", False)
    workflow_run_ids = (
        [workflow_run_id_or_ids]
        if isinstance(workflow_run_id_or_ids, int)
        else workflow_run_id_or_ids
    )
    return "\n".join(
        [
            flow_summary(
                workflow_run_id,
                with_fburl=True,
                inspect_children=True,
                add_log=add_log,
                to_std=to_std,
                **kwargs
            )
            for workflow_run_id in workflow_run_ids
        ]
    )


def flow_detailed_status(workflow_run_id):
    """show flow detailed status:
    workflow_run_id, status, run_ts, scheduler_type, job_instance_id"""
    initialize_session(load_config())
    ret = Drivers.get(Drivers.GET_WORKFLOW_DETAILED_STATUS)([workflow_run_id])
    detailed_st = ret[workflow_run_id]
    return detailed_st


def flow_find_by_title(title, owner=None):
    """list the flows owned by the owner and in the specified status"""
    # fblearner/flow/driver/queries.py
    # fblearner/flow/storage/models.py
    from sqlalchemy.sql import text

    initialize_session(load_config())
    with SessionContext(Session) as session:
        rows = session.execute(
            text(
                """
                SELECT
                    run.id AS workflow_run_id,
                    metadata.name AS workflow_title
                FROM workflow_runs run
                LEFT OUTER JOIN workflow_run_metadata metadata ON
                    run.id = metadata.workflow_run_id
               WHERE
                    (metadata.name = '{title}'{owner_condition})
                """.format(
                    title=title,
                    owner_condition=(
                        ""
                        if owner is None
                        else " and run.owner_unixname = '{owner}'".format(owner=owner)
                    ),
                )
            )
        ).fetchall()
    return [r[0] for r in rows]


def flow_list(
    owner=None,
    status="RUNNING",
    top_lvl_only=False,
    sort_by_recency=False,
    to_std=False,
):
    owner = owner if owner is not None else whoami()
    """list the flows owned by the owner and in the specified status"""
    # fblearner/flow/driver/queries.py
    # fblearner/flow/storage/models.py
    from sqlalchemy.sql import text

    status_id = [k for k in _FLOW_STATUS_MAP if _FLOW_STATUS_MAP[k] == status][0]
    initialize_session(load_config())
    with SessionContext(Session) as session:
        rows = session.execute(
            text(
                """
                SELECT
                    run.id AS workflow_run_id,
                    st.status AS status,
                    run.time_created AS run_ts,
                    st.end_time AS end_time,
                    info.scheduler_type AS scheduler_type,
                    st.job_instance_id AS job_instance_id,
                    run.part_of_run_id AS part_of_run_id
                FROM workflow_runs run
                LEFT OUTER JOIN workflow_run_scheduler_info info ON
                    run.id = info.workflow_run_id
                LEFT OUTER JOIN job_instance_status st ON
                    st.scheduler_type = info.scheduler_type AND
                    st.job_instance_id = info.scheduler_job_instance_id
               WHERE
                    (run.owner_unixname = '{owner}' and st.status = {status})
                """.format(
                    owner=owner, status=status_id
                )
            )
        ).fetchall()
    workflow_run_ids = [r[0] for r in rows]
    top_lvl_run_ids = [r[0] for r in rows if r[-1] is None]
    if sort_by_recency:
        if top_lvl_only:
            top_lvl_run_ids = flow_sort_by_recency(top_lvl_run_ids)
        else:
            workflow_run_ids = flow_sort_by_recency(workflow_run_ids)
            top_lvl_run_ids = [i for i in workflow_run_ids if i in top_lvl_run_ids]
    if to_std:
        flow_one_line_summary(top_lvl_run_ids, to_std=to_std)
    return workflow_run_ids if not top_lvl_only else top_lvl_run_ids


def flow_sort_by_recency(workflow_run_ids):
    recency = {}
    for workflow_run_id in workflow_run_ids:
        recency[workflow_run_id] = flow_elapsed_time(workflow_run_id)
    return sorted(recency, key=lambda x: recency[x])


def flow_kill_stale(owner=None, days=10, add_log=False, to_std=True):
    owner = owner if owner is not None else whoami()
    workflow_run_ids = flow_list(owner)
    for workflow_run_id in workflow_run_ids:
        elapsed_time = flow_elapsed_time(workflow_run_id)
        if elapsed_time > datetime.timedelta(days=days):
            flow_one_line_summary(workflow_run_id, to_std=to_std, add_log=add_log)
            flow_kill(workflow_run_id)


def flow_start_time(workflow_run_id):
    """return flow start time or None"""
    try:
        return datetime.datetime.fromtimestamp(
            flow_detailed_status(workflow_run_id).run_ts
        )
    except Exception:
        return None


def flow_end_time(workflow_run_id):
    """return flow end time or None"""
    try:
        return datetime.datetime.fromtimestamp(
            flow_detailed_status(workflow_run_id).end_time
        )
    except Exception:
        return None


def flow_elapsed_time(workflow_run_id):
    """time elapsed from the time of flow creation"""
    return (
        flow_end_time(workflow_run_id) or datetime.datetime.now().replace(microsecond=0)
    ) - flow_start_time(workflow_run_id)


def flow_elapsed_time_str(workflow_run_id):
    """time duration as a string"""
    return timedelta_rep(flow_elapsed_time(workflow_run_id))


def flow_check_runs(workflow_run_ids, add_log=False, to_std=False):
    """
    print out a copy-friendly list of flow_ids with info;
    and return a list of finished (not running) flows
    """
    finished_runs = OrderedDict()
    running_runs = OrderedDict()
    succeeded_runs = OrderedDict()
    failed_runs = OrderedDict()
    for i in workflow_run_ids:
        st = flow_status(i)
        if st not in ["RUNNING", "SCHEDULED"]:
            finished_runs[i] = st
        if st == "RUNNING":
            running_runs[i] = st
        if st == "SUCCEEDED":
            succeeded_runs[i] = st
        if st == "FAILED":
            failed_runs[i] = st
    pprint(
        "%d/%d/%d FINISHED/SUCCEEDED/FAILED, %d/%d ALL/RUNNING"
        % (
            len(finished_runs),
            len(succeeded_runs),
            len(failed_runs),
            len(workflow_run_ids),
            len(running_runs),
        ),
        to_std=to_std,
        add_log=add_log,
    )
    return finished_runs, running_runs, succeeded_runs, failed_runs


@memoize_timed(24 * 60 * 60)
@retryable(num_tries=3, sleep_time=1)
def flow_pkg_extend(workflow_run_id):
    package = flow_package(workflow_run_id)
    # reset env
    my_env = os.environ.copy()
    my_env.pop("LD_LIBRARY_PATH")
    logger.info(
        "extend expiration of package %s (flow %s)" % (package, workflow_run_id)
    )
    logger.info(
        subprocess.check_output(
            ["fbpkg", "expire", "--extend-only", flow_package(workflow_run_id), "28d"],
            env=my_env,
        )
    )
    return package


def flow_pkg_build(mode="opt", send_email_notification=False):
    my_env = os.environ.copy()
    my_env.pop("LD_LIBRARY_PATH")
    diff_info = (
        subprocess.check_output(
            ["hg", "log", "-r", ".", "--template", "'{xg_sl_normal}'"],
            cwd=os.path.expanduser("~/fbcode"),
        )
        .replace('"', "")
        .replace("'", "")
    )
    mode = "default" if mode is None else mode
    title = "CANARY: %s @mode/%s" % (diff_info, mode)
    workflow_run_ids = flow_find_by_title(title)
    if len(workflow_run_ids) > 0:
        print("pkg previously canaried with run: {}".format(title))
    else:
        cmd = [
            os.path.expanduser("~/misc/scripts/canary_workflow.sh"),
            "-t",
            title,
            "-m",
            mode,
        ]
        output = subprocess.check_output(cmd, env=my_env)
        print(output)
        try:
            m = re.search(
                "our.intern.facebook.com/intern/fblearner/details/(\d+)", output
            )
            workflow_run_ids = [int(m.group(1))]
        except:
            workflow_run_ids = flow_find_by_title(title)
    assert len(workflow_run_ids) == 1, workflow_run_ids
    workflow_run_id = workflow_run_ids[0]
    print("FBL: %s, %s" % (flow_rep(workflow_run_id), fbl_flow_link(workflow_run_id)))
    if send_email_notification:
        send_email(
            subject="{}: {}".format(flow_rep(workflow_run_id), title),
            to=my_email_addr(),
            body="flow pkg is build: \n {}".format(
                "FBL: %s, %s"
                % (flow_rep(workflow_run_id), fbl_flow_link(workflow_run_id))
            ),
            auto_sig=True,
        )
    return workflow_run_id


def flow_clone(
    workflow_run_id,
    title=None,
    owner=None,
    entitlement=None,
    package=None,
    arg_modifier=None,
    title_suffix="",
):
    """clone a flow"""
    default_title = ", ".join(
        [flow_title(workflow_run_id), "clf%s" % str(workflow_run_id)]
    )
    run = flow_run(
        args=(lambda a: arg_modifier(a) if arg_modifier else a)(
            flow_input_args(workflow_run_id)
        ),
        title=(title or default_title) + title_suffix,
        owner=owner if owner is not None else whoami(),
        entitlement=entitlement or flow_entitlement(workflow_run_id),
        package=package or flow_package(workflow_run_id),
        workflow=flow_name(workflow_run_id),
        model_type_id=flow_model_type_id(workflow_run_id),
    )
    if arg_modifier is not None:
        logger.info(
            "flow compare: %s"
            % fbl_compare_link(run.id, workflow_run_id, print_fburl=False)
        )
    return run


def flow_kill(workflow_run_id_or_ids, reason="murdered"):
    """kill a flow with a reason"""
    fl = FlowSession()
    workflow_run_ids = (
        [workflow_run_id_or_ids]
        if isinstance(workflow_run_id_or_ids, int)
        else workflow_run_id_or_ids
    )
    for workflow_run_id in workflow_run_ids:
        fl.kill_workflow(workflow_run_id, reason=reason)
        logger.info("flow f%s killed (%s)" % (str(workflow_run_id), reason))


def flow_default_input_args(workflow_name=None, pkg_version=None, workflow_run_id=None):
    """get the default input args for a (workflow, pkg), or a flow id"""
    if workflow_run_id is not None:
        info = flow_info(workflow_run_id)
        workflow_name = info.workflow_name
        pkg_version = info.packageVersion
    else:
        assert workflow_name is not None
        assert pkg_version is not None
    initialize_session(load_config())
    with SessionContext(Session) as session:
        registration = (
            session.query(WorkflowRegistration)
            .join(Workflow, WorkflowRegistration.workflow)
            .filter(
                Workflow.workflow_name == workflow_name,
                WorkflowRegistration.fbpackage_version == pkg_version,
            )
            .one()
        )
        return json.loads(registration.default_inputs)


def flow_metrics(workflow_run_id_or_result, with_ext=True):
    """return a dict of train/eval metrics"""
    if isinstance(workflow_run_id_or_result, int):
        flow_id = workflow_run_id_or_result
        result = flow_result(flow_id)
    else:
        result = workflow_run_id_or_result
        try:
            flow_id = int(result["model_id"].split("_")[0])
        except Exception:
            flow_id = -1

    def quote(s):
        return '"' + s + '"'

    metrics = OrderedDict()
    ext_metrics = OrderedDict()
    metrics["flow_id"] = flow_id
    metrics["flow_name"] = '"%s"' % flow_title(flow_id)

    def get_metric(*keys):
        try:
            r = result
            for k in keys:
                r = r[k]
            return r
        except Exception:
            return None

    def add_ranking(mode):
        try:
            d = result[mode + "_metrics"]["ranking"]["numeric"]
            for k in sorted(d):
                v = d[k]
                if k != "num_add_times":
                    ext_metrics[mode + "_" + k] = v
        except Exception:
            return

    metrics["train_ne"] = get_metric("training_metrics", "model", "numeric", "ne")
    metrics["train_cali"] = 1.0 - get_metric(
        "training_metrics", "model", "numeric", "calibration"
    )
    metrics["train_qps"] = get_metric(
        "training_metrics", "qps_metric", "numeric", "lifetime_qps"
    )
    metrics["train_num"] = get_metric(
        "training_metrics", "qps_metric", "numeric", "lifetime_examples"
    )
    metrics["eval_ne"] = get_metric("eval_metrics", "model", "numeric", "ne")
    metrics["eval_cali"] = 1.0 - get_metric(
        "eval_metrics", "model", "numeric", "calibration"
    )
    metrics["eval_auc"] = get_metric("eval_metrics", "AUC", "numeric", "auc")

    if with_ext:
        add_ranking("training")
        add_ranking("eval")
    return (metrics, ext_metrics if with_ext else metrics)


def flow_report(workflow_run_ids, first_as_baseline=False, add_log=False):
    """given multiple flow ids/results, generate a report of their metrices"""
    if not isinstance(workflow_run_ids, list):
        workflow_run_ids = [workflow_run_ids]
    metrics_list = [flow_metrics(x, True) for x in workflow_run_ids]

    def metrics_to_text(metrics_list, separator=" ", with_format=True):
        lines = []
        assert len(metrics_list) > 0
        column_names = metrics_list[0].keys()
        filtered_column_names = [
            c for c in column_names if any(m[c] is not None for m in metrics_list)
        ]
        column_widths = {
            c: max(len(str(m[c])) for m in metrics_list) for c in filtered_column_names
        }

        def str_fmt(c, v):
            return (
                ("{" + ":^" + str(column_widths[c]) + "}").format(v)
                if with_format
                else str(v)
            )

        def diff(m, bm, c):
            if c in ["flow_id", "flow_name"]:
                return ""
            else:
                try:
                    return "{:+.6}%".format((m[c] - bm[c]) / bm[c] * 100.)
                except Exception:
                    return "-"

        def add_line(ln):
            lines.append(ln)
            if add_log:
                logger.info(ln)

        ln = separator.join([str_fmt(c, c) for c in filtered_column_names])
        add_line(ln)
        # lines.append(''.join(len(ln) * ['=']))
        # logger.info(''.join(len(ln) * ['=']))
        for i, m in enumerate(metrics_list):
            ln = separator.join([str_fmt(c, m[c]) for c in filtered_column_names])
            add_line(ln)
            if first_as_baseline:
                ln = separator.join(
                    [
                        str_fmt(c, diff(m, metrics_list[0], c))
                        for c in filtered_column_names
                    ]
                )
                add_line(ln)
        return "\n".join(lines)

    def merge_dict(a, b):
        c = OrderedDict()
        for k, v in a.items():
            c[k] = v
        for k, v in b.items():
            if k not in c:
                c[k] = v
        return c

    basic_metrics = [x[0] for x in metrics_list]
    ext_metrics = [x[1] for x in metrics_list]
    full_metrics = [merge_dict(x[0], x[1]) for x in metrics_list]
    brief_report = metrics_to_text(basic_metrics)
    detailed_report = metrics_to_text(full_metrics, ",", False)
    return brief_report, detailed_report


def flow_log_compare_result(everpaste_url, home_url, title, time):
    if everpaste_url is None or home_url is None:
        logger.info("nothing to compare -- exit")
    else:
        logger.info('Flow Report "%s"' % title)
        logger.info("     Everpaste url : %s" % everpaste_url)
        logger.info("     Home url      : %s" % home_url)
        logger.info("     Took : %ds" % int(time))


def flow_compare(
    workflow_run_ids,
    separator=" ",
    detailed_summary=False,
    title=None,
    everpaste_shorten_to_fburl=True,
    home_shorten_to_fburl=True,
):
    """compare multiple flow runs: 1) print summary; 2) report metrics"""
    compare_start_time = datetime.datetime.now()
    workflow_run_ids = [i for i in workflow_run_ids]
    if len(workflow_run_ids) == 0:
        flow_log_compare_result(None, None, None, None)
        return None, None
    summary = "\n".join(
        [
            flow_detailed_summary(i) if detailed_summary else flow_one_line_summary(i)
            for i in workflow_run_ids
        ]
    )
    brief_report, detailed_report = flow_report(
        workflow_run_ids, first_as_baseline=True, add_log=False
    )
    title = str(title) if title else ("FlowCompare:%s" % now_str())
    # everpaste
    everpaste_body = "\n\n\n".join([summary, brief_report])
    everpaste_content = "%s\n\n\n%s" % (title, everpaste_body)
    everpaste_url = vis_utils.get_everpaste_url(str(everpaste_content))
    if everpaste_shorten_to_fburl:
        everpaste_url = get_fburl(everpaste_url)
    # home
    xls_content = "%s\n\n\n%s" % (title, detailed_report)
    filename = "%s_%s.csv" % (title, uuid.uuid4())
    dump_dir = "/home/{}/public_html/flows/".format(whoami())
    dir_purge(dump_dir)
    with open(os.path.join(dump_dir, filename), "w") as f:
        f.write(xls_content)
    home_url = "https://home.fburl.com/~{}/flows/".format(whoami()) + filename
    if home_shorten_to_fburl:
        home_url = get_fburl(home_url)
    compare_finish_time = datetime.datetime.now()
    flow_log_compare_result(
        everpaste_url,
        home_url,
        title,
        (compare_finish_time - compare_start_time).total_seconds(),
    )
    return everpaste_url, home_url


def flow_check_and_compare_loop(workflow_run_ids, title, interval=1800, max_iter=-1):
    num_runs = 0
    everpaste_url = None
    home_url = None
    report_title = None
    iter = 0
    while True:
        logger.info(center_with_padding(title))
        finished_runs, running_runs, succeeded_runs, failed_runs = flow_check_runs(
            workflow_run_ids, add_log=True
        )
        for i in failed_runs:
            logger.warning("FAILED: %s" % flow_one_line_summary(i))
        if len(succeeded_runs) != num_runs:
            num_runs = len(succeeded_runs)
            report_title = "%s @ %s" % (title, now_str())
            # only compare succeeded runs
            everpaste_url, home_url = flow_compare(succeeded_runs, title=report_title)
        else:
            logger.info("NO MORE NEW SUCCEEDED RUNS...")
            flow_log_compare_result(everpaste_url, home_url, report_title, 0)
        logger.info(center_with_padding("") + "\n\n\n")
        iter += 1
        if len(finished_runs) == len(workflow_run_ids):
            logger.info("FLOW CHECK/COMPARE LOOP FINISHED...\n")
            break
        elif max_iter > 0 and iter >= max_iter:
            logger.info("FLOW CHECK/COMPARE LOOP REACHED %d ITER...\n" % max_iter)
            break
        else:
            logger.info("FLOW CHECK/COMPARE LOOP HIBERNATE for %ds\n" % interval)
            time.sleep(interval)


def fbl_flow_link(workflow_run_id, shorten_to_fburl=True):
    url = (
        "https://our.intern.facebook.com/intern/fblearner/details/%s" % workflow_run_id
    )
    return get_fburl(url) if shorten_to_fburl else url


def fbl_compare_link(*workflow_run_ids, **kwargs):
    """print the link to compare (at most 3) flows"""
    beg = "https://our.intern.facebook.com/intern/fblearner/run/compare/?"
    parts = []
    for (i, fid) in enumerate(workflow_run_ids):
        parts.append("compare_to[%s]=%s" % (i, fid))
    parts.append("baseline_run=%s" % workflow_run_ids[0])
    for (i, fid) in enumerate(workflow_run_ids):
        parts.append("all_runs[%s]=%s" % (i, fid))
    link = beg + "&".join(parts)
    fburl = get_fburl(link)
    if kwargs.get("print_fburl", True):
        pprint(fburl)
    return fburl


def chronos_top_user(
    host_pool="fblearner_ftw",
    num=10,
    show_cpu_usage=True,
    include_myself=True,
    rank_by_count=True,
    add_log=True,
    ago="-1h",
):
    """list top users of the host pool"""
    from RockfortExpress import RockfortExpress as rfe
    from RockfortExpress import constants as rfe_const
    from rfe import client as rfe_client
    from libfb.py.dateutil import parse_time
    import libfb.py.employee
    import getpass

    # check following files for reference:
    # fbcode/schedulers/chronos/py/libs/scubahelper.py
    # fbcode/schedulers/chronos/py/scripts/chronos/query_scuba.py
    # fbcode/aml/chronos_job_stats/

    def _get_base_query(tablename):
        return rfe.QueryCommon(
            user_name=getpass.getuser(),
            user_id=libfb.py.employee.unixname_to_uid(getpass.getuser()),
            instance=tablename,
        )

    SCUBA_TABLES = {
        "running": "chronos_resource_logs",
        "finished": "chronos_job_instance_states",
        "pending": "chronos_pending_job_instances",
    }
    table = SCUBA_TABLES["running"]
    query_common = _get_base_query(table)
    view = rfe.View(
        begin=int(parse_time(ago)),
        end=int(parse_time("now")),
        filters=[
            rfe.Filter(
                key="host_pool",
                key_type=rfe.DataType.NORMAL,
                string_vals=[str(host_pool)],
                operation=rfe_const.OP_IN,
            )
        ],
    )
    query_param = rfe.QueryParams(
        bucket_dimensions=["job_instance_id"],
        bucket_sizes=[1],
        dimensions=["owner"],
        collect=["cpu", "rss_memory"],  # aggregation columns
        limit=0,
        metric=rfe.Metric.AVG,
    )
    result = rfe_client.getClient().queryRollup(query_common, view, query_param).rows
    cpu = {}
    mem = {}
    cnt = {}
    for entry in result:
        o = entry.dimensions[1]
        if libfb.py.employee.unixname_to_uid(o) == 0:
            continue
        c = entry.values[0]
        m = entry.values[1]
        cpu[o] = cpu.get(o, 0.0) + c
        mem[o] = mem.get(o, 0.0) + m
        cnt[o] = cnt.get(o, 0) + 1

    cpu_sum = sum(cpu.values())
    mem_sum = sum(mem.values())
    cnt_sum = sum(cnt.values())

    fields = []
    metric = cnt if rank_by_count else cpu
    user = list(sorted(metric, key=lambda o: -metric[o]))
    rank = dict(zip(user, range(1, 1 + len(user))))
    myself = getpass.getuser()
    for o in list(islice(user, 0, min(num, len(user)))) + (
        [myself] if myself in user else []
    ):
        fields.append(
            [
                rank[o],
                o,
                cnt[o],
                float(cnt[o]) / cnt_sum * 100,
                cpu[o],
                float(cpu[o]) / cpu_sum * 100,
                mem[o],
                float(mem[o]) / mem_sum * 100,
            ]
        )
    pprint_tabular(
        fields,
        fmt={1: "{:^}", 3: "{:.2g}%", 5: "{:.2g}%", 7: "{:.2g}%"},
        title={0: "RANK", 1: "USER", 2: "COUNT", 4: "CPU", 6: "MEM"},
        col_sep="\n",
        row_sep=" ",
        add_log=add_log,
    )
    return fields


# --------------------------------- Experiments -------------------------------
def hive_dataset(path, backshift=0, days=1):
    def get_blacklisted_dates(path):
        client = get_flow_indexing_client()
        namespace, table, partition = parse_hive_path(path)
        blackout = client.getBlackoutPartitions(namespace, table).partition_specs

        def match(x):
            for k, v in x.items():
                if k != "ds" and v != partition.get(k, None):
                    return False
            return True

        blackout = [b.get("ds", None) for b in blackout if match(b)]
        return blackout

    def parse_hive_path(path):
        namespace, table, partition = path[7:].split("/", 2)  # len("hive://") == 7
        partition = OrderedDict([part.split("=") for part in partition.split("/")])
        return namespace, table, partition

    def get_valid_dates(path):
        namespace, table, partition = parse_hive_path(path)
        ps = "/".join(
            [k + "=" + v for k, v in partition.items() if k != "ds" and v != "*"]
        )
        meta = metastore(namespace=namespace)
        bad_ds = get_blacklisted_dates(path)
        all_ds = meta.get_partition_dates(table, ps=ps)
        dss = []
        for ds in all_ds:
            if ds not in dss and ds not in bad_ds:
                dss.append(ds)
        return dss

    ds = get_valid_dates(path)[::-1]
    return [
        path.replace("ds=*", "ds={}".format(ds[i])) for i in range(backshift, days)
    ][::-1]


def ads_train_eval_arg_update(
    args_or_workflow_id,
    use_hive2=True,
    metrics={"ne", "auc", "jsd", "ranking"},
    checkpoint=True,
    dataset=None,
):
    args = (
        flow_input_args(args_or_workflow_id)
        if type(args_or_workflow_id) == int
        else args_or_workflow_id
    )
    if use_hive2:
        args["train_reader_options"]["reader_type"] = "hiveio2"
        args["eval_reader_options"]["reader_type"] = "hiveio2"
    if metrics:
        args["metric_options"]["metrics"] = []
        if "ne" in metrics:
            args["metric_options"]["metrics"].append(
                {
                    "binary_ne": {
                        "weight_name": "supervision:weight",
                        "window_size": 1000000,
                        "name": "model",
                        "learning_curves": ["ne", "calibration", "window_ne"],
                        "plot_jsd": ("jsd" in metrics),
                    }
                }
            )
        if "auc" in metrics:
            args["metric_options"]["metrics"].append(
                {"auc": {"weight_name": "supervision:weight", "name": "AUC"}}
            )
        if "ranking" in metrics:
            args["metric_options"]["metrics"].append(
                {
                    "ranking_metric": {
                        "learning_curves": [
                            "PV_window_positive_20000",
                            "PV_window_negative_20000",
                            "PV_window_positive_40000",
                            "PV_window_negative_40000",
                            "PV_window_positive_60000",
                            "PV_window_negative_60000",
                            "PV_window_positive_80000",
                            "PV_window_negative_80000",
                            "PV_window_positive_100000",
                            "PV_window_negative_100000",
                            "NDCG_window_positive_20000",
                            "NDCG_window_negative_20000",
                            "NDCG_window_positive_40000",
                            "NDCG_window_negative_40000",
                            "NDCG_window_positive_60000",
                            "NDCG_window_negative_60000",
                            "NDCG_window_positive_80000",
                            "NDCG_window_negative_80000",
                            "NDCG_window_positive_100000",
                            "NDCG_window_negative_100000",
                        ],
                        "name": "ranking",
                        "weight_name": "supervision:weight",
                        "window_size": 120000,
                        "max_window_k": 100000,
                        "window_gl": 0.2,
                        "max_lifetime_k": 0,
                        "lifetime_gl": 0.2,
                        "compute_negative": True,
                        "predictive_value_at_top_k": True,
                        "ndcg_at_k": True,
                    }
                }
            )
    if checkpoint:
        args["checkpoint_options"] = {
            "aggressive_cleanup": True,
            "checkpoint_every_examples": None,
            "checkpoint_feature_strategy": "default",
            "checkpoint_path": None,
            "epoch_duration_minutes": None,
            "resume_from_epoch": None,
        }
    if dataset:
        hive_path, train_days, train_cap, eval_days, eval_cap = dataset
        args["train_reader_options"]["dataset"] = hive_dataset(
            hive_path, backshift=1, days=train_days
        )
        args["eval_reader_options"]["dataset"] = hive_dataset(
            hive_path, backshift=0, days=eval_days
        )
        if train_cap:
            args["train_reader_options"]["max_examples"] = train_cap
        if eval_cap:
            args["eval_reader_options"]["max_examples"] = eval_cap
    return args


def rep_func(func, rep, *args, **kwargs):
    return [func(*args, **kwargs) for _ in range(rep)]


def mlt_plot(x, y):
    plt.plot(x, y)
    plt.show()


def mlt_plot_curves(
    multi_curves, modifiers={}, names={}, beg=None, end=None, title=None
):
    beg = int(beg) if beg is not None else beg
    end = int(end) if end is not None else end
    if isinstance(multi_curves, list):
        points = multi_curves
        multi_curves = {"unnamed_curve": points}
    if isinstance(multi_curves, dict) and all(
        isinstance(v, list) for v in multi_curves.values()
    ):
        curves = multi_curves
        multi_curves = {"unnamed_subplot": curves}

    def get_data(points, modifier=None):
        x = []
        y = []
        modifier = modifier or (lambda x, y: (x, y))
        for (px, py) in points:
            if (beg is None or px >= beg) and (end is None or px < end):
                _x, _y = modifier(px, py)
                x.append(_x)
                y.append(_y)
        return x, y

    figsize = deepcopy(plt.rcParams["figure.figsize"])
    nrow = len(multi_curves)
    figsize[1] *= nrow
    fig, axs = plt.subplots(nrow, 1, figsize=figsize)
    if not isinstance(axs, Iterable):
        axs = [axs]
    for i, (subplot_title, curves) in enumerate(multi_curves.items()):
        data = {
            name: get_data(points, modifiers.get(name, None))
            for name, points in curves.items()
        }
        sample_nums = []
        for name, (x, y) in data.items():
            axs[i].plot(x, y, linestyle="-", marker=".", label=names.get(name, name))
            sample_nums.append(len(x))
        axs[i].legend(loc="best")
        axs[i].set_title(subplot_title)
        axs[i].text(
            0.5,
            -0.15,
            "samples: {}+/-{}".format(np.average(sample_nums), np.std(sample_nums)),
            horizontalalignment="center",
            transform=axs[i].transAxes,
        )
    if title is not None:
        plt.suptitle(title, y=0.99)
    plt.tight_layout(rect=[0, 0.0, 1, 0.98])
    plt.show()
    return fig


def mlt_plot_learning_curves_from_result(
    result,
    subplot_curve_names,
    modifiers={},
    names={},
    beg=None,
    end=None,
    title=None,
    publish=False,
):
    def get_curve(curve):
        return result["learning_curves"][curve]["data"]

    multi_curves = OrderedDict()
    if isinstance(subplot_curve_names, dict):
        for subplot_title, curves in subplot_curve_names.items():
            multi_curves[subplot_title] = OrderedDict()
            for curve in curves:
                multi_curves[subplot_title][curve] = get_curve(curve)
    else:
        subplot_title = ""
        multi_curves[subplot_title] = OrderedDict()
        for curve in subplot_curve_names:
            multi_curves[subplot_title][curve] = get_curve(curve)
    fig = mlt_plot_curves(multi_curves, modifiers, names, beg, end, title)
    if publish:
        fp, url = gen_home_file("%s.png" % title)
        fig.savefig(fp)
        pprint("image saved to: %s" % url)
        return url


def send_email(
    subject,
    to,
    frm=None,
    body="",
    reply_to=None,
    cc=None,
    attachment_file_paths=None,
    add_attachment_list=True,
    auto_sig=True,
):
    """
    Send emails with fields:
     subject, to
    and optional:
     from, body, reply_to, cc, attachments
    """
    import mimetypes
    from email.mime.base import MIMEBase
    from email import encoders
    from email.mime.text import MIMEText
    from email.mime.image import MIMEImage
    from email.mime.audio import MIMEAudio
    from email.mime.multipart import MIMEMultipart
    import smtplib
    import socket
    import getpass
    import libfb.py.employee

    COMMASPACE = ", "

    def attachment(path, ctype=None, encoding=None, filename=None):
        if ctype is None and encoding is None:
            # Guess the content type based on the file's extension.  Encoding
            # will be ignored, although we should check for simple things like
            # gzip'd or compressed files.
            ctype, encoding = mimetypes.guess_type(path)
        if ctype is None or encoding is not None:
            # No guess could be made, or the file is encoded (compressed), so
            # use a generic bag-of-bits type.
            ctype = "application/octet-stream"
        maintype, subtype = ctype.split("/", 1)
        filename = filename or os.path.basename(path)
        if maintype == "text":
            fp = open(path)
            # Note: we should handle calculating the charset
            att = MIMEText(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == "image":
            fp = open(path, "rb")
            att = MIMEImage(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == "audio":
            fp = open(path, "rb")
            att = MIMEAudio(fp.read(), _subtype=subtype)
            fp.close()
        else:
            fp = open(path, "rb")
            att = MIMEBase(maintype, subtype)
            att.set_payload(fp.read())
            fp.close()
            # Encode the payload using Base64
            encoders.encode_base64(att)
        # Set the filename parameter
        att.add_header("Content-Disposition", "attachment", filename=filename)
        return att, ctype, filename

    def get_default_frm():
        unix_name = getpass.getuser()
        host_name = socket.gethostname()
        full_name = libfb.py.employee.unixname_to_fullname(unix_name)
        frm = "{full_name} on {host_name} <{unix_name}@{host_name}>".format(
            full_name=full_name, host_name=host_name, unix_name=unix_name
        )
        return frm

    def stringfy_emails(recipients):
        if isinstance(recipients, string_types):
            return recipients
        elif isinstance(recipients, Iterable):
            return COMMASPACE.join([str(r) for r in recipients])
        else:
            raise TypeError

    def decode_recipients(s):
        return s.split(COMMASPACE)

    dest_list = []
    preamble = ""
    postscript = ""
    msg = MIMEMultipart()
    msg["Subject"] = str(subject)
    msg["From"] = str(frm) if frm else get_default_frm()
    msg["To"] = stringfy_emails(to)
    dest_list += decode_recipients(msg["To"])
    if reply_to is not None:
        msg["Reply-To"] = stringfy_emails(reply_to)
    if cc is not None:
        msg["Cc"] = stringfy_emails(cc)
        dest_list += decode_recipients(msg["Cc"])
    attachment_info = []
    attachment_mime = []
    if attachment_file_paths is not None:
        if isinstance(attachment_file_paths, string_types):
            attachment_file_paths = [attachment_file_paths]
        for fp in attachment_file_paths:
            att, ctype, name = attachment(fp)
            size = human_readable_file_size_str(fp)
            attachment_info.append((len(attachment_info), ctype, size, name))
            attachment_mime.append(att)
    if len(attachment_info) > 0 and add_attachment_list:
        postscript += "\n\n"
        postscript += "List of Attachments:\n"
        postscript += "====================\n"

        postscript += (
            format_tabular(
                attachment_info,
                fmt={0: "({:^})", 1: "{:^}", 2: "{:^}", 3: '"{:^}"'},
                title={0: "ID", 1: "TYPE", 2: "SIZE", 3: "NAME"},
                col_sep="\n",
                row_sep="\t",
            ).expandtabs(4)
            + "\n"
        )
    if auto_sig:
        postscript += "\n\n"
        postscript += "====\n".format(now=now_str())
        postscript += "Email Auto Sent on {now} by {host_name}\n".format(
            now=now_str(), host_name=socket.gethostname()
        )

    mail_text = str("\n").join([str(x) for x in [preamble, body, postscript]])
    msg.attach(MIMEText(mail_text, "plain", "utf-8"))
    for att in attachment_mime:
        msg.attach(att)
    mail_server = smtplib.SMTP("localhost")
    mail_server.sendmail(msg["From"], dest_list, msg.as_string())
    return msg


log_reset()

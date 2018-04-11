from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from fblearner.flow.core.attrdict import from_dict
from fblearner.flow.core.types_lib.type import encode as encode_flow_type
from fblearner.flow.core.types_lib.gettype import gettype
from fblearner.flow.external_api import FlowSession, WorkflowRun
from fblearner.flow.util.runner_utilities import load_config
from fblearner.flow.thrift.indexing.ttypes import WorkflowRunMetadataMutation
from fblearner.flow.storage.models import (
    ModelType,
    Session,
    SessionContext,
    initialize_session,
    WorkflowRun,
    WorkflowRegistration,
    Workflow,
)
import fblearner.flow.projects.dper.flow_types as T
# add this to enable get default input
import fblearner.flow.facebook.plugins.all_plugins  # noqa
from caffe2.python.fb.dper.layer_models.model_definition import ttypes
from thrift.protocol import TSimpleJSONProtocol
from thrift.transport.TTransport import TMemoryBuffer

from pprint import pprint, pformat
from copy import deepcopy
from collections import OrderedDict

import logging
import json
import numpy

# --------------------------------- logging -----------------------------------
logger = logging.getLogger(__name__)
formatter = logging.Formatter('%(levelname)s %(asctime)s : %(message)s')


def clean_logging(logger):
    handlers = logger.handlers[:]
    for h in handlers:
        h.close()
        logger.removeHandler(h)


def add_logging(file_name):
    fh = logging.FileHandler(file_name)
    fh.setFormatter(formatter)
    logger.addHandler(fh)


def log_blank():
    logger.info('')
    logger.info('')
    logger.info('')
    logger.info('## -----------------------------------------------')
    logger.info('## -----------------------------------------------')
    logger.info('## -----------------------------------------------')
    logger.info('## -----------------------------------------------')
    logger.info('## -----------------------------------------------')
    logger.info('')
    logger.info('')
    logger.info('')


clean_logging(logger)
logger.setLevel(logging.INFO)
add_logging(r'/home/xlwang/fbcode/experimental/xlwang/ipy_flow_debug.log')
for h in logging.root.handlers:
    h.setFormatter(formatter)

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


APOLLO_XIII_TAG_ID = 325182364673414


def flow_run(
    args,
    title='test',
    owner='xlwang',
    entitlement='ads_ftw',
    package='aml.dper2:73',
    workflow='dper.workflows.ads.train_eval_workflow',
):
    """schedule a flow run, and return the WorkflowRun instance"""
    fl = FlowSession()
    run = fl.schedule_workflow(
        owner=owner,
        workflow_name=workflow,
        input_arguments=args,
        entitlement=entitlement,
        package_version=package,
        metadata=WorkflowRunMetadataMutation(
            name=title, notes='', add_tags=[APOLLO_XIII_TAG_ID]
        ),
    )
    logger.info(
        'flow "%s" launched: id=f%s \n    %s' % (
            title, str(run.id), (
                'https://our.intern.facebook.com/intern/fblearner/details/%s' %
                run.id
            )
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
    input_args = fl.get_workflow_run_inputs_summary(
        workflow_run_id=workflow_run_id
    )
    if print_return:
        pprint(input_args)
    return input_args


def flow_info(workflow_run_id):
    """return flow info, e.g., owner, packageVersion, childrenRunIDs,
    workflow_name, entitlement"""
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id)


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
    return title


def flow_set_title(workflow_run_id, title):
    fl = FlowSession()
    fl.set_name(workflow_run_id, title)


def flow_training_progress(workflow_run_id):
    """if a flow is a training workflow such as _train_workflow_impl, and is
    still running in progress, it returns ne, cali, and example num as a string
    to show its progress"""
    try:
        fl = FlowSession()
        result = fl.get_workflow_run_results_summary(workflow_run_id)
        ne = result['learning_curves']['model/ne']['data'][-1][1]
        num = result['learning_curves']['model/ne']['data'][-1][0]
        cali = result['learning_curves']['model/calibration']['data'][-1][1]
        progress = 'ne=%.6f, cali=%.6f, example=%.2fM' % (ne, cali, num * 1e-6)
        return progress
    except Exception:
        return None


def flow_status(workflow_run_id, add_log=True, inspect_children=True):
    """flow status, and default to output to logger and also checks running
    instance's children"""
    fl = FlowSession()
    st = fl.get_workflow_run_status(workflow_run_id)
    status_map = {
        1: 'SCHEDULED',
        2: 'RUNNING',
        3: 'SUCCEEDED',
        4: 'FAILED',
        6: 'KILLED',
        5: 'NOT_AVAILABLE'
    }
    status = status_map[st]
    if add_log:
        logger.info(
            'f%s # %s %s' %
            (workflow_run_id, status, flow_title(workflow_run_id))
        )
    if status == 'RUNNING':
        info = fl.get_workflow_run_info(workflow_run_id)
        children = list(info.childrenRunIDs)
        if len(children) > 0:
            for child in children:
                child_name = flow_name(child)
                child_st = fl.get_workflow_run_status(child)
                if add_log:
                    indent = '    |'
                    beg = ('-> f%s:' % child)
                    logger.info(
                        '%s%s %s (%s)' %
                        (indent, beg, status_map[child_st], child_name)
                    )
                    if ('train_workflow' in child_name):
                        child_progress = flow_training_progress(child)
                        if child_progress is not None:
                            logger.info(
                                '%s%s %s' %
                                (indent, ' ' * len(beg), child_progress)
                            )
                        # check grandchildren
                        grandchildren = list(
                            fl.get_workflow_run_info(child).childrenRunIDs
                        )
                        for gc in grandchildren:
                            gc_name = flow_name(gc)
                            gc_st = fl.get_workflow_run_status(gc)
                            gc_tt = flow_title(gc)
                            if ('run_dist_job' in gc_name and
                                    'Distributed Trainer' in gc_tt):
                                beg = ('-> f%s:' % gc)
                                logger.info(
                                    '%s%s %s (%s)' %
                                    (indent, beg, status_map[gc_st], gc_name)
                                )
                                gc_progress = flow_training_progress(gc)
                                if gc_progress is not None:
                                    logger.info(
                                        '%s%s %s' %
                                        (indent, ' ' * len(beg), gc_progress)
                                    )
    return status


def flow_summary(workflow_run_id, add_log=True):
    """show flow summary: workflow_run_id, name, owner, status, and title"""
    name = flow_name(workflow_run_id)
    title = flow_title(workflow_run_id)
    owner = flow_info(workflow_run_id).owner
    status = flow_status(workflow_run_id, add_log=False)
    lines = [
        '[%s]: %s (%s), %s' % (workflow_run_id, name, owner, status),
        '    %s' % title
    ]
    if add_log:
        for ln in lines:
            logger.info(ln)
    return '\n'.join(lines)


def flow_short_summary(workflow_run_id, add_log=True):
    """easy to crop out the flow ids and return status"""
    title = flow_title(workflow_run_id)
    owner = flow_info(workflow_run_id).owner
    status = flow_status(workflow_run_id, add_log=False)
    ln = '%s, # %-12s "%s", %s' % (workflow_run_id, owner, title, status)
    if add_log:
        logger.info(ln)
    return ln


def flow_check_runs(*workflow_run_ids):
    """
    print out a copy-friendly list of flow_ids with info;
    and return a list of finished (not running) flows
    """
    finished_runs = OrderedDict()
    lns = []
    for i in workflow_run_ids:
        lns += [flow_short_summary(i, add_log=False)]
        st = flow_status(i, add_log=True, inspect_children=True)
        if st != 'RUNNING':
            finished_runs[i] = st
    print('\n'.join(lns))
    return finished_runs


def flow_clone(
    workflow_run_id,
    title=None,
    owner=None,
    entitlement=None,
    package=None,
):
    """clone a flow"""
    default_title = ', '.join(
        [flow_title(workflow_run_id), 'clf%s' % str(workflow_run_id)]
    )
    run = flow_run(
        args=flow_input_args(workflow_run_id),
        title=title or default_title,
        owner=owner or 'xlwang',
        entitlement=entitlement or 'ads_ftw',
        package=package or flow_package(workflow_run_id),
        workflow=flow_name(workflow_run_id)
    )

    return run


def flow_kill(workflow_run_id, reason='murdered'):
    """kill a flow with a reason"""
    fl = FlowSession()
    fl.kill_workflow(workflow_run_id, reason=reason)
    logger.info('flow f%s killed (%s)' % (str(workflow_run_id), reason))


def flow_default_input_args(
    workflow_name=None, pkg_version=None, workflow_run_id=None
):
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
        registration = session.query(WorkflowRegistration).join(
            Workflow, WorkflowRegistration.workflow
        ).filter(
            Workflow.workflow_name == workflow_name,
            WorkflowRegistration.fbpackage_version == pkg_version
        ).one()
        return json.loads(registration.default_inputs)


def flow_metrics(workflow_run_id_or_result):
    """return a dict of train/eval metrics"""
    if isinstance(workflow_run_id_or_result, int):
        flow_id = workflow_run_id_or_result
        result = flow_result(flow_id)
    else:
        result = workflow_run_id_or_result
        try:
            flow_id = int(result['model_id'].split('_')[0])
        except Exception:
            flow_id = -1
    metrics = OrderedDict()
    metrics['flow_id'] = flow_id
    try:
        train_ne = result['training_metrics']['model']['numeric']['ne']
    except Exception:
        train_ne = None
    metrics['train_ne'] = train_ne
    try:
        train_cali = (
            result['training_metrics']['model']['numeric']['calibration']
        )
    except Exception:
        train_cali = None
    metrics['train_cali'] = train_cali
    try:
        train_qps = (
            result['training_metrics']['qps_metric']['numeric']['lifetime_qps']
        )
    except Exception:
        train_qps = None
    metrics['train_qps'] = train_qps
    try:
        eval_ne = result['eval_metrics']['model']['numeric']['ne']
    except Exception:
        eval_ne = None
    metrics['eval_ne'] = eval_ne
    try:
        eval_cali = result['eval_metrics']['model']['numeric']['calibration']
    except Exception:
        eval_cali = None
    metrics['eval_cali'] = eval_cali
    try:
        eval_auc = result['eval_metrics']['AUC']['numeric']['auc']
    except Exception:
        eval_auc = None
    metrics['eval_auc'] = eval_auc
    return metrics


def flow_report(
    workflow_run_ids, separator=' ', first_as_baseline=False, show_title=True
):
    """given multiple flow ids/results, generate a report of their metrices"""
    lines = []
    if not isinstance(workflow_run_ids, list):
        workflow_run_ids = [workflow_run_ids]
    metrics_list = [flow_metrics(x) for x in workflow_run_ids]
    assert len(metrics_list) > 0
    column_names = metrics_list[0].keys()
    filtered_column_names = [
        c for c in column_names if any(m[c] is not None for m in metrics_list)
    ]
    column_widths = {
        c: max(len(str(m[c])) for m in metrics_list)
        for c in filtered_column_names
    }

    def str_fmt(c, v):
        return ('{' + ':^' + str(column_widths[c]) + '}').format(v)

    def diff(m, bm, c):
        if c == 'flow_id':
            return ''
        else:
            try:
                return '{:+.6}%'.format((m[c] - bm[c]) / bm[c] * 100.)
            except Exception:
                return '-'

    ln = separator.join([str_fmt(c, c) for c in filtered_column_names])
    lines.append(ln)
    logger.info(ln)
    lines.append(''.join(len(ln) * ['=']))
    logger.info(''.join(len(ln) * ['=']))
    for i, m in enumerate(metrics_list):
        ln = separator.join(
            [str_fmt(c, m[c]) for c in filtered_column_names] +
            ([flow_title(workflow_run_ids[i])] if show_title else [])
        )
        lines.append(ln)
        logger.info(ln)
        if first_as_baseline:
            ln = separator.join(
                [
                    str_fmt(c, diff(m, metrics_list[0], c))
                    for c in filtered_column_names
                ]
            )
            lines.append(ln)
            logger.info(ln)
    return '\n'.join(lines)


def flow_compare(
    workflow_run_ids, separator=' ', summary_style='short', show_title=True
):
    """compare multiple flow runs: 1) print summary; 2) report metrics"""
    summary = '\n'.join(
        [
            (
                flow_short_summary(i)
                if summary_style == 'short' else flow_summary(i)
            ) for i in workflow_run_ids
        ]
    )
    report = flow_report(workflow_run_ids, separator, True, show_title=True)
    return '\n'.join([summary, report])


def fbl_compare_link(*workflow_run_ids):
    """print the link to compare (at most 3) flows"""
    beg = 'https://our.intern.facebook.com/intern/fblearner/run/compare/?'
    parts = []
    for (i, fid) in enumerate(workflow_run_ids):
        parts.append('compare_to[%s]=%s' % (i, fid))
    parts.append('baseline_run=%s' % workflow_run_ids[0])
    for (i, fid) in enumerate(workflow_run_ids):
        parts.append('all_runs[%s]=%s' % (i, fid))
    link = beg + '&'.join(parts)
    print(link)


logger.info('')
logger.info('')
logger.info('')
logger.info('')
logger.info('')
logger.info('============================================')
logger.info('========== NEW IPYTHON, START LOG ==========')
logger.info('============================================')
logger.info('')
logger.info('')
logger.info('')
logger.info('')
logger.info('')

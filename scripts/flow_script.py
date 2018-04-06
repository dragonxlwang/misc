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

from pprint import pprint
from copy import deepcopy
from collections import OrderedDict

import logging
import json
import numpy


logger = logging.getLogger(__name__)


def clean_logging(logger):
    handlers = logger.handlers[:]
    for h in handlers:
        h.close()
        logger.removeHandler(h)


clean_logging(logger)
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(levelname)s %(asctime)s : %(message)s')
fh = logging.FileHandler(
    r'/home/xlwang/fbcode/experimental/xlwang/ipy_flow_debug.log'
)
fh.setFormatter(formatter)
logger.addHandler(fh)
for h in logging.root.handlers:
    h.setFormatter(formatter)

################################################################################


def tt_to_json(obj):
    trans = TMemoryBuffer()
    proto = TSimpleJSONProtocol.TSimpleJSONProtocol(trans)
    obj.write(proto)
    return trans.getvalue()


def tt_to_dict(obj):
    return json.loads(tt_to_json(obj))


def ft_to_dict(obj):
    return encode_flow_type(None, obj)


################################################################################

APOLLO_XIII_TAG_ID=325182364673414

def flow_run(
    args,
    title='test',
    owner='xlwang',
    entitlement='ads_ftw',
    package='aml.dper2:73',
    workflow='dper.workflows.ads.train_eval_workflow',
):
    fl = FlowSession()
    run = fl.schedule_workflow(
        owner=owner,
        workflow_name=workflow,
        input_arguments=args,
        entitlement=entitlement,
        package_version=package,
        metadata=WorkflowRunMetadataMutation(name=title, notes='', add_tags=[APOLLO_XIII_TAG_ID]),
    )
    logger.info(
        'flow "%s" launched: id=f%s \n    %s' % (
            title, str(run.id),
            'https://our.intern.facebook.com/intern/fblearner/details/%s' % run.
            id
        )
    )
    return run


def flow_result(workflow_run_id, print_return=False):
    fl = FlowSession()
    result = fl.get_workflow_run_results_summary(
        workflow_run_id, update_gluster_access_time_for_output=False
    )
    if print_return:
        pprint(result)
    return result


def flow_input_args(workflow_run_id, print_return=False):
    fl = FlowSession()
    input_args = fl.get_workflow_run_inputs_summary(
        workflow_run_id=workflow_run_id
    )
    if print_return:
        pprint(input_args)
    return input_args


def flow_info(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id)


def flow_name(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).workflow_name


def flow_title(workflow_run_id):
    fl = FlowSession()
    title = fl.get_workflow_run_metadata(workflow_run_id).name
    return title


def flow_entitlement(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).entitlement


def flow_package(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).packageVersion

def flow_owner(workflow_run_id):
    return flow_info(workflow_run_id).owner

def flow_status(workflow_run_id, add_log=True):
    fl = FlowSession()
    st = fl.get_workflow_run_status(workflow_run_id)
    status = {
        1: 'SCHEDULED',
        2: 'RUNNING',
        3: 'SUCCEEDED',
        4: 'FAILED',
        6: 'KILLED',
        5: 'NOT_AVAILABLE'
    }[st]
    if add_log:
        logger.info('f%s: %s' % (workflow_run_id, status))
    return status


def flow_summary(workflow_run_id):
    name = flow_name(workflow_run_id)
    title = flow_title(workflow_run_id)
    owner = flow_info(workflow_run_id).owner
    status = flow_status(workflow_run_id, add_log=False)
    lines = []
    ln = '[%s]: %s (%s), %s' % (workflow_run_id, name, owner, status)
    lines.append(ln)
    logger.info(ln)
    ln = '    %s' % title
    lines.append(ln)
    logger.info(ln)
    return '\n'.join(lines)


def flow_clone(workflow_run_id):
    fl = FlowSession()
    args = flow_input_args(workflow_run_id)
    name = flow_name(workflow_run_id)
    title = '%s: cloned from f%s' % (name, str(workflow_run_id))
    run = run_flow(args, title)
    return run


def flow_kill(workflow_run_id, reason='murdered'):
    fl = FlowSession()
    fl.kill_workflow(workflow_run_id, reason=reason)
    logger.info('flow f%s killed (%s)' % (str(workflow_run_id), reason))


def get_flow_default_inputs(
    workflow_name=None, pkg_version=None, workflow_run_id=None
):
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
    if isinstance(workflow_run_id_or_result, int):
        flow_id = workflow_run_id_or_result
        result = flow_result(flow_id)
    else:
        result = workflow_run_id_or_result
        try:
            flow_id = int(result['model_id'].split('_')[0])
        except:
            flow_id = -1
    metrics = OrderedDict()
    metrics['flow_id'] = flow_id
    try:
        train_ne = result['training_metrics']['model']['numeric']['ne']
    except:
        train_ne = None
    metrics['train_ne'] = train_ne
    try:
        train_cali = result['training_metrics']['model']['numeric'
                                                        ]['calibration']
    except:
        train_cali = None
    metrics['train_cali'] = train_cali
    try:
        train_qps = result['training_metrics']['qps_metric']['numeric'
                                                            ]['lifetime_qps']
    except:
        train_qps = None
    metrics['train_qps'] = train_qps
    try:
        eval_ne = result['eval_metrics']['model']['numeric']['ne']
    except:
        eval_ne = None
    metrics['eval_ne'] = eval_ne
    try:
        eval_cali = result['eval_metrics']['model']['numeric']['calibration']
    except:
        eval_cali = None
    metrics['eval_cali'] = eval_cali
    try:
        eval_auc = result['eval_metrics']['AUC']['numeric']['auc']
    except:
        eval_auc = None
    metrics['eval_auc'] = eval_auc
    return metrics


def flow_report(
    workflow_run_ids_or_results, separator=' ', first_as_baseline=False
):
    lines = []
    if not isinstance(workflow_run_ids_or_results, list):
        workflow_run_ids_or_results = [workflow_run_ids_or_results]
    metrics_list = [flow_metrics(x) for x in workflow_run_ids_or_results]
    assert len(metrics_list) > 0
    column_names = metrics_list[0].keys()
    filtered_column_names = [
        c for c in column_names if any(m[c] is not None for m in metrics_list)
    ]
    column_widths = {
        c: max([len(str(m[c])) for m in metrics_list])
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
            except:
                return '-'

    ln = separator.join([str_fmt(c, c) for c in filtered_column_names])
    lines.append(ln)
    logger.info(ln)
    lines.append(''.join(len(ln) * ['=']))
    logger.info(''.join(len(ln) * ['=']))
    for m in metrics_list:
        ln = separator.join([str_fmt(c, m[c]) for c in filtered_column_names])
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


def flow_compare(workflow_run_ids, separator=' '):
    summary = '\n'.join([flow_summary(i) for i in workflow_run_ids])
    report = flow_report(workflow_run_ids, separator, True)
    return '\n'.join([summary, report])

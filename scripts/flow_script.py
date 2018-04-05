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
import logging
import json

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


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
        metadata=WorkflowRunMetadataMutation(name=title, notes='', add_tags=[]),
    )
    logger.info('flow "%s" launched: id=f%s' % (title, str(run.id)))
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


def flow_entitlement(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).entitlement


def flow_package(workflow_run_id):
    fl = FlowSession()
    return fl.get_workflow_run_info(workflow_run_id).packageVersion


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


def flow_metrics(workflow_run_ids_or_results):
    fl = FlowSession()
    if not isinstance(workflow_run_ids_or_results, list):
        workflow_run_ids_or_results = [workflow_run_ids_or_results]
    logger.info('Tne, Tcali, Tqps, Ene, Ecali, Eauc')
    for id_or_result in workflow_run_ids_or_results:
        if isinstance(id_or_result, int):
            result = flow_result(id_or_result)
        else:
            result = id_or_result
        train_ne = result['training_metrics']['model']['numeric']['ne']
        train_cali = result['training_metrics']['model']['numeric'
                                                        ]['calibration']
        train_qps = result['training_metrics']['qps_metric']['numeric'
                                                            ]['lifetime_qps']
        eval_ne = result['eval_metrics']['model']['numeric']['ne']
        eval_cali = result['eval_metrics']['model']['numeric']['calibration']
        try:
            eval_auc = result['eval_metrics']['AUC']['numeric']['auc']
        except:
            eval_auc = None
        logger.info(
            'f%s %s %s %s %s %s %s' % (
                fid, train_ne, train_cali, train_qps, eval_ne, eval_cali,
                eval_auc
            )
        )


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


def tt_to_json(obj):
    trans = TMemoryBuffer()
    proto = TSimpleJSONProtocol.TSimpleJSONProtocol(trans)
    obj.write(proto)
    return trans.getvalue()


def tt_to_dict(obj):
    return json.loads(tt_to_json(obj))


def ft_to_dict(obj):
    return encode_flow_type(None, obj)

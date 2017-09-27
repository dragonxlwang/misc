from __future__ import print_function

from fblearner.flow.service.flow_client import get_client
import json
import argparse
import sys
import os
import pprint
import logging

logging.basicConfig()
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def get_flow_input(fbl=None, save_path=None, **kwargs):
    fbl = int(fbl)
    client = get_client()
    input = client.getWorkflowRunInputs(fbl)
    if not save_path:
        save_path = 'fbl{}.json'.format(fbl)
    logger.info("Save FBL {} to {}".format(fbl, save_path))
    with open(os.path.expanduser(save_path), 'w') as fout:
        input = json.loads(input)
        input = json.dumps(input, indent=4)
        fout.write(input)


def get_args(argv):
    parser = argparse.ArgumentParser(prog='flow_util')
    flow_launcher = argparse.ArgumentParser(add_help=False)
    flow_launcher.add_argument(
        "--fbl",
        help='Fblearner flow id.',
    )
    io_launcher = argparse.ArgumentParser(add_help=False)
    io_launcher.add_argument(
        "--save-path",
        default=None,
        help='Save to file path.',
    )
    subparsers = parser.add_subparsers(title="Subcommands")
    get_flow_input_subparser = subparsers.add_parser(
        "get_input",
        help="Get flow input",
        parents=[flow_launcher, io_launcher],
    )
    get_flow_input_subparser.set_defaults(func=get_flow_input)
    return parser.parse_args(argv)


if __name__ == '__main__':
    args = get_args(sys.argv[1:])
    # try:
    args.func(**vars(args))
    # except:
    #     print("Error", file=sys.stderr)
    #     sys.exit(1)

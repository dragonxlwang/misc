from __future__ import (absolute_import, division, print_function,
                        unicode_literals)

import argparse
import getpass

from metastore import metastore


def get_default_user():
    return getpass.getuser()


def list_table(args):
    m = metastore(namespace=args.namespace)
    tables = m.get_table_names_by_filter('hive_filter_field_owner__="%s"' % args.user)
    print(",\n".join(tables))


def subparse_list_table(subparsers):
    sap = subparsers.add_parser("list_table")
    sap.add_argument("--namespace", default="search")
    sap.add_argument("--user", default=get_default_user())
    sap.set_defaults(func=list_table)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Metastore Util")
    subparsers = ap.add_subparsers()
    subparse_list_table(subparsers)
    args = ap.parse_args()
    args.func(args)

#!/usr/bin/env python
import json
import os
import subprocess
import sys
import threading

# debug = False
# logfile = sys.stdout if debug else open(
#     '/tmp/ycm_extra.' + str(os.getpid()), 'w', 0
# )

# print >> logfile, time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime())

subp_lock = threading.Lock()


def subp(cmd):
    with subp_lock:
        return subprocess.Popen(
            cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE
        ).communicate()


fb_cdb_fp = os.path.join(os.path.expanduser("~"), "fbcode", "compile_commands.json")


def buck_query(filename):
    filename = _rel_fbcode(filename)
    cmd = ["buck", "query", "owner(%s)" % filename]
    [out, err] = subp(cmd)
    if not out:
        print(
            "\033[1;31m" + "No target found: " + "'" + " ".join(cmd) + "'" + "\033[0m"
        )
        raise Exception
    targets = [x.strip() for x in sorted(out.splitlines())]
    print("\033[1;32mFound Target for %s:\033[0m" % filename)
    for i, t in enumerate(targets):
        print("{}:".format(i), t)
    return targets


def _find_target(arg0, arg1=None):
    if not os.path.exists(arg0):
        targets = [arg0]
    elif os.path.isdir(arg0):
        targets = _findall_recursive_in_dir(arg0)
    else:
        targets = buck_query(str(arg0))
        if arg1 is not None:
            targets = [targets[int(arg1)]]
    return targets


def _rel_fbcode(f):
    f = os.path.abspath(f)
    assert "fbcode/" in f
    f = f.split("fbcode/")[-1]
    return f


def _findall_recursive_in_dir(arg0):
    if not arg0.endswith("/"):
        arg0 += "/"
    cmd = ["find", arg0, "-type", "f"]
    [out, err] = subp(cmd)
    if not out:
        print("\033[1;31m" + "No Files found: " + "'" + " ".join(cmd) + "'" + "\033[0m")
        exit(1)
    files = [x.strip() for x in sorted(out.splitlines())]
    targets = []
    cc_lst = ["cc", "cu", "c", "cpp"]

    def is_cc(f):
        ext = f.split(".")[-1]
        return ext != f and ext in cc_lst

    for f in files:
        if is_cc(f):
            try:
                targets += _find_target(f, 0)
            except Exception:
                pass
    return targets


def _dump_json(cdb_dict, cdb_fp):
    print("\033[1;32mDump Compiled DB:\033[0m")
    print(cdb_fp)
    with open(cdb_fp, "w") as f:
        f.write(json.dumps(cdb_dict.values()))


def buck_gen(arg0, arg1=None):
    targets = _find_target(arg0, arg1)
    assert len(targets) == 1
    target = targets[0]
    cmd = ["buck", "build", "--show-output", "%s#compilation-database" % target]
    [out, err] = subp(cmd)
    cdb_fp = out.strip().split()[-1]
    print("\033[1;32mCompiled DB:\033[0m")
    print(cdb_fp)
    return cdb_fp


def buck_add_cdb_to_dict(cdb_dict, cdb_fp):
    try:
        print("\033[1;32mAdd Compiled DB:\033[0m")
        if not os.path.isabs(cdb_fp):
            cdb_fp = os.path.join(os.path.expanduser("~"), "fbcode", cdb_fp)
        print(cdb_fp)

        with open(cdb_fp) as f:
            try:
                json_content = json.loads(f.read())
            except Exception:
                print("\033[1;31mCannot parse file at {}\033[0m".format(cdb_fp))
                return cdb_dict
    except IOError:
        print("\033[1;31mCannot find file at {}\033[0m".format(cdb_fp))
        return cdb_dict

    def maybe_wrap(arg):
        if "=" in arg:
            arg = "'" + arg + "'"

    old_cnt = len(cdb_dict)
    for entry in json_content:
        if "command" in entry:
            entry.pop("arguments", None)
        elif "arguments" in entry:
            entry["command"] = " ".join(entry["arguments"])
            entry.pop("arguments", None)
        f = entry["file"]
        if f not in cdb_dict:
            cdb_dict[f] = entry
    new_cnt = len(cdb_dict)
    print("Compile DB Size: {0} -> {1}".format(old_cnt, new_cnt))
    return cdb_dict


def buck_add(arg0, arg1=None):
    targets = _find_target(arg0, arg1)
    cdb_dict = {}
    targets = set(targets)
    for target in targets:
        cdb_fp = buck_gen(target)
        buck_add_cdb_to_dict(cdb_dict, cdb_fp)
    buck_add_cdb_to_dict(cdb_dict, fb_cdb_fp)
    _dump_json(cdb_dict, fb_cdb_fp)


def buck_check(filename):
    fp = os.path.abspath(filename)
    cdb_dict = {}
    buck_add_cdb_to_dict(cdb_dict, fb_cdb_fp)
    if_in = fp in cdb_dict
    print(
        "\033[1;32mFound Target {0} in {1}\033[0m? {2}".format(
            fp, fb_cdb_fp, "YES" if if_in else "NO"
        )
    )
    if if_in:
        print(cdb_dict[fp])


def buck_print():
    cdb_dict = {}
    buck_add_cdb_to_dict(cdb_dict, fb_cdb_fp)
    for i, f in enumerate(cdb_dict):
        print("[{0}]: {1}".format(i, f))


if __name__ == "__main__":
    args = sys.argv
    cmd = str(args[1]) if len(args) > 1 else "help"
    if cmd == "query":
        buck_query(args[2])
    if cmd == "gen":
        buck_gen(*args[2:])
    if cmd == "clean":
        try:
            os.remove(fb_cdb_fp)
        except OSError:
            print("\033[1;31mCannot delete file at {}\033[0m".format(fb_cdb_fp))
    if cmd == "add":
        buck_add(*args[2:])
    if cmd == "check":
        buck_check(args[2])
    if cmd == "print":
        buck_print()
    if cmd.endswith("help"):
        print("== buck utilities == ")
        print("options:")
        print("* query [FILE] : query target rules related to a file")
        print("* gen   [rule] : generate compiled_commands for a rule")
        print("* clean        : delete compiled_commands")
        print("* add   [rule] : add a rule to compiled_commands")
        print("* check [file] : check if a file is already added")
        print("* print        : print added files in compiled_commands")

#!/usr/bin/env python3
#
# This file has been generated by conda-smithy in order to build the recipe
# locally.
#
import os
import glob
import subprocess
from argparse import ArgumentParser


def setup_environment(ns):
    os.environ["CONFIG"] = ns.config
    os.environ["UPLOAD_PACKAGES"] = "False"


def run_docker_build(ns):
    script = glob.glob(".*/run_docker_build.sh")[0]
    subprocess.check_call(script)

def verify_config(ns):
    valid_configs = {os.path.basename(f)[:-5] for f in glob.glob(".ci_support/*.yaml")}
    print(f"valid configs are {valid_configs}")
    if ns.config in valid_configs:
        print("Using " + ns.config + " configuration")
        return
    elif len(valid_configs) == 1:
        ns.config = valid_configs.pop()
        print("Found " + ns.config + " configuration")
    elif ns.config is None:
        print("config not selected, please choose from the following:\n")
        selections = list(enumerate(sorted(valid_configs), 1))
        for i, c in selections:
            print(f"{i}. {c}")
        s = input("\n> ")
        idx = int(s) - 1
        ns.config = selections[idx][1]
        print(f"selected {ns.config}")
    else:
        raise ValueError("config " + ns.config + " is not valid")
    # Remove the following, as implemented
    if not ns.config.startswith('linux'):
        raise ValueError(f"only Linux configs currently supported, got {ns.config}")


def main(args=None):
    p = ArgumentParser("build-locally")
    p.add_argument("config", default=None, nargs="?")

    ns = p.parse_args(args=args)
    verify_config(ns)
    setup_environment(ns)

    run_docker_build(ns)


if __name__ == "__main__":
    main()


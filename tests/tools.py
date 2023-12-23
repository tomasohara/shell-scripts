#! /usr/bin/env python
#
# Tools for simplify testing
#
# This provides tools for simplify testing
#
# usage example:
# tools eval_condition 2+2==4
# tools exec_with_log ls
# tools conditional_exec 2+2==4 ls

import os
import sys


def eval_condition(condition):
    """eval condition and throw result via stdout or stderr"""
    print("eval", condition)
    try:
        result = eval(condition)
        print(result)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)

def exec_with_log(command: str):
    """execute command and throw the result into a /tmp/{command}-{PID}.log file"""
    print("exec", command)
    result = os.popen(command).read()

    # Crea un nombre de archivo único utilizando el PID del proceso
    file_name = f"/tmp/{command.replace(' ', '')}-{os.getpid()}.log"

    # Crea el archivo temporal, sobreescribe si ya existe
    with open(file_name, 'w') as f:
        f.write(result)

def conditional_exec(condition, command):
    """execute command if condition is true"""
    print(f"eval {condition}")
    try:
        result = eval(condition)
        if result:
            print(f"exec {command}")
            os.system(command)

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)


commands = {
    'eval_condition': eval_condition,
    'exec_with_log': exec_with_log,
    'conditional_exec': conditional_exec,
}

if __name__ == '__main__':
    command = os.path.basename(sys.argv[1])
    assert sys.argv[2:], "No arguments provided"
    if command in commands:
        commands[command](*sys.argv[2:])
    else:
        print(f"ERROR: {command} not found", file=sys.stderr)
        sys.exit(1)
    
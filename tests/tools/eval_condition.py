#!/usr/bin/env python
#
# Evaluation tool for test scripts
#
# This script evaluates a condition and optionally executes a command
#
# NOTE: This file can be referenced using the eval-condition
#       alias defined in the tomohara-aliases.bash file
# usage example:
# eval-condition --condition 2+2==4
# eval-condition --condition 2+2==4 --exec "ls -l"

"""Script to evaluate a condition and optionally execute a command"""

from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main

class CondEval:
    """Class to evaluate conditions and execute commands"""

    def __init__(self,condition, command):
        """Initialize the class with the condition and optional command"""
        self.condition = condition
        self.command = command
        debug.trace_object(debug.TL.DETAILED, self, label=f"{self.__class__.__name__} instance")

    def eval_condition(self, ):
        """Evaluate the condition and return True or False"""
        try:
            result = eval(self.condition)
            debug.trace(debug.TL.QUITE_DETAILED, f"eval_condition({self.condition!r}) => {result}")
            return result
        except Exception as e:
            print(f"Error evaluating condition: {e}")
            return False

    def exec_command(self):
        """Execute the command if present"""
        if self.command:
            try:
                result = gh.run(self.command)
                debug.trace(debug.TL.QUITE_DETAILED, f"command({self.command!r}) => {result}")
                print(result)
            except Exception as e:
                print(f"Error executing command: {e}")

class Script(Main):
    """Main class for the script"""

    def setup(self):
        # Get the condition and command (if provided)
        self.command = self.get_parsed_option("exec", None)
        self.condition = self.get_parsed_option("condition", None)
        # Create an instance of the condition evaluator
        self.evaluator_inst = CondEval(self.condition, self.command)
        debug.trace_current_context(level=debug.TL.QUITE_VERBOSE)

    def run_main_step(self):
        """Run the main step of the script"""
        result = self.evaluator_inst.eval_condition()
        # If the condition is True and a command is provided, execute it
        if result and self.command:
            self.evaluator_inst.exec_command()
        # Otherwise, just print the result of the condition evaluation
        else:
            print(result)

def main():
    """Main function to execute the script"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        text_options=[
            ("condition", "Condition to evaluate"),
            ("exec", "Command to execute if the condition is True"),
        ],
        skip_input=True
    )
    app.run()

if __name__ == '__main__':
    # Execute the main function
    main()

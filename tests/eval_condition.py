#!/usr/bin/env python
#
# Evaluation tool for test scripts
#
# This script evaluates a condition and optionally executes a command
#
# Note:
# - This file can be referenced using the eval-condition alias in testing-aliases.bash.
#
# TODO:
# - Add in motivation in terms of example-based testing.
# - Otherwise, this seems like a complicated script for doing simple evaluations.
#

"""
Script to evaluate a condition and optionally execute a command

Sample usage:
    {script} '2+2==4'

    {script} '2+2==4' --exec "ls -l"
"""

from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants
TL = debug.TL

class CondEval:
    """Class to evaluate conditions and execute commands"""

    def __init__(self):
        """Initialize the class"""
        debug.trace_object(TL.DETAILED, self, label=f"{self.__class__.__name__} instance")

    def eval_condition(self, condition, context=None):
        """Evaluate the condition and return True or False, using optional CONTEXT dict.
        Note: Return None if exception occurred"""
        result = None
        # pylint: disable=eval-used,bare-except
        try:
            result = eval(condition, context)         
        except:
            system.print_exception_info("eval_condition")
        debug.trace(TL.QUITE_DETAILED, f"eval_condition({condition!r}) => {result!r}")
        return result

    def exec_command(self, command):
        """Execute the command if present and return output
        Note: Return None if exception occurred"""
        result = None
        try:
            result = gh.run(command)
        except:                               # pylint: disable=bare-except
            system.print_exception_info("eval_condition")
        debug.trace(TL.QUITE_DETAILED, f"command({command!r}) => {result}")
        return result


class Script(Main):
    """Main class for the script"""
    command = None
    condition = None
    evaluator_inst = None
    context = None

    def setup(self):
        """Check results of command line processing"""
        # Get the condition and command (if provided)
        self.command = self.get_parsed_option("exec", None)
        self.condition = self.get_parsed_option("condition", None)
        # Support stdin in condition and command
        if "stdin" in self.condition:
            # The input stream is assigned to a local variable, which later gets
            # used as context for the evaluatiom. This avoid headaches trying to
            # parse the expression, such as accounting for "stdin" as a literal
            # in the condition, different quotes, etc.
            self.context = { "stdin": self.read_entire_input() }

        # Create an instance of the condition evaluator
        self.evaluator_inst = CondEval()
        debug.trace_current_context(level=TL.QUITE_VERBOSE)

    def run_main_step(self):
        """Run the main step of the script"""
        output = ""

        # Evaluate condition and optionally show result
        eval_result = self.evaluator_inst.eval_condition(self.condition,
                                                         context=self.context)
        if self.verbose:
            print(f"Evaluation of condition {self.condition!r}: {eval_result}")
            if self.context:
                print(f"STDIN:\n{self.context['stdin']}")
        if not self.command:
            output = eval_result

        # Evaluate command
        if eval_result and self.command:
            if self.verbose:
                print(f"Executing command: {self.command}")
            output = self.evaluator_inst.exec_command(self.command)

        # Print final output
        print(output)

def main():
    """Main function to execute the script"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        text_options=[
            ("exec", "Command to execute if the condition is True"),
        ],
        positional_arguments=[
            ("condition", "Condition to evaluate"),
        ],
        skip_input=False,
        manual_input=True
    )
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    # Execute the main function
    main()

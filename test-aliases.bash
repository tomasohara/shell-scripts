# test-aliases.bash: python aliases for testing tools
#
# usage:
#    source test-aliases.bash
#
# testing tools:
#   eval-condition: evaluates a condition and optionally executes a command if the condition is true


alias eval-condition='python eval_condition.py'
alias stable-diffusion='STREAMLINED_CLIP=1 python "$(realpath "../../mezcla/mezcla/examples/hf_stable_diffusion.py")"'
alias sd-description='stable-diffusion --batch --img2txt'
# alias sd-generation='stable-diffusion' # HOW TO DO TXT2IMG?
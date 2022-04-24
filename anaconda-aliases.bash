# Anaconda support based on conda installation
#
#------------------------------------------------------------------------
# Copyright (c) 2020 Thomas P. O'Hara
#
# This software is Open Source, licensed under the GNU Lesser General Public Version 3 (LGPLv3). See LICENSE.txt in directory (or repository).
#

# Uncomment the following line(s) for tracing:
## set -o xtrace
## echo "in anaconda-aliases.bash"

# add-conda-env-to-xterm-title(): puts conda prompt modifier in xterm title
# along with python version (e.g., "...; Py3.6:(old_tensorflow)")
# note: also resets prompt to '$ ' (following change by conda scripts)
function add-conda-env-to-xterm-title {
    export XTERM_TITLE_SUFFIX="Py$(python --version 2>&1 | extract_matches.perl -i 'python (\d.\d)'):$CONDA_PROMPT_MODIFIER"

    reset-prompt
    set-title-to-current-dir
}

# TODO: Put in a separate file (e.g., .bashrc.anaconda)
anaconda3_dir="$HOME/anaconda3"
anaconda2_dir="$HOME/anaconda2"
# OLD: init-conda(dir])
# init-condaN([- | dir]): initialize anaconda using specified dir (or ~/anaconda3)
function init-condaN() {
    local anaconda_dir="$1"
    ## DEBUG: echo "in init-condaN $1*"
    ## OLD: if [ "$anaconda_dir" = "" ]; then anaconda_dir="$anaconda3_dir"; fi
    if [ "$anaconda_dir" = "" ]; then echo "Usage: init-condaN anaconda-dir"; return; fi
    if [ "$anaconda_dir" = "-" ]; then anaconda_dir="$anaconda3_dir"; fi
    # Note: assignment separates so that $? preserved
    #     https://unix.stackexchange.com/questions/506352/bash-what-does-masking-return-values-mean
    local conda_setup
    conda_setup="$($anaconda_dir'/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$conda_setup"
    else
        if [ -f "$anaconda_dir/etc/profile.d/conda.sh" ]; then
	    . "$anaconda_dir/etc/profile.d/conda.sh"
        ## OLD: else
            ## OLD: export PATH="$anaconda_dir/bin:$PATH"
        fi
	prepend-path "$anaconda_dir/bin"
    fi

    # Restore Bash prompt and put conda environment in xterm title instead
    ## OLD: reset-prompt
    add-conda-env-to-xterm-title

    # HACK: make sure cls aliased to default Unix version of clear (anaconda3 quirk) and also that it doesn't clear the terminal buffer [n.b., effing stupid feature introduction in long-stading utility!]
    ## OLD: alias cls='/usr/bin/clear'
    alias cls='/usr/bin/clear -x'

    ## DEBUG: echo "out: init-condaN()"
}
alias init-conda3='init-condaN $anaconda3_dir'
alias init-conda2='init-condaN $anaconda2_dir'
alias init-conda=init-conda2
# TODO: alias init-conda=init-conda3

# Work around for intermittent problems w/ 'conda activate' requiring 'source activate' instead.
# activation-helper is to handle deactivate as well
function activation-helper () {
    local command="$1"
    local env="$2"
    local conda_command="conda"
    # Note: need to use conda's alias not the script returned by which
    local conda_path=$(/usr/bin/which $conda) 2> /dev/null
    if [ "$conda_path" = "" ]; then
	conda_command="source"
    fi
    ## DEBUG:
    ## echo "Issuing: $conda_command" "$command" "$env"
    $conda_command "$command" $env
}
alias conda-activate='activation-helper activate'
alias conda-deactivate='activation-helper deactivate'
#
## OLD: alias add-tensorfow='conda activate env_tensorflow_gpu'
alias add-tensorfow='conda-activate env_tensorflow_gpu'
alias all-conda-to-pythonpath='export PYTHONPATH=$anaconda3_dir/envs/env_tensorflow_gpu/lib/python3.7/site-packages:$anaconda3_dir/lib/python3.7:$PYTHONPATH'
# OLD: alias init-jsl-conda='init-conda; export PYTHONPATH="$HOME/john-snow-labs/python:$PYTHONPATH"'
# note: various conda-xyz aliases for sake of tab completion
alias conda-list-env='conda list env'
alias conda-list-env-hack='ls ~/.conda/envs'
alias conda-env-list='conda env list'
alias conda-env-name='conda env list | extract_matches.perl "^(\S+ )  " | echoize'
## OLD: alias conda-activate-env='source activate'
## OLD: function conda-activate-env { source activate "$1"; add-conda-env-to-xterm-title; }
function conda-activate-env {
    ## DEBUG: echo "in conda-activate-env $*"
    local env="$1"
    if [ "$env" = "" ]; then
	echo "Usage: conda-activate-env"
	echo ""
	echo "Note: available environments:"
	## TODO: use columns
	conda-list-env-hack | perl -pe 's/^/    /;'
	echo ""
    fi
    ## OLD: source activate "$env";
    conda-activate "$env"
    add-conda-env-to-xterm-title;
}
## OLD: alias conda-deactivate-env='source deactivate'
## OLD: function conda-deactivate-env { source deactivate "$1"; add-conda-env-to-xterm-title; }
## OLD: function conda-deactivate-env { conda deactivate "$1"; add-conda-env-to-xterm-title; }
function conda-deactivate-env {
    conda-deactivate
    add-conda-env-to-xterm-title
}

# Miniconda3 initializaion
# <<< conda initialize <<<
# !! Contents within this block are managed by 'conda init' !!
function init-miniconda3 () {
    local base="/usr/local/misc/programs/anaconda3"
    local conda_setup
    conda_setup="$("$base/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
	eval "$conda_setup"
    else
	if [ -f "$base/etc/profile.d/conda.sh" ]; then
            . "$base/etc/profile.d/conda.sh"
	else
            export PATH="$base/bin:$PATH"
	fi
    fi

    # Restore Bash prompt and put conda environment in xterm title instead
    ## OLD: reset-prompt
    add-conda-env-to-xterm-title
}

# conda-create-env(name, [python_version=3.7]): create Python3 environment for Python 3.7 by default
# TODO: determine the version, make sure ipython gets installed
function conda-create-env () {
    if [ "$1" = "" ]; then
	echo "usage: conda-create-env name [python_version=3.7]"
	return
    fi
    local name="$1"
    local python_version="$2"
    if [ "$python_version" = "" ]; then python_version="3.7"; fi
    ensure-conda-loaded
    conda create --yes --name "$name" python="$python_version"
}

# ensure-conda-loaded(): Make sure conda environment loaded (e.g., via miniconda3)
#
function ensure-conda-loaded {
    if [ "$CONDA_PYTHON_EXE" = "" ]; then
	echo "Warning: Conda not initialized so using miniconda3"
	init-miniconda3;
    fi
}

# conda-init-env(name): make sure conda environment NAME is active, as well
# as ensuring conda itself is active.
#
function conda-init-env {
    local env_name="$1"
    ensure-conda-loaded
    ## OLD: source activate $env_name
    conda-activate $env_name
    ## OLD: reset-prompt
    add-conda-env-to-xterm-title
}

# Misc. aliases
alias conda-info-env='conda info --envs'

# Uncomment the following line for tracing:
## echo "out anaconda-aliases.bash"

## TODO: delete
## dummy change for git

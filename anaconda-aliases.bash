# Anaconda support from tpo-magro (circa Jan 2020)
#
#------------------------------------------------------------------------
# Copyright (c) 2020 Thomas P. O'Hara
#
# This software is Open Source, licensed under the GNU Lesser General Public Version 3 (LGPLv3). See LICENSE.txt in directory (or repository).
#

# add-conda-env-to-xterm-title(): puts conda prompt modifier in xterm title
# along with python version (e.g., "...; Py3.6:(old_tensorflow)")
# note: also resets prompt to '$ '
function add-conda-env-to-xterm-title {
    export XTERM_TITLE_SUFFIX="Py$(python --version 2>&1 | extract_matches.perl -i 'python (\d.\d)'):$CONDA_PROMPT_MODIFIER"

    reset-prompt
    set-title-to-current-dir
}

# TODO: Put in a separate file (e.g., .bashrc.anaconda)
anaconda3_dir="/home/tomohara/anaconda3"
anaconda2_dir="/home/tomohara/anaconda2"
# OLD: init-conda(dir])
# init-condaN([- | dir]): initialize anaconda using specified dir (or ~/anaconda3)
function init-condaN() {
    local anaconda_dir="$1"
    ## OLD: if [ "$anaconda_dir" = "" ]; then anaconda_dir="$anaconda3_dir"; fi
    if [ "$anaconda_dir" = "" ]; then echo "Usage: init-condaN anaconda-dir"; return; fi
    if [ "$anaconda_dir" = "-" ]; then anaconda_dir="$anaconda3_dir"; fi
    local conda_setup="$($anaconda_dir'/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
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

    # HACK: make sure clr aliased to default Unix version of clear (anaconda3 quirk)
    alias cls='/usr/bin/clear'
}
alias init-conda3='init-condaN $anaconda3_dir'
alias init-conda2='init-condaN $anaconda2_dir'
alias init-conda=init-conda2
# TODO: alias init-conda=init-conda3
alias add-tensorfow='conda activate env_tensorflow_gpu'
alias all-conda-to-pythonpath='export PYTHONPATH=$anaconda3_dir/envs/env_tensorflow_gpu/lib/python3.7/site-packages:$anaconda3_dir/lib/python3.7:$PYTHONPATH'
# OLD: alias init-jsl-conda='init-conda; export PYTHONPATH="$HOME/john-snow-labs/python:$PYTHONPATH"'
# note: various conda-xyz aliases for sake of tab completion
## alias conda-list-env='conda list env'
alias conda-list-env='conda env list'
alias conda-list-env-hack='ls ~/.conda/envs'
alias conda-activate-env='source activate'
alias conda-deactivate-env='source deactivate'
## OLD: alias activate-conda-env=conda-activate-env

# Miniconda3 initializaion
# <<< conda initialize <<<
# !! Contents within this block are managed by 'conda init' !!
function init-miniconda3 () {
    ## OLD: local base="/usr/local/misc/programs/miniconda3"
    local base="$HOME/miniconda3"
    local conda_setup="$("$base/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
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
    local name="$1"
    local python_version="$2"
    if [ "$python_version" = "" ]; then python_version="3.7"; fi
    ensure-conda-loaded
    conda create --name "$name" python="$python_version"
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
    source activate $env_name
    ## OLD: reset-prompt
    add-conda-env-to-xterm-title
}

# Misc. aliases
alias conda-info-env='conda info --envs'

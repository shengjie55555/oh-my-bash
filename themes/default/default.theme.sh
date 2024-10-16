#! bash oh-my-bash.module
#
# One line prompt showing the following configurable information
# for git:
# time (virtual_env) username@hostname pwd git_char|git_branch git_dirty_status|→
#
# The → arrow shows the exit status of the last command:
# - bold green: 0 exit status
# - bold red: non-zero exit status
#
# Example outside git repo:
# 07:45:05 user@host ~ →
#
# Example inside clean git repo:
# 07:45:05 user@host .oh-my-bash ±|master|→
#
# Example inside dirty git repo:
# 07:45:05 user@host .oh-my-bash ±|master ✗|→
#
# Example with virtual environment:
# 07:45:05 (venv) user@host ~ →
#

SCM_NONE_CHAR=''
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_green}|"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"
SCM_GIT_SHOW_MINIMAL_INFO=true

CLOCK_THEME_PROMPT_PREFIX=''
CLOCK_THEME_PROMPT_SUFFIX=' '
THEME_SHOW_CLOCK=${THEME_SHOW_CLOCK:-"true"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_navy"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

OMB_PROMPT_VIRTUALENV_FORMAT='(%s) '
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

function _omb_theme_PROMPT_COMMAND() {
    # This needs to be first to save last command return code
    local RC="$?"

    local hostname="${_omb_prompt_bold_gray}\u@\h"
    local python_venv; _omb_prompt_get_python_venv
    python_venv=$_omb_prompt_white$python_venv

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${_omb_prompt_bold_green}"
    else
        ret_status="${_omb_prompt_bold_brown}"
    fi

    # Append new history lines to history file
    history -a

    # PS1="$(clock_prompt)$python_venv${hostname} ${_omb_prompt_bold_teal}\W $(scm_prompt_char_info)${ret_status}→ ${_omb_prompt_normal}"

    BOLD=$(tput bold)
    BLUE="\[\033[0;34m\]"
    GREEN="\[\033[0;32m\]"
    CYAN="\[\033[0;36m\]"
    PURPLE="\[\033[0;35m\]"
    YELLOW="\[\033[0;33m\]"
    RED="\[\033[0;31m\]"
    RESET="\[\033[0m\]"

    source /home/shengjie.wu/.oh-my-bash/tools/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1

    # 定义缓存文件路径
    GPU_MODEL_CACHE_FILE="$HOME/.gpu_model_cache"

    # 函数获取GPU型号并缓存结果
    get_gpu_model() {
        # 检查缓存文件是否存在且非空
        if [ ! -s "$GPU_MODEL_CACHE_FILE" ]; then
            # 获取GPU型号，并将其写入缓存文件
            nvidia-smi -L | head -n 1 | awk '{print $4}' | cut -d "-" -f1 > "$GPU_MODEL_CACHE_FILE"
        fi
        # 无论是否刚刚创建，都从缓存文件读取GPU型号
        cat "$GPU_MODEL_CACHE_FILE"
    }

    # PS1="$(clock_prompt)${BLUE}\u${RESET}@${GREEN}\h-$(get_gpu_model)${RESET}:${PURPLE}\W${RESET}\$(__git_ps1 '(%s)') \$ "
    # PS1="$(clock_prompt)$python_venv${hostname}-$(get_gpu_model)${RESET}:${PURPLE}\W${RESET}\$(__git_ps1 '(%s)') \$ "
    PS1="$(clock_prompt)$python_venv${hostname}-$(get_gpu_model)${RESET}:${_omb_prompt_bold_teal}\W${RESET}${GREEN}$(__git_ps1 '(%s)')${RESET} \$ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

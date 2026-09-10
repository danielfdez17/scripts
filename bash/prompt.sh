# shellcheck shell=bash
# Source this file from ~/.bashrc (do not execute it):
#   source /path/to/scripts/bash/prompt.sh
#
# Prompt layout:
#   ~/relative/path  branch ⇡2 ⇣1 +1 !2 ?3 =1 $2 [merge]  ➜
#
# Git tokens: ⇡ ahead  ⇣ behind  + staged  ! unstaged  ? untracked
#             = conflicts  $ stash  [merge]/[rebase]/[cherry-pick]/[revert]/[bisect]
#
# Depends only on bash and git. No starship, oh-my-posh, or other prompt tools.
#
# Optional environment variables:
#   SCRIPTS_PROMPT=0      skip installing the prompt
#   SCRIPTS_PROMPT_GIT=0  hide the git segment (path-only prompt)

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "Source this file from ~/.bashrc:" >&2
    echo "  source $0" >&2
    exit 1
fi

[[ $- == *i* ]] || return
[[ "${SCRIPTS_PROMPT:-1}" != "0" ]] || return

__scripts_prompt_reset='\[\033[0m\]'
__scripts_prompt_bold='\[\033[1m\]'
__scripts_prompt_red='\[\033[0;31m\]'
__scripts_prompt_green='\[\033[0;32m\]'
__scripts_prompt_yellow='\[\033[0;33m\]'
__scripts_prompt_cyan='\[\033[0;36m\]'
__scripts_prompt_magenta='\[\033[0;35m\]'

if [[ -n "${NO_COLOR:-}" ]]; then
    __scripts_prompt_reset=''
    __scripts_prompt_bold=''
    __scripts_prompt_red=''
    __scripts_prompt_green=''
    __scripts_prompt_yellow=''
    __scripts_prompt_cyan=''
    __scripts_prompt_magenta=''
fi

# Append a status token (symbol + optional count) to the git segment.
__scripts_prompt_append() {
    local -n __scripts_prompt_buffer="$1"
    local color=$2
    local symbol=$3
    local count=${4:-}

    if [[ -n "$count" && "$count" -eq 0 ]]; then
        return
    fi

    __scripts_prompt_buffer+="${color}${symbol}"
    if [[ -n "$count" ]]; then
        __scripts_prompt_buffer+="${count}"
    fi
    __scripts_prompt_buffer+="${__scripts_prompt_reset} "
}

# Build the git segment for the current directory, or print nothing.
__scripts_prompt_git() {
    [[ "${SCRIPTS_PROMPT_GIT:-1}" != "0" ]] || return
    command -v git >/dev/null 2>&1 || return

    local git_status
    git_status="$(GIT_OPTIONAL_LOCKS=0 git status --porcelain=v1 -b --ignore-submodules=dirty 2>/dev/null)" || return
    [[ -n "$git_status" ]] || return

    local branch="" ahead=0 behind=0 gone=0
    local staged=0 unstaged=0 untracked=0 conflicted=0 stashed=0
    local operation="" first=1 line x y xy
    local detached_re='\(HEAD detached at ([^)]+)\)'
    local ahead_re='ahead[[:space:]]+([0-9]+)'
    local behind_re='behind[[:space:]]+([0-9]+)'
    local stash_re='^[0-9]+$'

    while IFS= read -r line || [[ -n "$line" ]]; do
        if (( first )); then
            first=0
            local header="${line#\#\# }"
            if [[ "$header" == "HEAD (no branch)" ]]; then
                branch="$(GIT_OPTIONAL_LOCKS=0 git rev-parse --short HEAD 2>/dev/null || printf '%s' "detached")"
            elif [[ "$header" =~ $detached_re ]]; then
                branch="${BASH_REMATCH[1]}"
            else
                branch="${header#No commits yet on }"
                branch="${branch%%...*}"
            fi
            [[ "$header" =~ $ahead_re ]] && ahead="${BASH_REMATCH[1]}"
            [[ "$header" =~ $behind_re ]] && behind="${BASH_REMATCH[1]}"
            [[ "$header" == *"[gone]"* ]] && gone=1
            continue
        fi

        xy="${line:0:2}"
        x="${xy:0:1}"
        y="${xy:1:1}"
        case "$xy" in
            \?\?)
                untracked=$((untracked + 1))
                ;;
            UU|AA|DD|AU|UA|DU|UD)
                conflicted=$((conflicted + 1))
                ;;
            *)
                if [[ "$x" != ' ' && "$x" != '?' && "$x" != '!' ]]; then
                    staged=$((staged + 1))
                fi
                if [[ "$y" != ' ' && "$y" != '?' && "$y" != '!' ]]; then
                    unstaged=$((unstaged + 1))
                fi
                ;;
        esac
    done <<< "$git_status"

    local git_dir
    git_dir="$(GIT_OPTIONAL_LOCKS=0 git rev-parse --git-dir 2>/dev/null)" || git_dir=""
    if [[ -n "$git_dir" ]]; then
        if [[ -d "$git_dir/rebase-merge" ]]; then
            operation="rebase"
            if [[ -f "$git_dir/rebase-merge/msgnum" && -f "$git_dir/rebase-merge/end" ]]; then
                local step="" total=""
                IFS= read -r step < "$git_dir/rebase-merge/msgnum"
                IFS= read -r total < "$git_dir/rebase-merge/end"
                [[ -n "$step" && -n "$total" ]] && operation="rebase ${step}/${total}"
            fi
        elif [[ -d "$git_dir/rebase-apply" ]]; then
            operation="rebase"
            if [[ -f "$git_dir/rebase-apply/next" && -f "$git_dir/rebase-apply/last" ]]; then
                local step="" total=""
                IFS= read -r step < "$git_dir/rebase-apply/next"
                IFS= read -r total < "$git_dir/rebase-apply/last"
                [[ -n "$step" && -n "$total" ]] && operation="rebase ${step}/${total}"
            fi
        elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
            operation="merge"
        elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
            operation="cherry-pick"
        elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
            operation="revert"
        elif [[ -f "$git_dir/BISECT_LOG" ]]; then
            operation="bisect"
        fi

        stashed="$(GIT_OPTIONAL_LOCKS=0 git rev-list --walk-reflogs --count refs/stash 2>/dev/null || true)"
        [[ "$stashed" =~ $stash_re ]] || stashed=0
    fi

    [[ -n "$branch" ]] || return

    local segment=" ${__scripts_prompt_magenta}${branch}${__scripts_prompt_reset} "
    __scripts_prompt_append segment "$__scripts_prompt_green" "⇡" "$ahead"
    __scripts_prompt_append segment "$__scripts_prompt_red" "⇣" "$behind"
    if (( gone )); then
        __scripts_prompt_append segment "$__scripts_prompt_red" "gone"
    fi
    __scripts_prompt_append segment "$__scripts_prompt_green" "+" "$staged"
    __scripts_prompt_append segment "$__scripts_prompt_yellow" "!" "$unstaged"
    __scripts_prompt_append segment "$__scripts_prompt_cyan" "?" "$untracked"
    __scripts_prompt_append segment "$__scripts_prompt_red" "=" "$conflicted"
    __scripts_prompt_append segment "$__scripts_prompt_yellow" '$' "$stashed"
    if [[ -n "$operation" ]]; then
        __scripts_prompt_append segment "$__scripts_prompt_red$__scripts_prompt_bold" "[${operation}]"
    fi

    printf '%s' "${segment%" "}"
}

__scripts_set_prompt() {
    local exit_code=$?
    local git_info=""
    git_info="$(__scripts_prompt_git)"

    local prompt_char
    if (( exit_code == 0 )); then
        prompt_char="${__scripts_prompt_green}➜${__scripts_prompt_reset}"
    else
        prompt_char="${__scripts_prompt_red}✗${__scripts_prompt_reset}"
    fi

    # \w is $PWD with $HOME abbreviated as ~. Keep the full path from $HOME.
    PROMPT_DIRTRIM=0
    PS1="${__scripts_prompt_cyan}\w${__scripts_prompt_reset}${git_info} ${prompt_char} "
}

if [[ -z "${__SCRIPTS_PROMPT_LOADED:-}" ]]; then
    if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
        PROMPT_COMMAND=(__scripts_set_prompt "${PROMPT_COMMAND[@]}")
    else
        # shellcheck disable=SC2178,SC2128
        PROMPT_COMMAND="__scripts_set_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    fi
    __SCRIPTS_PROMPT_LOADED=1
fi

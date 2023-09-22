#!/bin/bash
#
# Simple script for executing answers from ChatGPT as Bash commands.

function __prepare_prompt() {
  local command="$1"
  local shell="$2"
  local context="$3"

  local prompt=""

  if [ "${shell}" == "none" ]; then
    prompt="${command}"
  else
    prompt="Write a one-liner ${shell} code snippet to ${command}"
    prompt+=", in the current working directory. "
    prompt+="Assume there is no need to provide any arguments. "
    prompt+="The code should contain no comments, no descriptions, no examples, "
    prompt+="no explanations, no markdown."
  fi

  if [ ! -z "${context}" ]; then
    prompt+="\n\nContext:\n\`\`\`\n${context}\n\`\`\`"
  fi

  if [ "${PROMPTSH_DEBUG}" == "1" ]; then
    echo -en "\033[3mPrompt:\n" 1>&2
    echo -n "${prompt}" 1>&2
    echo -en "\033[0m\n\n" 1>&2
  fi

  echo "${prompt}"
}

function __execute() {
  local prompt="$1"
  local shell="$2"
  local is_interactive="$3"

  local completion

  local completion_hash

  completion_hash="$( \
    echo "${prompt}" \
    | md5sum \
    | cut \
      -d " " \
      -f 1 \
  )"

  local completion_cache_dir="${TMPDIR:-/tmp}/promptsh/cache/completions"
  local completion_cache_path="${completion_cache_dir}/${completion_hash}"

  mkdir -p "${completion_cache_dir}"

  if [ -f "${completion_cache_path}" ]; then
    completion="$(cat "${completion_cache_path}")"

    if [ "${PROMPTSH_DEBUG}" == "1" ]; then
      echo -en "\033[33mGot completion from cache at key ${completion_hash}:\n\033[1m${completion}\033[0m\n\n" 1>&2
    fi
  else
    local model="gpt-3.5-turbo"

    local response

    local prompt_json_value
    prompt_json_value="$(echo -n "${prompt}" | jq -Rsa '.')"

    post_data='
    {
      "model": "'"${model}"'",
      "temperature": 0,
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": '"${prompt_json_value}"'
        }
      ]
    }'

    response="$( \
      curl \
        --silent \
        --request "POST" \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer ${OPENAI_TOKEN}" \
        --data "${post_data}" \
        "https://api.openai.com/v1/chat/completions" \
    )"

    if [ "${PROMPTSH_DEBUG}" == "1" ]; then
      echo -en "\033[31mCompletion was not found in cache\n\nRequest to OpenAI API:\n\033[1m" 1>&2
      echo -n "${post_data}" 1>&2
      echo -en "\033[0m\n\nResponse from OpenAI API:\n\033[1m" 1>&2
      echo -n "${response}" 1>&2
      echo -en "\033[0m\n\n" 1>&2
    fi

    completion=$(echo "$response" | jq -r '.choices[0].message.content')

    if [ "${completion}" == "null" ]; then
      error=$(echo "$response" | jq -r '.error.message')

      if [ "${error}" == "null" ]; then
        echo -e "\033[31mUnknown error occured, you can retry run with PROMPTSH_DEBUG=1\033[0m" 1>&2
      else
        echo 1>&2
        echo -e "\033[31m${error}\033[0m" 1>&2
        echo 1>&2
      fi

      exit 1
    fi

    echo "${completion}" > "${completion_cache_path}"
  fi

  if ! $is_interactive; then
    echo -en "\033[32m${completion}\033[0m\n\n" 1>&2
  fi

  if [ "${shell}" == "none" ]; then
    echo "${completion}"
  else
    if $is_interactive; then
      PS1='$ '

      read \
        -er \
        -i "echo '${completion}' | ${shell}" \
        -p "${PS1@P}" \
        input

      if [ -n "${input}" ]; then
        eval "${input}" \
        && builtin history -s "${input}"
      fi
    else
      echo "${completion}" | $shell
    fi
  fi
}

function __print_help() {
  echo
  grep '^#.*' "${SOURCE_PATH}" | tail -n +3 | cut -c 3-
  echo
  echo "  Commands:"
  echo
  echo "      -h | --help                       Prints this message."
  echo "      --update                          Updates this script to the latest."
  echo
  echo "  Parameters:"
  echo
  echo "      -c | --command        [prompt]    Given prompt."
  echo "      -i | --interactive                Let user edit received command."
  echo "      -s | --stdin                      Enables reading context from \`stdin\`"
  echo "      -x | --shell          [shell]     Specifies shell for execution of command."
  echo "                                        Use \`none\` for non-code prompts."
  echo "                                        Default: \`bash\`"
  echo
}

set -e

SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

if [ $# -eq 0 ]; then
  __print_help
  exit 0
fi

command=""
is_interactive=false
is_reading_stdin=false
is_need_update=false
shell="bash"

while [ $# -gt 0 ]; do
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    __print_help
    exit 0
  elif [ "$1" == "-c" ] || [ "$1" == "--command" ]; then
    command="$2"
    shift
    shift
  elif [ "$1" == "-x" ] || [ "$1" == "--shell" ]; then
    shell="$2"
    shift
    shift
  elif [ "$1" == "-i" ] || [ "$1" == "--interactive" ]; then
    is_interactive=true
    shift
  elif [ "$1" == "-s" ] || [ "$1" == "--stdin" ]; then
    is_reading_stdin=true
    shift
  elif [ "$1" == "--update" ]; then
    is_need_update=true
    shift
  fi
done

if $is_need_update; then
  curl -fsSL "https://raw.githubusercontent.com/Danand/promptsh/main/install.sh" \
  | bash

  exit 0
fi

context=""

if $is_reading_stdin; then
  context="$(cat)"
fi

prompt="$( \
  __prepare_prompt \
  "${command}" \
  "${shell}" \
  "${context}" \
)"

__execute \
  "${prompt}" \
  "${shell}" \
  "${is_interactive}"

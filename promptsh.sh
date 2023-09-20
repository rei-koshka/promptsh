#!/bin/bash
#
# Simple script for executing answers from ChatGPT as Bash commands.

function __prepare_prompt() {
  local command="$1"

  local prompt="Write a compact Bash code snippet to ${command}"

  prompt+=", in the current working directory. "
  prompt+="Assume there is no need to provide any arguments or read from stdin. "
  prompt+="The code should not contain comments, descriptions, examples, "
  prompt+="explanations, markdown, shebang, "
  prompt+="or any code for reading arguments or stdin."

  if [ "${PROMPTSH_DEBUG}" == "1" ]; then
    echo -en "\033[3mPrompt:\n${prompt}\033[0m\n\n" 1>&2
  fi

  echo "${prompt}"
}

function promptsh() {
  local command="$@"

  local prompt
  prompt="$(__prepare_prompt "${command}")"

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

    response="$( \
      curl \
        --silent \
        --request "POST" \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer ${OPENAI_TOKEN}" \
        --data \
          '{
            "model": "'"${model}"'",
            "temperature": 0,
            "max_tokens": 1024,
            "messages": [
              {
                "role": "user",
                "content": "'"${prompt}"'"
              }
            ]
          }' \
        "https://api.openai.com/v1/chat/completions" \
    )"

    if [ "${PROMPTSH_DEBUG}" == "1" ]; then
      echo -en "\033[31mCompletion was not found in cache, got response from OpenAI API\n\033[1m${response}\033[0m\n\n" 1>&2
    fi

    completion=$(echo "$response" | jq -r '.choices[0].message.content')

    echo "${completion}" > "${completion_cache_path}"
  fi

  echo -en "\033[32m${completion}\033[0m\n\n" 1>&2

  echo "${completion}" | bash
}

set -e

promptsh "$@"

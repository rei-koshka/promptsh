#!/bin/bash
#
# Installs `promptsh` from CWD at cloned repo.

set -e

is_sudo_present=true
sudo > /dev/null 2>&1 || is_sudo_present=false

if [ "$(id -u)" -ne 0 ]; then
  if $is_sudo_present; then
    echo 1>&2
    echo "Installation requires root privileges." 1>&2
    echo "Please run it again with \`sudo\`" 1>&2
    echo 1>&2

    exit 1
  else
    is_running_as_admin=true
    touch "${HOME}/../.elevated" > /dev/null 2>&1 || is_running_as_admin=false

    if ! $is_running_as_admin; then
      echo 1>&2
      echo "Installation requires administrator privileges." 1>&2
      echo "Please run it again as administrator." 1>&2
      echo 1>&2

      exit 1
    fi
  fi
fi

if [ -z "${OPENAI_TOKEN}" ]; then
  echo "Installation requires OpenAI API key." 1>&2
  echo 1>&2
  echo "You can obtain a new one here:" 1>&2
  echo "https://platform.openai.com/account/api-keys" 1>&2
  echo 1>&2
  echo "Then, you should set environment variable OPENAI_TOKEN to the value of OpenAI API key." 1>&2
  echo 1>&2
  echo "How to to that (MacOS):" 1>&2
  echo "echo 'export OPENAI_TOKEN=\"your-key-here\"' >> ~/.zshrc && source ~/.zshrc" 1>&2
  echo 1>&2
  echo "How to to that (MINGW64):" 1>&2
  echo "echo 'export OPENAI_TOKEN=\"your-key-here\"' >> ~/.bash_profile && source ~/.bash_profile" 1>&2
  echo 1>&2
  echo "How to to that (Linux):" 1>&2
  echo "echo 'export OPENAI_TOKEN=\"your-key-here\"' >> ~/.bashrc && source ~/.bashrc" 1>&2
  echo 1>&2

  exit 1
fi

executable_name="promptsh"

source_filename="${executable_name}.sh"
source_path="$(pwd)/${source_filename}"

installation_dir="/usr/local/bin"

if [ ! -d "${installation_dir}" ]; then
  installation_dir="/usr/bin"
fi

installation_path="${installation_dir}/${executable_name}"

if [ ! -f "${source_path}" ]; then
  curl \
    -fsSL \
    "https://raw.githubusercontent.com/Danand/promptsh/main/${source_filename}" \
    -o "${source_path}"
fi

chmod +x "${source_path}"

rm -f "${installation_path}"

ln -s "${source_path}" "${installation_path}"

echo "Successfully installed \`${executable_name}\` to \`${installation_dir}\`"

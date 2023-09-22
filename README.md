# **Prompt** **Sh**ell

_aka_ `promptsh`

Simple script for executing answers from ChatGPT as Bash commands.

Written in pure Bash, **no** dependencies required.

## Prerequisites

1. [**OpenAI API** key](https://platform.openai.com/account/api-keys).
2. Set environment variable `OPENAI_TOKEN`:
   - **MacOS**:

   ```bash
   echo 'export OPENAI_TOKEN="your-key-here"' >> ~/.zshrc && source ~/.zshrc
   ```

   - **MINGW64**:

   ```bash
   echo 'export OPENAI_TOKEN="your-key-here"' >> ~/.bash_profile && source ~/.bash_profile
   ```

   - **Ubuntu** and other Linux systems:

   ```bash
   echo 'export OPENAI_TOKEN="your-key-here"' >> ~/.bashrc && source ~/.bashrc
   ```

## How to install

- **MINGW64**:
  1. Run **Git Bash**/**MINGW64** as Administrator.
  2. Run the following command:

     ```bash
     curl -fsSL "https://raw.githubusercontent.com/Danand/promptsh/main/install.sh" \
     | bash
     ```

- Other terminals (requires `sudo`):
  1. Launch Terminal as usual.
  2. Run the following command:

     ```bash
     curl -fsSL "https://raw.githubusercontent.com/Danand/promptsh/main/install.sh" \
     | sudo OPENAI_TOKEN="${OPENAI_TOKEN}" bash
     ```

  3. You will be prompted for superuser password.

## How to use

```bash
$ promptsh --help

Simple script for executing answers from ChatGPT as Bash commands.

  Commands:

      -h | --help                       Prints this message.
      --update                          Updates this script to the latest.

  Parameters:

      -c | --command        [prompt]    Given prompt.
      -x | --shell          [shell]     Specifies shell for execution of command.
      -s | --stdin                      Enables reading context from `stdin`
      -i | --interactive                Let user edit received command.
                                        Use `none` for non-code prompts.
                                        Default: `bash`
```

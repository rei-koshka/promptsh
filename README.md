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
     curl -fsSL "https://raw.githubusercontent.com/Danand/promptsh/main/install.sh" | bash
     ```

- Other terminals (requires `sudo`):
  1. Launch Terminal as usual.
  2. Run the following command:

     ```bash
     curl -fsSL "https://raw.githubusercontent.com/Danand/promptsh/main/install.sh" | sudo bash
     ```

  3. You will be prompted for superuser password.

## How to use

Just type commands prepending with `promptsh`:

```log
$ promptsh init repo
git init

Initialized empty Git repository in /home/user/promptsh/.git/

$ promptsh add changes and commit
git add . && git commit -m "Commit changes"

[main (root-commit) 15e69a8] Commit changes
 3 files changed, 154 insertions(+)
 create mode 100644 README.md
 create mode 100755 install.sh
 create mode 100755 promptsh.sh
```

# envs

This is my git-friendly manager for handling Python virtual environments. It lets you easily create, activate, and update your environments. It keeps track of package dependencies with `venv-freeze` using `$VENV_DIR/<env_name>/requirements.txt`.

## Examples

- Creating a new environment: `venv-create newenv`
- Activating an environment: `venv-activate myenv`
- Freezing an environment's requirements: `venv-freeze myenv`
- Initializing all environments on another system: `venv-init`

## Setup

- Fork the repository by visiting: https://github.com/skelouse/envs/fork

- Clone your forked repository. 
This command will clone the repository into the default directory: `$HOME/envs`

```bash
git clone git@github.com:<your_username>/envs.git $HOME/envs
```

- Add this line to your shell configuration file (.bashrc, .zshrc, etc.):

```
source "$HOME/envs/venv.sh"
```

## Scripts

### venv.sh

This script provides several functions to manage python virtual environments:

- `venv-activate <env_name>`: Activates the specified virtual environment.
- `venv-freeze [env_name]`: Freezes the current environment's packages into a `requirements.txt` file. If no environment is specified, it uses the currently active one.
- `venv-create <env_name>`: Creates a new virtual environment with the specified name.
- `venv-init`: After a clone will iterate environments `$VENV_DIR/<env_name/requirements.txt` and install the dependencies for those environments

- After venv-freeze, track the changes with Git:
  ```bash
  cd "$VENV_DIR/<env_name>"
  git add requirements.txt
  git commit -m "Update dependencies for <env_name>"
  git push origin master
  ```

## Environment Variables
These scripts use the following environment variables, which you can customize:

- `VENV_PIP` (default: "pip"): The pip command to use.
- `VENV_PYTHON` (default: "python3"): The Python command for creating virtual environments.
- `VENV_DIR` (default: "$HOME/envs"): The directory where virtual environments are stored.


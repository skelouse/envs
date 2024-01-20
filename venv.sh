#!/bin/bash

# Default values for environment variables
: ${VENV_PIP:="pip"}
: ${VENV_PYTHON:="python3"}
: ${VENV_DIR:="$HOME/envs"}

function venv-activate() {
    if [[ -z "$1" ]]; then
        echo "Usage: venv-activate <env_name>"
        return 1
    fi

    # Deactivate current virtual environment if one is active
    if [[ -n $(type -t deactivate) && $(type -t deactivate) == 'function' ]]; then
        deactivate
    fi

    ENV_PATH="$VENV_DIR/$1/bin/activate"

    if [[ -f "$ENV_PATH" ]]; then
        source "$ENV_PATH"
    else
        echo "Virtual environment not found."
        return 1
    fi
}

function venv-freeze() {
    local env_name=$1
    local env_activated=false
    local env_was_previously_active=false
    local env_path=""

    if [[ -n "$VIRTUAL_ENV" ]]; then
        env_path="$VIRTUAL_ENV"
        env_name=$(basename "$VIRTUAL_ENV")
        echo "Using currently activated environment: $env_name"
        env_was_previously_active=true
    elif [[ -n "$env_name" ]]; then
        env_path="$HOME/bash/envs/$env_name"
        venv-activate "$env_name" && env_activated=true
    else
        echo "Usage: venv-freeze [env_name]"
        echo "No environment is currently activated, and no environment name was provided."
        return 1
    fi

    if [[ $env_activated == true ]] || [[ $env_was_previously_active == true ]]; then
        $VENV_PIP freeze > "$env_path/requirements.txt"
        echo "Requirements for $env_name have been frozen."

        if [[ $env_activated == true ]] && [[ $env_was_previously_active == false ]]; then
            deactivate
        fi
    else
        echo "Failed to activate the environment $env_name."
        return 1
    fi
}


_venv_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local envs=$(ls -d $VENV_DIR/*/ | xargs -n 1 basename)
    COMPREPLY=($(compgen -W "${envs}" -- ${cur}))
}

complete -F _venv_complete venv-activate
complete -F _venv_complete venv-freeze


function venv-create() {
    if [[ -z "$1" ]]; then
        echo "Usage: venv-create <env_name>"
        return 1
    fi

    local env_name=$1
    local env_path="$VENV_DIR/$env_name"

    if [[ -d "$env_path" ]]; then
        echo "Virtual environment $env_name already exists."
        return 1
    fi

    $VENV_PYTHON -m venv "$env_path"

    if [[ -d "$env_path" ]]; then
        echo "Virtual environment $env_name created."
        venv-activate "$env_name"
    else
        echo "Failed to create the virtual environment $env_name."
        return 1
    fi
}

function venv-init() {
    if [[ -f "$VENV_DIR/init.sh" ]]; then
        echo "Initializing virtual environments..."
        setup_venv() {
            local env_dir=$1
            local env_name=$(basename "$env_dir")

            echo "Setting up virtual environment for $env_name"

            # Create virtual environment if it doesn't exist
            if [[ ! -d "$env_dir/bin" ]]; then
                python3 -m venv "$env_dir"
            fi

            # Activate the virtual environment
            source "$env_dir/bin/activate"

            # Check if requirements.txt exists and install packages
            if [[ -f "$env_dir/requirements.txt" ]]; then
                pip install -r "$env_dir/requirements.txt"
            else
                echo "No requirements.txt found for $env_name, skipping package installation."
            fi

            # Deactivate the virtual environment
            deactivate
        }

        # Export the setup_venv function so it can be used in subshells
        export -f setup_venv

        # Find each directory in VENV_DIR and call setup_venv on it
        find "$VENV_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.git' -exec bash -c 'setup_venv "$0"' {} \;

        echo "All virtual environments have been set up."
    else
        echo "init.sh script not found in $VENV_DIR"
        return 1
    fi
}
#!/bin/bash

set -e

# Get the parent directory of the script root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
echo "Script root: $SCRIPT_DIR"
echo "Parent directory: $PARENT_DIR"

# Find all requirements.txt files recursively
REQUIREMENTS_FILES=($(find "$PARENT_DIR" -name "requirements.txt" -type f))

echo "Found ${#REQUIREMENTS_FILES[@]} requirements.txt files."
# echo "${REQUIREMENTS_FILES[@]}"

# Create venv in .venv at the parent directory
VENV_PATH="$PARENT_DIR/.venv"

echo "Virtual environment path: $VENV_PATH"

echo "Checking for existing virtual environment..."

if [ -d "$VENV_PATH" ]; then
    echo "Found existing virtual environment at $VENV_PATH"
else
    echo "Creating virtual environment at $VENV_PATH"
    python -m venv "$VENV_PATH"
fi

# Activate the venv
source "$VENV_PATH/bin/activate"

# Install all requirements.txt files with confirmation
for ((i=0; i<${#REQUIREMENTS_FILES[@]}; i++)); do
    REQ="${REQUIREMENTS_FILES[$i]}"
    echo "File $((i+1))/${#REQUIREMENTS_FILES[@]}: $REQ"
    
    read -p "Install requirements from $REQ? (y/n): " CONFIRM
    if [ "$CONFIRM" = "y" ]; then
        pip install -r "$REQ"
        echo "Installed requirements from $REQ"
    else
        echo "Skipped $REQ"
    fi

    echo "----------------------------------------"
    echo "Current pip version: $(pip --version)"
done

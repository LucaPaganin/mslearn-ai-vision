#!/bin/bash

# Script to recursively delete .env files with git rm and recreate them

# Set the repository root (current directory)
REPO_ROOT=$(pwd)

echo -e "\e[32mStarting cleanup of .env files in repository: $REPO_ROOT\e[0m"

# Find all .env files recursively
ENV_FILES=($(find "$REPO_ROOT" -name "*.env" -type f))

if [ ${#ENV_FILES[@]} -eq 0 ]; then
    echo -e "\e[33mNo .env files found in the repository.\e[0m"
else
    echo -e "\e[36mFound ${#ENV_FILES[@]} .env file(s):\e[0m"
    for FILE in "${ENV_FILES[@]}"; do
        echo "  $FILE"
    done
    
    # Remove each .env file using git rm
    for FILE in "${ENV_FILES[@]}"; do
        echo -e "\e[33mRemoving $FILE with git rm...\e[0m"
        if git rm --cached "$FILE"; then
            echo -e "  \e[32m✓ Successfully removed $FILE\e[0m"
        else
            echo -e "  \e[31m✗ Failed to remove $FILE with git rm\e[0m"
        fi
    done
fi

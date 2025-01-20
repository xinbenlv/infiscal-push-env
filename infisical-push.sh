#!/bin/bash

# Check if .env file is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <path-to-env-file> [additional infisical parameters...]"
    echo "Example: $0 .env --env=prod --silent"
    exit 1
fi

ENV_FILE="$1"
shift  # Remove the first argument (ENV_FILE) from the arguments list

# Check if the file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: File $ENV_FILE does not exist"
    exit 1
fi

# Read .env file, ignore comments and empty lines
# Build the infisical command with additional parameters
COMMAND="infisical secrets set $*"  # Add any additional parameters
DISPLAY_COMMAND="infisical secrets set $*"
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Add to command if it's a valid VAR=value line
    if [[ "$line" =~ ^([[:alnum:]_]+)=.+ ]]; then
        VAR_NAME="${BASH_REMATCH[1]}"
        COMMAND="$COMMAND $line"
        DISPLAY_COMMAND="$DISPLAY_COMMAND $VAR_NAME=*****"
    fi
done < "$ENV_FILE"

# Execute the command if we have variables to set
if [ "$COMMAND" != "infisical secrets set $*" ]; then
    echo "Executing: $DISPLAY_COMMAND"
    eval "$COMMAND"
else
    echo "No valid environment variables found in $ENV_FILE"
    exit 1
fi

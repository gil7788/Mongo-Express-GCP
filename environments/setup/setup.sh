#!/bin/bash

# [TODO add cmds status checks, and error handling and improve system messages]

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Make deploy_function.sh executable and run it
chmod +x "$SCRIPT_DIR/deploy_cloudbuild_trigger.sh"
"$SCRIPT_DIR/deploy_functions.sh"

# Make create_user_services.sh executable and run it
chmod +x "$SCRIPT_DIR/create_user_services.sh"
"$SCRIPT_DIR/create_user_services.sh"

echo "Setup complete."
exit 0

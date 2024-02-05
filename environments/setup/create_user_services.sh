#!/bin/bash

# Determine the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_PATH="$SCRIPT_DIR/../config.sh"

echo "Loading environment variables..."
if [ -f "$CONFIG_PATH" ]; then
    source "$CONFIG_PATH"
    echo "Environment variables loaded successfully."
else
    echo "config.sh not found"
    exit 1
fi

# Function to create and grant roles to a service account
create_and_grant() {
    local service_account_name=$1
    local display_name=$2
    local role=$3
    local project_id=$4

    # Create service account
    gcloud iam service-accounts create "$service_account_name" \
        --display-name "$display_name" \
        --project "$project_id"

    # Grant role to the service account
    gcloud projects add-iam-policy-binding "$project_id" \
        --member "serviceAccount:${service_account_name}@${project_id}.iam.gserviceaccount.com" \
        --role "$role"
}

# Ensure the Compute Engine API is enabled
echo "Ensuring Compute Engine API is enabled..."
gcloud services enable compute.googleapis.com --project "$PROJECT_ID"

# Create Cloud Run service account
create_and_grant "cloud-run-sa" "Cloud Run Service Account" "roles/run.admin" "$PROJECT_ID"

# Set up Cloud Build service account
CLOUD_BUILD_SA="$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"

# Grant Cloud Build service account necessary roles
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "serviceAccount:$CLOUD_BUILD_SA" \
    --role "roles/run.admin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "serviceAccount:$CLOUD_BUILD_SA" \
    --role "roles/iam.serviceAccountUser"

echo -e "Service accounts and permissions are set up.\n\n"

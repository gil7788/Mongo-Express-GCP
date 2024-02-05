#!/bin/bash

# Determine the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_PATH="$SCRIPT_DIR/../config.sh"

# Load environment variables
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

# Additional function to grant multiple roles to a service account
grant_roles() {
    local service_account_email=$1
    local project_id=$2
    shift 2
    local roles=("$@")

    for role in "${roles[@]}"; do
        gcloud projects add-iam-policy-binding "$project_id" \
            --member "serviceAccount:$service_account_email" \
            --role "$role"
    done
}

# Ensure the Compute Engine, Artifact Registry, and Cloud Run APIs are enabled
echo "Ensuring required APIs are enabled..."
gcloud services enable compute.googleapis.com artifactregistry.googleapis.com run.googleapis.com --project "$PROJECT_ID"

# Create Cloud Run service account
create_and_grant "cloud-run-sa" "Cloud Run Service Account" "roles/run.admin" "$PROJECT_ID"

# Ensure Cloud Run service account can pull images from Artifact Registry
CLOUD_RUN_SA_EMAIL="${PROJECT_ID}@appspot.gserviceaccount.com"
grant_roles "$CLOUD_RUN_SA_EMAIL" "$PROJECT_ID" "roles/artifactregistry.reader"

# Setup Cloud Build service account
CLOUD_BUILD_SA="$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"

# Define roles for Cloud Build service account
ROLES=("roles/run.admin" "roles/iam.serviceAccountUser" "roles/artifactregistry.admin" "roles/storage.admin")

# Grant defined roles to Cloud Build service account
grant_roles "$CLOUD_BUILD_SA" "$PROJECT_ID" "${ROLES[@]}"

echo -e "Service accounts and permissions are set up.\n\n"
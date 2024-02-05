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

echo "Setting GCP project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID || { echo "Failed to set project ${PROJECT_ID}"; exit 1; }

# Check if necessary variables are set
MISSING_VARS=0
check_var() {
  if [ -z "${!1}" ]; then
    echo "Error: $1 is not set"
    MISSING_VARS=1
  fi
}

check_var "PROJECT_ID"
check_var "GCP_PROJECT_NAME"
check_var "GITHUB_REPOSITORY_OWNER"
check_var "GITHUB_REPOSITORY_NAME"
check_var "FUNCTION_NAME"
check_var "GCP_REGION"
check_var "SERVICE_ACCOUNT_EMAIL"
check_var "GCP_MIRRORED_REPOSITORY_NAME"

if [ $MISSING_VARS -ne 0 ]; then
    exit 1
fi

# Retrieve the project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
echo "Project Number: $PROJECT_NUMBER"

# Define secret name and value
SECRET_NAME="webhook-trigger-secret-${PROJECT_ID}"
SECRET_VALUE=$(openssl rand -base64 32)
echo "Secret Name: $SECRET_NAME"
echo "Secret Value: [HIDDEN]"

# Create the secret in Secret Manager
echo "Creating secret in Secret Manager..."
gcloud secrets create $SECRET_NAME --replication-policy="automatic"
echo "Secret created successfully."

# Add the secret version
echo "Adding secret version..."
echo -n $SECRET_VALUE | gcloud secrets versions add $SECRET_NAME --data-file=-
echo "Secret version added successfully."

# Grant the Cloud Build service account access to the secret
CLOUDBUILD_SA="service-${PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
echo "Granting Cloud Build service account access to the secret..."
gcloud secrets add-iam-policy-binding $SECRET_NAME --member="serviceAccount:${CLOUDBUILD_SA}" --role="roles/secretmanager.secretAccessor"
echo "Access granted successfully."

echo "Deploying Cloud Function $FUNCTION_NAME..."
gcloud functions deploy $FUNCTION_NAME \
    --runtime nodejs18 \
    --trigger-http \
    --allow-unauthenticated \
    --set-env-vars PROJECT_ID=$PROJECT_ID,GCP_REGION=$GCP_REGION,GCP_CLOUD_RUN_SERVICE_NAME=$GCP_CLOUD_RUN_SERVICE_NAME,GCP_CONTAINER_REGISTRY_REPOSITORY_NAME=$GCP_CONTAINER_REGISTRY_REPOSITORY_NAME,DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME,GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER,GITHUB_REPOSITORY_NAME=$GITHUB_REPOSITORY_NAME,GCP_MIRRORED_REPOSITORY_NAME=$GCP_MIRRORED_REPOSITORY_NAME \
    --source ./environments/setup/nodejs_cloud_functions \
    --entry-point triggerCloudBuild \
    --region $GCP_REGION
echo -e "Cloud Function deployed successfully.\n\n"

# The following section is commented out as the function itself handles triggering Cloud Build
# based on the logic within it and does not require a separate Cloud Build trigger.
# gcloud beta builds triggers create webhook \
#     --name="$MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID" \
#     --description="Webhook trigger for external invocation" \
#     --region="$GCP_REGION" \
#     --secret="$SECRET_URI" || echo "Failed to create Cloud Build Webhook Trigger"
# echo "Cloud Build Webhook Trigger created successfully."

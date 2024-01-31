#!/bin/bash

echo "Loading environment variables..."
if [ -f ./environments/config.sh ]; then
    source ./environments/config.sh
    echo "Environment variables loaded successfully."
else
    echo "config.sh not found"
    exit 1
fi

echo "Setting GCP project to $PROJECT_ID..."
# Set the correct GCP project
gcloud config set project $PROJECT_ID --verbosity=debug

# Check if necessary variables are set
MISSING_VARS=0
if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID is not set"
    MISSING_VARS=1
fi
if [ -z "$MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID" ]; then
    echo "Error: MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID is not set"
    MISSING_VARS=1
fi
if [ -z "$GCP_PROJECT_NAME" ]; then
    echo "Error: GCP_PROJECT_NAME is not set"
    MISSING_VARS=1
fi
if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
    echo "Error: GITHUB_REPOSITORY_OWNER is not set"
    MISSING_VARS=1
fi
if [ -z "$GITHUB_REPOSITORY_NAME" ]; then
    echo "Error: GITHUB_REPOSITORY_NAME is not set"
    MISSING_VARS=1
fi
if [ -z "$FUNCTION_NAME" ]; then
    echo "Error: FUNCTION_NAME is not set"
    MISSING_VARS=1
fi
if [ -z "$GCP_REGION" ]; then
    echo "Error: GCP_REGION is not set"
    MISSING_VARS=1
fi
if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
    echo "Error: SERVICE_ACCOUNT_EMAIL is not set"
    MISSING_VARS=1
fi

if [ $MISSING_VARS -ne 0 ]; then
    exit 1
fi


echo "Deploying Cloud Function $FUNCTION_NAME..."
gcloud functions deploy $FUNCTION_NAME \
    --runtime nodejs18 \
    --trigger-http \
    --allow-unauthenticated \
    --set-env-vars PROJECT_ID=$PROJECT_ID,GCP_REGION=$GCP_REGION,GCP_CLOUD_RUN_SERVICE_NAME=$GCP_CLOUD_RUN_SERVICE_NAME \
    --source ./environments/setup/nodejs_cloud_functions \
    --entry-point triggerCloudBuild \
    --region $GCP_REGION \
    --verbosity=debug
echo "Cloud Function $FUNCTION_NAME deployed."

echo "Setting IAM policy bindings..."
# Grant Cloud Build permissions
if gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/cloudbuild.builds.editor" \
    --verbosity=debug; then
    echo "Cloud Build permissions set successfully."
else
    echo "Failed to set Cloud Build permissions."
    exit 1
fi

# Grant Cloud Run permissions
if gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/run.admin" \
    --verbosity=debug; then
    echo "Cloud Run permissions set successfully."
else
    echo "Failed to set Cloud Run permissions."
    exit 1
fi

echo "Creating Cloud Build Trigger..."
# Example of creating a simple trigger. Modify according to your requirements.
if gcloud beta builds triggers create github \
    --name=$MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID \
    --repo-name=$GITHUB_REPOSITORY_NAME \
    --repo-owner=$GITHUB_REPOSITORY_OWNER \
    --branch-pattern="^master$" \
    --build-config="cloudbuild.yaml"; then
    echo "Cloud Build Trigger created successfully."
else
    echo "Failed to create Cloud Build Trigger."
    exit 1
fi

echo "Script execution completed."

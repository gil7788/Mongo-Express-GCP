# Description: This file contains the configuration variables for the Terraform Cloud (TFC) and Google Cloud Platform (GCP) environments.

# Terraform Cloud (TFC)
TERRAFORM_ORGANIZATION_NAME="My-TFC-Tutorial"
TERRAFORM_ORGANIZATION_ID="org-Qzi2vYQye5iErTKo"
TFC_MASTER_WORKSPACE_NAME="Mongo-Express-GCP"
TFC_MASTER_WORKSPACE_ID="ws-KNRoQeYM2xCRJxUx"
TFC_PROD_WORKSPACE_NAME="Mongo-Express-GCP-Production"
TFC_PROD_WORKSPACE_ID="ws-RP3cJ37AVaRQ9nJm"

# Google Cloud Platform (GCP)
GCP_PROJECT_NAME="mongo-express"
PROJECT_ID="mongo-express-412515"
GCP_REGION="us-west2"
GCP_ZONE="us-west2-a"

# GitHub
GITHUB_REPOSITORY_OWNER="gil7788"
GITHUB_REPOSITORY_NAME="Mongo-Express-GCP"
GITHUB_REPOSITORY_URL="https://github.com/${GITHUB_REPOSITORY_OWNER}/${GITHUB_REPOSITORY_NAME}"
MASTER_BRANCH_NAME="master"
PROD_BRANCH_NAME="prod"

## Resources
GCP_MIRRORED_REPOSITORY_NAME=$(echo "github_${GITHUB_REPOSITORY_OWNER}_${GITHUB_REPOSITORY_NAME}" | tr '[:upper:]' '[:lower:]') # Ensure lower case for the mirrored repository name
GCP_CLOUD_RUN_SERVICE_NAME="mongo-express-service"
GCP_CONTAINER_REGISTRY_REPOSITORY_NAME="mongo-express-repo"

# Docker
DOCKER_IMAGE_NAME="mongo-express-image"

# Setup
## Define the Cloud Function name
FUNCTION_NAME="trigger-cloudbuild-deployer-id"
MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID="master-branch-cloudbuild-trigger-id"

# Service Accounts
SERVICE_ACCOUNT_EMAIL="${GCP_PROJECT_NAME}-service-account@${PROJECT_ID}.iam.gserviceaccount.com"

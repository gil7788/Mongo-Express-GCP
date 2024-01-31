# Managing infrastructure as code with Terraform, Cloud Build, and GitOps

This is the repo for the [Managing infrastructure as code with Terraform, Cloud Build, and GitOps](https://cloud.google.com/solutions/managing-infrastructure-as-code) tutorial. This tutorial explains how to manage infrastructure as code with Terraform and Cloud Build using the popular GitOps methodology. 

## Configuring your **dev** environment

Just for demostration, this step will:
 1. Configure an apache2 http server on network '**dev**' and subnet '**dev**-subnet-01'
 2. Open port 80 on firewall for this http server 

```bash
cd ../environments/dev
terraform init
terraform plan
terraform apply
terraform destroy
```

## Promoting your environment to **production**

Once you have tested your app (in this example an apache2 http server), you can promote your configuration to prodution. This step will:
 1. Configure an apache2 http server on network '**prod**' and subnet '**prod**-subnet-01'
 2. Open port 80 on firewall for this http server 

```bash
cd ../prod
terraform init
terraform plan
terraform apply
terraform destroy
```

## Setup
This section explains how to set up `terraform` config in this repository with Google Cloud Platform (GCP).
### Setup Github
Create a Github repositroy with the following branches:
- `master`
- `prod`

### Setup GCP
- Enable Google Cloud API's
    - `gcloud config set project <GCP-project_id>`
    - `gcloud services enable cloudbuild.googleapis.com compute.googleapis.com`
- Create a Cloud Bucket
    - `CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
    --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"`

    - `gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$CLOUDBUILD_SA --role roles/editor`
    Where $PROJECT_ID is GCP project id.`
- Connect Cloud Build with Github Repository
    - Go to the GitHub Marketplace page for the Cloud Build app: [Link](https://github.com/marketplace/google-cloud-build)

### Cloud Build Setup Instructions
- 1. Enable Cloud Build and Artifact Registry APIs

Execute the following command to enable necessary services in your GCP project:

```bash
gcloud services enable \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    --project=<PROJECT-ID>
```

- 2. Create a Shell Script (run.sh)
Create a script named run.sh that will define your build or deployment commands.

- 3. Create a Dockerfile
Prepare a Dockerfile to define the steps for creating your Docker image.

- 4. Create a New Docker Repository
Use this command to create a Docker repository in the Artifact Registry:
```bash
gcloud artifacts repositories create quickstart-docker-repo \
    --repository-format=docker \
    --location=us-west2 \
    --description="Docker repository"
```

- 5. Verify the Repository Creation
Ensure your repository has been successfully created:

```bash
gcloud artifacts repositories list
```

- 6. Create cloudbuild.yaml
Prepare your cloudbuild.yaml file with the necessary build steps:
```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    script: |
      docker build -t us-west2-docker.pkg.dev/$PROJECT_ID/quickstart-docker-repo/quickstart-image:tag1 .
    automapSubstitutions: true
images:
  - 'us-west2-docker.pkg.dev/<PROJECT-ID>/quickstart-docker-repo/quickstart-image:tag1'
```

- 7. Submit the Build
Trigger the Cloud Build using the following command:
```bash
gcloud builds submit \
    --region=us-west2 --config \
    cloudbuild.yaml
```
These steps will guide you through setting up a Cloud Build process in GCP, including creating a Docker image and storing it in the Artifact Registry. Remember to replace `<PROJECT-ID>` with your actual GCP project ID.

- 8. Ensure running user has Cloud Run Admin IAM Permissions


### GH Repo Mapping
Creating Cloud Build Trigger...
ERROR: (gcloud.beta.builds.triggers.create.github) FAILED_PRECONDITION: Repository mapping does not exist. Please visit https://console.cloud.google.com/cloud-build/triggers;region=global/connect?project=137286199491 to connect a repository to your project
Failed to create Cloud Build Trigger.

### Configure Terraform Files
- Make sure that project name is set correctly in the following files:
    -   `environments/dev/backend.tf`
    -    `environments/dev/terraform.tfvars`
    -    `environments/prod/backend.tf`
    -    `environments/prod/terraform.tfvars`



# Mirror Github Repository to Cloud Source Repository (CSR)
Mirroring a GitHub repository to Cloud Source Repositories (CSR) in Google Cloud Platform (GCP) allows you to maintain a copy of your GitHub repository in Google Cloud. This can be beneficial for integrating with other Google Cloud services, such as Cloud Build. Here’s how to set up a mirror:
Prerequisites

    A Google Cloud Platform account and a project created within it.
    The Cloud Source Repositories API enabled for your project.
    A GitHub repository that you want to mirror.

Steps to Mirror a GitHub Repository
Step 1: Enable Cloud Source Repositories API

    Go to the Google Cloud Console.
    Navigate to the "APIs & Services" dashboard.
    Click "+ ENABLE APIS AND SERVICES".
    Search for "Cloud Source Repositories" and enable it for your project.

Step 2: Mirror the GitHub Repository

    Open Cloud Source Repositories:
        In the Google Cloud Console, navigate to "Source Repositories" within the "Tools" section or search for "Cloud Source Repositories" in the top search bar.

    Start Repository Mirroring:
        Click on "Add repository".
        Choose "Connect external repository", then select your project.
        Click "Continue".

    Select Source Provider:
        Choose GitHub as your source provider. You might be prompted to authorize Google Cloud Platform to access your GitHub account. Follow the on-screen instructions to grant the necessary permissions.

    Choose the Repository to Mirror:
        After authorization, you’ll see a list of your GitHub repositories. Select the repository you wish to mirror.
        Click "Connect Selected Repository".

    Finalize the Mirroring Setup:
        Once connected, Google Cloud Source Repositories will automatically sync the selected GitHub repository. Every push to your GitHub repository will be mirrored in Cloud Source Repositories.

Step 3: Verify the Mirroring

    After setting up the mirror, you can verify it by navigating to Cloud Source Repositories in the Google Cloud Console. You should see your GitHub repository listed there, and it should update automatically whenever changes are pushed to GitHub.

Additional Information

    Automated Builds: With your repository mirrored in Cloud Source Repositories, you can easily set up automated builds in Cloud Build by creating triggers that respond to 

    commits to your mirrored repository.
    Private Repositories: If you’re mirroring a private GitHub repository, ensure that the Google Cloud service account used by Cloud Source Repositories has been granted access to that repository in GitHub.
    Manual Sync: While the mirror should update automatically, you can also trigger a manual sync in Cloud Source Repositories if needed.

Mirroring your GitHub repository to Cloud Source Repositories facilitates a seamless integration with Google Cloud’s developer tools, offering a robust CI/CD pipeline and enhancing your development workflow.


## References
Terrafrom managing infrastructure as code: [Link](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code)
# Terraform Cloud and Google Cloud Platform Setup
 
 Welcome to the Terraform Cloud (TFC) - Google Cloud Platform (GCP) workspace setup guide! This repository contains a Terraform configuration designed to help you set your work with Terraform Cloud (TFC), particularly for Google Cloud Platform (GCP) resources, wih a corresponding github repository.

 ## Prerequisites

 Before you begin, make sure you have the following:

 - A Google Cloud Platform (GCP) account.
 - A Terraform Cloud (TFC) account.
 - A Github Repository
 - Google Cloud SDK, [Installation Guide](https://cloud.google.com/sdk/docs/install)
 - `jq` installed on your machine (for processing JSON files).

 ## Setup
 ### Step 1: Link Terraform Cloud with GitHub Repository

 To get started, you'll need to connect your Terraform Cloud workspace to this GitHub repository:

 1. Log in to your Terraform Cloud account.
 2. Create a new workspace or use an existing one.
 3. Under "Version Control Workflow" choose GitHub and follow the prompts to connect your GitHub account.
 4. Select this repository from the list of repositories.
 5. Configure Workspace:
    a. Click "Advanced Options" and set Terraform Working Directory to "terraform".

 ### Step 2: Generate GCP Service Account Key for TFC
 Before moving forward, you should ensure you have a Google Cloud project set up, please follow instructions below:

 1. **Select or Create a Google Cloud Project:**
      - Log in to the [Google Cloud Console](https://console.cloud.google.com/).
      - On the top navigation bar, you'll see a dropdown where you can  select an existing project or create a new one.
      - If you need to create a new project, click on the "New Project" button  and follow the prompts to set up a new project. Be sure to note the project ID as you'll need it for your Terraform configurations.

 2. **Create a Service Account:**
    - Go to the [Google Cloud Console](https://console.cloud.google.com/).
    - Navigate to "IAM & Admin" > "Service Accounts".
    - Click "Create Service Account" and follow the instructions.
   **Set Service Account Details**
    - Set Service Account Name
    - Set Service Account Id
   **Grant Service Account Access to Project:**
    - From "select a role" dropdown, select "project", then "editor" or "owner".
    - To allow key enable/disable Google API 
      - Click "Add Another Role
      - From "select a role" dropdown, select "Services Usage", then "Services Usage Admin".
    - Click Done

 3. **Create and Download the JSON GCP Credential Key:**
   Once the service account is created, create a key in JSON format.
    - Click on the created service account, go to the "Keys" section, and click "Add Key" > "Create new key".
    - Choose JSON and click "Create". The key file will be downloaded to your machine.

 ### Step 3: Set GCP Credential Key Environment Variable on TFC

 1. **Prepare the JSON Key:**
    - Use `jq` to compress the JSON key into a single line. In your terminal, run:
      ```bash
      jq -c . < path/to/your-key.json > path/to/compressed-key.json
      ```
    - Open the `compressed-key.json` file and copy its content.

 2. **Configure the Environment Variable in Terraform Cloud:**
    - In your Terraform Cloud workspace, go to "Variables".
    - Under "Variables," click "Add variable".
    - Ensure you mark "Environment variable".
    - Name the variable `GOOGLE_CREDENTIALS`.
    - Paste the contents of the `compressed-key.json` file into the "Value" field.
    - Ensure you mark the variable as "Sensitive" to keep the credentials secure.
    - Click "Save variable".

 ### Step 4: Enable Version Control (VCS)
 1. **Set VCS setting**
      - In your Terraform Cloud workspace, go to "Settings" > "Version Control"
      - Under VCS Triggers, ensure you mark "Always trigger runs".
      - Set VCS branch to "prod", make sure that branch exists before.
      - Ensure you mark "Automatic speculative plans"
      - Click "Update VCS settings".

### Step 5: Mirror Github Repository to Cloud Source Repository (CSR)
Mirroring a GitHub repository to Cloud Source Repositories (CSR) in Google Cloud Platform (GCP) allows you to maintain a copy of your GitHub repository in Google Cloud. This can be beneficial for integrating with other Google Cloud services, such as Cloud Build. Here’s how to set up a mirror:

#### Step 1: Enable Cloud Source Repositories API
**Option 1: Google Console**
- Go to the Google Cloud Console.
- Navigate to the "APIs & Services" dashboard.
- Click "+ ENABLE APIS AND SERVICES".
- Search for "Cloud Source Repositories" and enable it for your project.

**Option 2: Google Cloud SDK**
- Authenticate with Google Cloud: `gcloud auth login`
- Set your project ID: `gcloud config set project <project-id>`
- Enable the Cloud Source Repositories API `gcloud services enable sourcerepo.googleapis.com`

#### Step 2: Mirror the GitHub Repository
- **Open Cloud Source Repositories:**
    - In the Google Cloud Console, navigate to "Source Repositories" within the "Tools" section or search for "Cloud Source Repositories" in the top search bar.

- **Start Repository Mirroring:**
    - Click on "Add repository".
    - Choose "Connect external repository", then select your project.
    - Click "Continue".

- **Select Source Provider:**
    - Choose GitHub as your source provider. You might be prompted to authorize Google Cloud Platform to access your GitHub account. Follow the on-screen instructions to grant the necessary permissions.

- **Choose the Repository to Mirror:**
    - After authorization, you’ll see a list of your GitHub repositories. Select the repository you wish to mirror.
    - Click "Connect Selected Repository".

- **Finalize the Mirroring Setup:**
    - Once connected, Google Cloud Source Repositories will automatically sync the selected GitHub repository. Every push to your GitHub repository will be mirrored in Cloud Source Repositories.

#### Step 3: Verify the Mirroring

- After setting up the mirror, you can verify it by navigating to Cloud Source Repositories in the Google Cloud Console. You should see your GitHub repository listed there, and it should update automatically whenever changes are pushed to GitHub.

#### Additional Information

- **Automated Builds:** With your repository mirrored in Cloud Source Repositories, you can easily set up automated builds in Cloud Build by creating triggers that respond to commits to your mirrored repository.
- **Private Repositories:** If you’re mirroring a private GitHub repository, ensure that the Google Cloud service account used by Cloud Source Repositories has been granted access to that repository in GitHub.
- **Manual Sync:** While the mirror should update automatically, you can also trigger a manual sync in Cloud Source Repositories if needed.

Mirroring your GitHub repository to Cloud Source Repositories facilitates a seamless integration with Google Cloud’s developer tools, offering a robust CI/CD pipeline and enhancing your development workflow.


### Step 6: GCP Cloudbuild Webhook Deployment
1. **Setup Configuration**
- Set environment variables in `environments/config.sh` according to your Terraform Cloud (TFC), Google Cloud Platform (GCP), and GitHub Repository settings.
- Run `environments/setup/setup.sh`, it will deploy a CloudBuild webhook and set the necessary permissions for the service account.

2. **Script Functionality** (`setup.sh` and `deploy_functions.sh`)
- **environments/config.sh:** Defines variables for TFC, GCP, GitHub, resources, Docker, and setup configurations.
- **environments/setup/setup.sh:** Makes the `deploy_function.sh` script executable and runs it.
- **deploy_functions.sh:**
    - Loads environment variables from `config.sh`.
    - Sets the GCP project to work with.
    - Checks if all required variables are set.
    - Retrieves the project number.
    - Creates a secret in GCP's Secret Manager to store the CloudBuild webhook's trigger secret.
    - Grants the Cloud Build service account access to the secret.
    - Deploys a Cloud Function that can trigger Cloud Build, passing environment variables to it.

### Step 7: Setup TFC Notification (Webhook) to Trigger CloudBuild Webhook

To set up a webhook for the Terraform Cloud (TFC) workspace to trigger CloudBuild, follow these instructions:

1. **Create a Notification Configuration in TFC:**
    - Log into Terraform Cloud and navigate to your workspace.
    - Go to "Settings" > "Notifications".
    - Click on "Create a Notification".
    - Enter a meaningful name for the notification.
    - For "Destination Type", select "Webhook".
    - For "Destination URL", you will need the URL of the Cloud Function deployed in Step 5. This function acts as the webhook receiver. The URL should look something like `https://REGION-PROJECT_ID.cloudfunctions.net/FUNCTION_NAME`, where `REGION`, `PROJECT_ID`, and `FUNCTION_NAME` are replaced with your specific values.
    - Select the events that should trigger the notification. Typically, you might choose "Run States" such as "Completed" or "Errored".
    - Click "Create Notification".
    - After notification creation, ensure notification is enabled (disabled by default).

2. **Test the Webhook:**
    - After setting up, it's a good idea to test the webhook to ensure it triggers CloudBuild as expected.
    - You can do this by triggering a Terraform run in your workspace that completes the criteria for sending a notification.
    - Check your Cloud Build history in the GCP Console to confirm that the run was triggered by the webhook. Or use `gcloud builds list` command to list builds, you can view detailed log by running `gcloud builds log <build-log-id>` (build log id is listed at `gcloud builds list`).

This setup creates a direct link between your Terraform Cloud runs and Google Cloud Build, enabling CI/CD processes that automatically deploy infrastructure changes when Terraform plans are applied.

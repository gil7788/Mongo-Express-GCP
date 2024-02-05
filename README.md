# Google Cloud Platform - Terraform Cloud Scaffold

## Project Tree Structure

The structure of this project is designed to support a modular and efficient development workflow, integrating infrastructure management with application development. Below is a description of key directories and their intended purposes:

### `environments/master`
This directory houses the Terraform configurations specific to the master (or development) environment. It's structured to manage resources that are in a continuous state of iteration, closely aligned with the ongoing development of the application.

### `environments/prod`
Contains Terraform configurations for the production environment. This setup is tailored for stability and reliability, managing the infrastructure that supports the application once it's ready to be released to end users.

### `environments/`
The parent directory for different environment configurations, `environments/` includes shared scripts, configurations (like `cloudbuild.yaml` for CI/CD pipelines), and Terraform modules in a `modules/` subdirectory.

### `app`
The `app` directory holds the application code, Dockerfile, and any scripts needed for building and running the application container. This setup facilitates a consistent development environment and eases the process of containerization and deployment.

## Developer Environment Setup

For a new developer joining the project, the following steps outline how to get started. These steps assume that the repository and workspace have been initially configured by a repository admin.

1. **Clone the Project Repository:**
   Start by cloning the repository to your local machine to access the project files.
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. **Install Necessary Tools:**
   Ensure you have Docker, the Google Cloud SDK, and Terraform installed on your machine. These tools are essential for running the application, managing cloud resources, and applying infrastructure changes.

3. **GCP Authentication:**
   Authenticate with Google Cloud using the `gcloud` CLI to access GCP resources. This step might require you to have access to the Google Cloud project and appropriate permissions.
   ```bash
   gcloud auth login
   gcloud config set project <project-id>
   ```

4. **Access Terraform Cloud Workspace:**
   Make sure you have access to the Terraform Cloud workspace associated with the project. You might need an invitation from the repository admin. Once added, configure your Terraform CLI to work with the Terraform Cloud workspace.

5. **Environment Configuration:**
   Set up any required local environment variables. This may include cloud credentials, application configuration variables, and anything else necessary for development.

   Given the outlined setup, a developer joining the project would need to configure their environment based on the completed setup steps by the repository admin. This includes:

   - **Google Cloud SDK Configuration:** Ensure the Google Cloud SDK is installed and authenticated against the developer's Google account with access to the GCP project. Use `gcloud auth login` and `gcloud config set project <project-id>` to set up the local environment for GCP access.

   - **Terraform Cloud Workspace Access:** The developer needs access to the Terraform Cloud workspace that has been linked with the GitHub repository. They may require an invitation from the admin or workspace owner to join this workspace.

   - **Environment Variables for Terraform Cloud:** If there are any specific environment variables set up in the Terraform Cloud workspace (e.g., `GOOGLE_CREDENTIALS`), the developer may need to ensure these are also configured or accessible for local development and testing. This might involve setting local environment variables or configuring equivalent settings in their development tools.

   - **Local Terraform Configuration:** Developers should initialize Terraform locally within the project directory (specifically within the `environments/master` or `environments/prod` directories, depending on their development focus) by running `terraform init`. This step ensures they can run Terraform plans and applies locally for testing.

   - **Access to Service Account Key:** For operations that require GCP access, such as deploying cloud functions or interacting with GCP services, developers will need access to the GCP service account key. They should securely obtain this key from an admin and configure it locally, typically by setting the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of the JSON key file.

   - **GitHub Repository Setup:** Developers need to clone the GitHub repository to their local development machine using `git clone <repository-url>`. They should ensure they have the necessary permissions to push changes to the repository.

   - **Cloud Source Repositories (CSR) Mirroring:** If the project uses CSR for mirroring the GitHub repository, developers should verify that this is correctly set up and that they have access to the CSR repository. This might involve coordinating with the admin to ensure proper access rights.

These steps ensure that a new developer has the necessary tools, access, and configurations to start contributing to the project effectively.


6. **Initialize Terraform:**
   Navigate to the relevant environment directory within `environments/` and run `terraform init` to prepare Terraform to manage the infrastructure.

7. **Running the Application Locally:**
   Use Docker to build and run the application locally for development and testing. Navigate to the `app/` directory and use the Docker CLI to build the container image and run the application.


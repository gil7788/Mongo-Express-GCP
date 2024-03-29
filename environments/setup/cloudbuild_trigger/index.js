const {CloudBuildClient} = require('@google-cloud/cloudbuild');
const client = new CloudBuildClient();

exports.triggerCloudBuild = async (req, res) => {
  const projectId = process.env.PROJECT_ID;
  const mirroredRepoName = process.env.GCP_MIRRORED_REPOSITORY_NAME; // This should be in lower case as per GCP setup
  const branchName = process.env.BRANCH_NAME;

  // Define substitutions from environment variables or hardcoded values
  const substitutions = {
    _GCP_REGION: process.env.GCP_REGION,
    _PROJECT_ID: projectId,
    _GCP_CONTAINER_REGISTRY_REPOSITORY_NAME: process.env.GCP_CONTAINER_REGISTRY_REPOSITORY_NAME,
    _DOCKER_IMAGE_NAME: process.env.DOCKER_IMAGE_NAME,
    _GCP_CLOUD_RUN_SERVICE_NAME: process.env.GCP_CLOUD_RUN_SERVICE_NAME,
  };

  // [TODO] Add manual github repository mirroring to the cloud source repository, to make sure the source code is updated
  const buildRequest = {
    projectId: projectId,
    build: {
      steps: [
        {
          // Cloning the specific branch from the repository
          name: 'gcr.io/cloud-builders/git',
          args: [
            'clone',
            '-b',
            branchName,
            '--single-branch',
            `https://source.developers.google.com/p/${projectId}/r/${mirroredRepoName}`,
            '.'
          ],
          id: 'clone-repo',
        },
        {
          // Submitting a new build request with the short SHA included in the substitutions
          name: 'gcr.io/cloud-builders/gcloud',
          entrypoint: 'bash',
          args: [
            '-c',
            `
            gcloud builds submit --config src/app/cloudbuild.yaml --substitutions=_GCP_REGION=${substitutions._GCP_REGION},_PROJECT_ID=${substitutions._PROJECT_ID},_GCP_CONTAINER_REGISTRY_REPOSITORY_NAME=${substitutions._GCP_CONTAINER_REGISTRY_REPOSITORY_NAME},_DOCKER_IMAGE_NAME=${substitutions._DOCKER_IMAGE_NAME},_GCP_CLOUD_RUN_SERVICE_NAME=${substitutions._GCP_CLOUD_RUN_SERVICE_NAME},_SHORT_SHA=latest ./src/app
            `,
          ],
          id: 'submit-build',
          waitFor: ['clone-repo'],
        }
      ],
    }
  };

  console.log("Triggering build with request:", JSON.stringify(buildRequest, null, 2));
  let buildRequestString = JSON.stringify(buildRequest, null, 2);

  try {
    const [operation] = await client.createBuild(buildRequest);
    // Wait for the build to complete and get the result
    const [build] = await operation.promise();

    // Create a string to hold the build response details
    let buildResponseString = JSON.stringify({
      id: build.id,
      status: build.status,
      startTime: build.startTime,
      finishTime: build.finishTime,
      logsBucket: build.logsBucket,
      sourceProvenanceResolved: build.sourceProvenanceResolved,
    }, null, 2);

    // Sending back a verbose success response that includes both the request and the build result
    res.status(200).send(`Build Request: ${buildRequestString}\nBuild Result: ${buildResponseString}`);
  } catch (error) {
    console.error("Error triggering build:", error);

    // Sending back a verbose error response that includes the request and the error message
    res.status(500).send(`Build Request: ${buildRequestString}\n Error triggering build: ${error.message}`);
  }
};

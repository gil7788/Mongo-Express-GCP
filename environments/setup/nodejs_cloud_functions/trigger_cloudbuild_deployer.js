const { CloudBuildClient } = require('@google-cloud/cloudbuild');

exports.triggerCloudBuild = async (req, res) => {
  const client = new CloudBuildClient();
  const projectId = process.env.PROJECT_ID;
  const triggerId = process.env.MASTER_BRANCH_CLOUD_BUILD_TRIGGER_ID;
  const branchName = 'master';

  const buildRequest = {
    projectId: projectId,
    triggerId: triggerId,
    source: {
      projectId: projectId,
      branchName: branchName,
    },
  };

  let responseMessage = `Triggering build with the following request: ${JSON.stringify(buildRequest)}`;

  try {
    const [operation] = await client.runBuildTrigger(buildRequest);
    responseMessage += `\nBuild successfully triggered: ${operation.metadata.build.id}`;
    res.status(200).send(responseMessage);
  } catch (error) {
    responseMessage += `\nError triggering build: ${error.message}`;
    console.error("Error triggering build:", error);
    res.status(500).send(responseMessage);
  }
};

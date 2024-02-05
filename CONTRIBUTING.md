# How to Contribute

This file presents a few guidelines you need to follow, so that your contribution will utilize Terraform Cloud hooks and will be easy to merge with the contribution of others.

## Workflow
 ### GitHub Flow
 In our project, we use a structured branching strategy involving `prod`, `master`, and feature branches. The `master` branch serves as the primary development branch where all the feature development takes place. Contributors create feature branches off of `master` for each new feature or bug fix. After completing the development, the changes are merged back into `master` through pull requests.

For releases, we use the `prod` branch, which represents the production-ready state of our application. When it's time to deploy, the latest stable version of code from `master` is merged into `prod`


 #### Updating the Master Branch:

 Here’s how to update the master branch using this workflow:

 1. **Create a Feature Branch:**
    - From  `master` branch, create a new branch. This is where you'll work on your changes.
    ```bash
    git checkout master
    git pull origin master
    git checkout -b your-feature-branch
    ```

 2. **Develop Your Feature:**
    - Make your changes in this feature branch. Commit these changes to the branch.
    ```bash
    git add .
    git commit -m "Your commit message"
    ```

 3. **Create a Pull Request (PR):**
    - Push your branch to the remote repository and open a pull request to the `master` branch.
    ```bash
    git push origin your-feature-branch
    ```
    - On GitHub, create a new PR from `your-feature-branch` to `master` 

 4. **Merge the PR:**
    - After Pull Request review
    - Choose either **"Squash and merge"** or **"Rebase and merge"**.

 #### Updating the Production (Prod) Branch: 

 For deploying to production, the workflow involves merging changes from the `master` branch into a `prod` branch. 

 1. **Create a Pull Request to Prod Branch:** 
    - From the `master` branch, create a new pull request to the `prod` branch. 
    ```bash 
    git checkout master 
    git pull origin master 
    git push origin master  # Ensure the remote master is up to date 
    ``` 
    - On GitHub, create a new PR from `master` to `prod` 

 2. **Merge with a Merge Commit:** 
    - Select "Create a merge commit" while merging the pull request on GitHub.

 3. **Update Local Prod and Master Branches:** 
    - After merging, make sure to update both your local `prod` and `master` branches. This ensures that both branches reflect the current state of the repository after the merge. 
    ```bash 
    # Update local prod branch 
    git checkout prod 
    git pull origin prod 

    # Update local master branch 
    git checkout master 
    git merge origin prod 
    git push origin master 
    ``` 
#### Managing conflicts
Here's how to manage a scenario, with `feature/one` already rebased and merged into `master`, and now needing to add changes from `feature/two` into `master`.

##### Managing Conflicts on Master Branch:
**Update Your Local master Branch:**
Before attempting to merge `feature/two`, ensure your local `master` branch is up to date with the remote repository. This includes the changes from `feature/one` that were recently merged.

    git checkout master
    git pull origin master

**Rebase feature/two Against the Updated master:**
Switch to your `feature/two` branch and rebase it against the updated `master` branch. This step is crucial as it applies your `feature/two` changes on top of the latest `master`, helping to identify and resolve conflicts outside the `master` branch.

    git checkout feature/two
    git rebase master

During the rebase process, git may pause and alert you to conflicts that need to be resolved manually.

**Resolve Conflicts:**
If there are conflicts, git will stop the rebase and list the files that need manual intervention. Open these files in your code editor, and you'll see sections marked with <<<<<<<, =======, and >>>>>>>, indicating conflicting changes. Resolve each conflict by editing the file to your desired final state.

After resolving each conflict in a file, add it to the staging area:

    git add <filename>

Once all conflicts are resolved and the changes are staged, continue the rebase:

    git rebase --continue

Repeat this process until all conflicts are resolved and the rebase is complete. If at any point you decide that the rebase should be aborted, you can do so with `git rebase --abort`.

**Finalize the Merge:**
After successfully rebasing `feature/two` onto the latest `master`, push your changes to the remote feature branch (you might need to use force push due to the rebase, but be cautious as this can overwrite history on the remote branch):

    git push origin feature/two --force

Then, create a pull request for `feature/two` into `master` as you did with `feature/one`. Since `feature/two` has been rebased, the pull request should only contain the changes unique to `feature/two` and be free of conflicts with `master`.

**Review and Merge the Pull Request:**
Have your changes reviewed through the pull request process. If there are no additional conflicts or issues, merge `feature/two` into `master` using your project's preferred merge strategy - either squash and merge, or rebase and merge.

#### Managing conflicts on Prod Branch
`prod` branch should be updated only by a pull request from `master` branch. Using such workflow, will prevent conflicts at merge between `master` and `prod` branches.
If there is a merge conflict between `master` branch and a `prod` branch, you should raise a red flag and reconsider your workflow.


#### Best Practices for Conflict Management:
1. Keep Branches Short-Lived: The longer a branch lives separately from `master`, the higher the chances of conflicts. Try to merge feature branches back into `master` as soon as they're ready and tested.

2. Regularly Pull Changes from `master` into Your Feature Branches: This can help minimize conflicts by keeping your feature branches up-to-date with the latest changes in `master`.

3. `prod` branch should be updated only by a pull request from `master` branch. Using such workflow, will prevent conflicts at merge between `master` and `prod` branches.

4. Consider using feature toggles to shorten `prod` branch update cycle.

### Provision Resource on Google Cloud Platform
This section provides guidelines for resource provision on Google Cloud Platform utilizing Terraform Cloud. There are 2 environments configured in this project:
1.  `master` used as test environment.
2. `prod` used as production environment.

Both of the environments are configurable with terraform and independent from one another, such stucture facilitates test fexibility.

[TODO elborate on the corespondence between application development and resource provisioning. How can one develop an application and configure resources for the application to run is our project]


## Terrafrom Cloud Hooks
This section provides a brief overview of the installed hooks on Github `master` and `prod` branches by Terraform Cloud.

#### Terraform Plan Workflow
- **Trigger**: The workflow is triggered on pull requests to the `master` and `prod` branches.
- **Steps**:
  1. **Checkout**: Checks out the repository code.
  2. **Upload Configuration**: Uploads the Terraform configuration to Terraform Cloud.
  3. **Create Plan Run**: Creates a speculative plan in Terraform Cloud.
  4. **Get Plan Output**: Retrieves the output of the Terraform plan.
  5. **Apply Manually (Optional)**: Use TFC GUI to apply change manually (see **Terraform Apply Workflow** for more details).

#### Terraform Apply Workflow
- **Trigger**: The workflow is triggered on pull requests to the `prod` branch.
- **Steps**:
  1. **Checkout**: Checks out the repository code.
  2. **Upload Configuration**: Uploads the Terraform configuration to Terraform Cloud.
  3. **Create Apply Run**: Creates an apply run in Terraform Cloud.
  4. **Apply**: Applies the Terraform configuration if it is confirmable.
  5. **Cloudbuild**: Builds application utilizing provisioned resource on GCP and runs application.

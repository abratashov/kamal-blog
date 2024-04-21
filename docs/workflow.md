# Workflow

## Setup GitLab CI Pipeline (by admin)

1. Check or modify existing pipeline `.gitlab-ci.yml`

2. Create SSH key to demo server deploy
https://docs.gitlab.com/ee/ci/ssh_keys/
https://docs.gitlab.com/ee/user/ssh.html#generate-an-ssh-key-pair

```sh
local$ ssh-keygen -t ed25519 -f ~/.ssh/id_kamal_blog_demo_ed25519 -C "demo@kamal_blog.org"
<SKIP entering PASSPHRASE to deploy from the Gitlab runner>
local$ cat ~/.ssh/id_kamal_blog_demo_ed25519.pub | ssh deployer@31.42.190.196 'cat >> ~/.ssh/authorized_keys'
```

3. Add restriction to merge requests:
https://gitlab.com/user/project/-/settings/merge_requests
```
[*] Merge method: Fast-forward merge
[*] Merge options: Enable the "Delete source branch" option by default
[*] Squash commits when merging: Encourage / Checkbox is visible and selected by default
[*] Merge checks: Pipelines must succeed
```
4. Add ENV variables that are described in `.gitlab-ci.yml`

https://docs.gitlab.com/ee/ci/variables/#for-a-project
https://gitlab.com/user/project/-/settings/ci_cd

## Git Workflow with GitLab CI

Generally, PRs should be **nice and small** and all commits should be squashed.

Create a meaningful **branch name** in the format `{ID}-Ticket-description` that links the branch to the ticket. In case of ticket absence, use a common pattern that starts from the `chore`, like this `chore/description-without-id`. Please don't start the branch name from the `m`, `ma`, `mai`, `main` because it hardens switching to the real `main` branch in the cmd by `[Tab]` pressing in our daily routine.

Add ticket ID to **commit message**, this facilitates exploring Git history during the debugging and seeking the cause of bugs. The commit message could be in any format, e.g. `[{ID}] Commit description`, all commits of the PR should be squashed in one before merging (GitLab can do it by default).

**Workflow**

1. Each task should be added to GitLab, GitHub or JIRA and have its `ID`

2. Create a new branch from the `main`, e.g. `555-New-super-task`

3. Commit everything to our branch with the same commit message: `555-New-super-task` (because all the commits from the branch will be merged into one anyway)

4. When everything is ready, open the PR into `main`, leave `merge all commits into one` and `delete the branch` as it is already configured by default

5. Set the status of the PR to `Ready for Review` and add needed developers

6. Wait for the `green build`

7. After merging to the `main`, run the `demo` deploy manually from the icon on the PR or "main" branch

8. The same action is to update the `production` server by `admin`

9. Check that everything is OK and be happy!

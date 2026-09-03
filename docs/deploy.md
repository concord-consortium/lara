# Deployment

## S3 deploys

One GitHub Actions workflow deploys static files to S3 on every push:

- [`deploy-example-interactives.yml`](../.github/workflows/deploy-example-interactives.yml) builds the example interactives and deploys them to `models-resources/lara-example-interactives/`.

## AWS Access

The GitHub actions in this project are allowed to update files in S3 using OIDC. An IAM role has been created in AWS with a trust policy that allows GitHub actions in this specific repository to assume this IAM role. The IAM role has a `RepoName` tag and a managed policy that uses this tag to give the role's users permission to update files in `models-resources/[RepoName]`.

See [deploy-setup.md in starter-projects](https://github.com/concord-consortium/starter-projects/blob/main/doc/deploy-setup.md) for how the AWS side is set up.

### Why this repo needs an extra policy

The shared managed policy grants access to `models-resources/lara/` only, because the repository is named `lara`. This repo does not use that prefix — it deploys to `models-resources/lara-example-interactives/`. The `lara` role therefore carries an additional inline policy, `lara-extra-s3-prefixes`, granting access to that prefix. Re-running `create-deploy-role.sh` updates the trust policy and leaves the inline policy alone.

## Rails application deploys

The LARA Rails application is **not** deployed by GitHub Actions.

GitHub Actions only builds the application image. The `build` job in [`ci.yml`](../.github/workflows/ci.yml) builds the Docker image on every push and pushes it to `ghcr.io/concord-consortium/lara`.

The deploy itself is run by hand with the AWS CLI: pick a released version, apply the Rails migrations as a one-off ECS task, then update the environment CloudFormation stack so its `LaraDockerImage` parameter points at the new image. The stacks are `authoring-lara-staging` for staging and `lara-ecs-production` for production. The full procedure, including the environment-specific names and the verification steps, is written up in [`.claude/skills/release-lara/SKILL.md`](../.claude/skills/release-lara/SKILL.md).

Because these deploys run under a person's own AWS credentials rather than in GitHub Actions, there is nothing here for OIDC to authenticate. A `deploy_backend_to_aws.yml` workflow that would have deployed the backend from Actions was written in early 2024 but never used, and was removed in favour of the process above.

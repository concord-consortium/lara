# Deployment

## S3 deploys

Two GitHub Actions workflows deploy static files to S3 on every push:

- [`deploy-storybook.yml`](../.github/workflows/deploy-storybook.yml) builds the `lara-typescript` Storybook and deploys it to `models-resources/lara-storybook/`.
- [`deploy-example-interactives.yml`](../.github/workflows/deploy-example-interactives.yml) builds the example interactives and deploys them to `models-resources/lara-example-interactives/`.

## AWS Access

The GitHub actions in this project are allowed to update files in S3 using OIDC. An IAM role has been created in AWS with a trust policy that allows GitHub actions in this specific repository to assume this IAM role. The IAM role has a `RepoName` tag and a managed policy that uses this tag to give the role's users permission to update files in `models-resources/[RepoName]`.

See [deploy-setup.md in starter-projects](https://github.com/concord-consortium/starter-projects/blob/main/doc/deploy-setup.md) for how the AWS side is set up.

### Why this repo needs an extra policy

The shared managed policy grants access to `models-resources/lara/` only, because the repository is named `lara`. This repo does not use that prefix — it deploys to `models-resources/lara-storybook/` and `models-resources/lara-example-interactives/`. The `lara` role therefore carries an additional inline policy, `lara-extra-s3-prefixes`, granting access to those two prefixes. Re-running `create-deploy-role.sh` updates the trust policy and leaves the inline policy alone.

## Rails application deploys

The LARA Rails application itself is deployed to AWS ECS by [`deploy_backend_to_aws.yml`](../.github/workflows/deploy_backend_to_aws.yml), which updates a CloudFormation stack and runs database migrations as a one-off ECS task. That workflow still authenticates with long-lived AWS access keys and has not been migrated to OIDC.

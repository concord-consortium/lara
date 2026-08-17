---
name: release-lara
description: Release and deploy LARA authoring to staging or production on AWS ECS. Tags a version, waits for the image build, applies Rails migrations as a one-off ECS task, updates the CloudFormation stack to the new image, and verifies the deployed version end to end. Handles pre-releases cut from a feature branch as well as releases from master. Use when asked to release, deploy, cut a version, ship a branch to staging, or push LARA to AWS.
---

# Release LARA

Releases LARA by tagging a version, running migrations as a one-off ECS task, and
pointing the environment's CloudFormation stack at the new image. Everything is driven
through the AWS CLI.

**Deploying is a real, user-visible change.** Production serves live authors whose
activities are used by teachers and students. Never run the production path without an
explicit confirmation from the user in the same conversation, and never skip the
pre-flight checks to save time.

## Environment parameter

Takes one argument, `staging` or `production`.

**If the argument is absent, ask the user which environment before doing anything
else.** Use `AskUserQuestion` with those two options; this is a consequential, discrete
choice and it must not be guessed. Do not infer it from the branch, the last release, or
from context. If the user names an environment in prose ("ship it to staging"), that
counts as the argument being present.

## Environment configuration

Look these up rather than deriving them. **Nothing here is named symmetrically**, and
every pattern-based guess is wrong for at least one environment. The stack names invert
the word order, and the production log group is a near-anagram of the production stack
name.

| | staging | production |
|---|---|---|
| CloudFormation stack | `authoring-lara-staging` | `lara-ecs-production` |
| ECS cluster | `staging` | `production` |
| App task family | `authoring-lara-staging-App` | `lara-ecs-production-App` |
| Migrate task family | `authoring-lara-staging-App-migrate` | `lara-ecs-production-App-migrate` |
| CloudWatch log group | `authoring-lara-staging` | `lara-production-ecs` |
| Host | `authoring.lara.staging.concord.org` | `authoring.concord.org` |
| Version style | usually pre-release `vX.Y.Z-pre.N`, see step 2 | release `vX.Y.Z` |

Region is `us-east-1`, account `612297603577`, image repo
`ghcr.io/concord-consortium/lara`, and the stack's image parameter is
**`LaraDockerImage`**. Confirm the AWS identity with `aws sts get-caller-identity`
before making changes.

Three naming traps, each of which has a plausible wrong answer sitting right next to the
right one:

- **The production log group is `lara-production-ecs`, not `lara-ecs-production`.** That
  second string is the *stack* name. A group named `lara-production-app` also exists but
  carries hash-named streams from a different logging setup, not the ECS task streams.
- **Stale `lara-ecs-staging-*` task families still exist** (`lara-ecs-staging-App`,
  `lara-ecs-staging-App-migrate`, and others) from a retired staging stack. The current
  staging families are the `authoring-lara-staging-*` ones. Running a migration against
  the wrong family points it at a retired environment's configuration.
- **Production has many one-off `lara-ecs-production-App-*` families**
  (`-migrate2`, `-publish-runs`, `-copy-anon-runs`, and more). Only `-App-migrate` is the
  schema migration family.

Re-derive the cluster from the stack rather than trusting the table if anything looks
off:

```bash
aws cloudformation describe-stacks --stack-name "$(aws cloudformation describe-stacks \
  --stack-name "$STACK" --query "Stacks[0].Parameters[?ParameterKey=='ClusterStackName'].ParameterValue" \
  --output text)" --query "Stacks[0].Parameters[?ParameterKey=='EcsClusterName'].ParameterValue" --output text
```

## Helper scripts

Three helper scripts ship with this skill, in its own `scripts/` directory. **Their paths
are relative to the skill, not to the repo.** The working directory throughout a release
is the LARA checkout, whose top-level `scripts/` is unrelated, so a bare
`scripts/verify-migration.sh` resolves to nothing or to the wrong file. Set `SKILL_DIR`
from the base directory reported when the skill was loaded, and invoke them through it:

```bash
SKILL_DIR=<the skill's base directory>   # as reported on load
```

| script | answers | source |
|---|---|---|
| `verify-migration.sh` | did *this* migrate task fail, and why | the task's Rails output |
| `check-migration-status.sh` | is the schema where it should be | `schema_migrations` in the database |
| `check-deployed-version.sh` | is the new image actually serving | the served footer |

The two migration scripts are complementary, not alternatives, and step 5 runs both. Only
the database knows which migrations are applied; only the log says why a run died.

## Reading the schema state

`schema_migrations` is the primary source for which migrations are applied: it is the
table Rails itself consults to decide what is still pending. Read it with
`rake db:migrate:status` whenever the question is *is the schema where it should be*,
rather than inferring it from a migrate task's log. The table survives log retention, does
not depend on the wording of Rails' output, and after a partial failure states exactly
which migrations are missing.

The database is only reachable from inside the VPC, so this runs as a one-off ECS task and
its output still arrives via CloudWatch. That is not the same as scraping the migrate run's
narration: the answer originates in the database, not in a process's claim about itself.

**Do not register a task definition revision to read status.** Step 6 treats revisions of
the `-App-migrate` family as the audit trail of what migrated, so a status-only revision
would look exactly like a migration run for that version. `run-task --overrides` can
change the command (just not the image), which is all this needs.

**Which task definition to override decides the argv**, because the two families differ in
`entryPoint`. Verified on both environments: the container is named `App` in each.

**Pick exactly one of the next two lines.** They are alternatives, not a sequence, and
running both leaves you on the second with a possibly-unset `$REV`.

```bash
# Any time: the App family has an empty entryPoint, so command is the whole argv.
CMD='["bundle","exec","rake","db:migrate:status"]'; TD="${STACK}-App"

# Only right after step 5: that revision already has entryPoint ["bundle","exec"].
CMD='["rake","db:migrate:status"]'; TD="${STACK}-App-migrate:${REV}"

aws ecs run-task --cluster "$CLUSTER" --launch-type EC2 --count 1 \
  --started-by "lara-migrate-status" --task-definition "$TD" \
  --overrides "{\"containerOverrides\":[{\"name\":\"App\",\"command\":${CMD}}]}" \
  --query '{taskArn:tasks[0].taskArn,failures:failures}'

STATUS_TASK=<last path segment of taskArn>
until [ "$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$STATUS_TASK" \
        --query 'tasks[0].lastStatus' --output text)" = "STOPPED" ]; do sleep 10; done
```

**The image decides the file list, the database decides the applied list.** Both halves of
the status table come from different places, so a version can read as absent purely because
the task ran an older image. That is why a pre-flight read against the still-deployed image
reports the release's new migrations as `NOT IN IMAGE`, and why it is not an error there.

Then assert with the script, passing **version timestamps, not class names**:

```bash
"$SKILL_DIR"/scripts/check-migration-status.sh "$LOG_GROUP" "$STATUS_TASK" applied <version ...>
```

Mode `applied` requires every migration file in the image to be up. Mode `report` prints
the same state without failing on pending migrations, for reads taken before migrating.

The version is the timestamp, derived from the same filenames as step 3a:

```bash
git diff --name-only "$FROM_TAG".."$TARGET_REF" -- db/migrate/ \
  | sed -n 's#.*/\([0-9]\{14\}\)_.*#\1#p'
```

Class names are wrong here, and the reason is in Rails rather than in the script:
`db:migrate` logs the camelized name (`AddFooToBars`) while `db:migrate:status` humanizes
the same name (`Add foo to bars`). A class name therefore matches `verify-migration.sh`'s
input and never this one. The version is identical in both outputs and in the filename.

## Releasing from a branch

**Production is master-only.** Never tag production from anything else. Code reaches
production having been reviewed and merged, and a production tag on a branch would ship
work that no PR ever approved. If asked for a production release from a branch, stop and
say the branch needs merging first.

**Staging is routinely cut from a branch**, and that is the normal way to test work in
progress. It is what pre-release tags are for. Nothing below is an exception to be
apologized for; it is the common case during development.

Everything in the steps still applies. Only these differ:

- **Push the branch before pushing the tag.** Pushing a tag alone does upload the commits,
  but they are then reachable only from the tag, so deleting it can strand them. It also
  keeps the PR showing what was actually deployed.
- **`git log "$FROM_TAG"..HEAD` in step 2 must not be `..master`.** On a branch, `..master`
  reports the wrong commit set entirely, usually an empty or misleadingly short list.
- **Say the branch and SHA in the report.** A branch pre-release is not reproducible from
  master's history, and if the PR is later squash-merged the tagged commit never lands on
  master at all, so the tag becomes the only record of what that image contained.

**The trap worth slowing down for is divergence.** Staging holds whatever was deployed
last, which is usually master lineage. A branch that forked before commits already on
staging will, when deployed, *remove* them from staging, and step 3d reports this as
DIVERGENT rather than FORWARD. That is not a formality: staging is shared, so this silently
takes away work someone else may be testing.

Merge master into the branch before releasing (or rebase onto it) so the deploy reads as
FORWARD and carries everything staging already had. Prefer this to overriding the check.
When you do deploy something divergent deliberately, say which master commits staging is
losing, not just that it diverged.

## Steps

### 1. Preconditions

- Working tree clean and `git pull` done, on whichever ref this release is cut from. See
  Releasing from a branch: **production is master-only, staging is not.**
- `aws sts get-caller-identity` returns account `612297603577`.
- Report what is currently deployed before changing anything:

```bash
aws cloudformation describe-stacks --stack-name "$STACK" \
  --query 'Stacks[0].{Status:StackStatus,Updated:LastUpdatedTime,Image:Parameters[?ParameterKey==`LaraDockerImage`].ParameterValue}'
```

Abort if the stack is not in a settled state (`UPDATE_COMPLETE` or `CREATE_COMPLETE`).
Deploying onto an in-progress or rolled-back stack is how you get a stuck stack.

The currently deployed image tag is the **from-version** for every diff below.

### 2. Choose the version

Versioning is semver from the commits since the last release: any `feat:` commit means a
minor bump, otherwise a patch bump. Check what is actually shipping:

```bash
git log --oneline "$FROM_TAG"..HEAD      # HEAD, so this reads correctly on a branch too
```

**Read that list, do not just count it.** Environments here routinely sit many weeks
behind, so a release billed as "ship the column-labeling fix" can carry dozens of
unrelated commits across several tickets. Summarize everything that is actually going
out, so nobody attributes a surprise to whichever ticket prompted the release.

- **staging** usually cuts a pre-release, `vX.Y.Z-pre.N`. `N` starts at 0 and increments
  if that version already has pre-releases.
- **production** cuts the plain `vX.Y.Z` matching the pre-release that was verified on
  staging.

**Staging is not always a pre-release, and the alternative is arguably safer.** The other
flow is to cut the final `vX.Y.Z`, build it once, deploy that image to staging, verify
it, then promote the *identical image* to production. Production then runs the exact
artifact that was validated on staging rather than a separate rebuild of the same commit.
Do not treat a request for a non-pre tag on staging as a mistake to be corrected. If the
user has not made the style clear, ask which of the two they want rather than assuming.

Tags are **annotated** (`git tag -a`), and the message convention is `Version v<X.Y.Z>`,
matching the tag itself. Confirm the chosen version with the user before creating it; a
wrong version number is annoying to undo once pushed.

Note pre-release tags are **plain git tags, not GitHub Releases**. Release objects exist
for final versions only, and are created in step 8.

### 3. Pre-flight checks

Run all four and report the results together **before** tagging. Each one has bitten a
real release.

**These checks run before step 4 creates the tag, so they must not reference `$NEW_TAG`**
as a git revision: it does not exist yet and every command below would fail with
`fatal: bad revision`. Resolve the target to a ref that exists now:

```bash
# A new release tags the current commit; a rollback targets an existing tag.
TARGET_REF=HEAD          # rollback: TARGET_REF="$NEW_TAG"
```

`$NEW_TAG` is still the name being *published*, and stays correct from step 4 onward once
the tag exists.

**a. Migrations that will apply.** This tells you whether step 5 is needed at all and,
critically, gives you the expected migration class names to verify against. Note LARA's
migrations live at the repo root, not under a `rails/` subdirectory:

```bash
git diff --name-only "$FROM_TAG".."$TARGET_REF" -- db/migrate/
```

Empty output means step 5 is skipped entirely. Say so in the report rather than running
the migrate task as a no-op.

This is a diff of files, not a reading of the database, so it says what the release *adds*
and not what is already applied. When the two could disagree, and they do whenever staging
was migrated ahead of the tag or a commit is being re-tagged, confirm the starting point
against `schema_migrations` (see Reading the schema state) in `report` mode. A clean
pre-flight read is zero pending migrations for the deployed image; anything pending before
you start is a leftover from an earlier release and needs explaining first.

**b. CloudFormation template drift.** `--use-previous-template` in step 6 means template
changes in the release are *not* applied. If the template changed, that is silent and
wrong:

```bash
aws cloudformation get-template --stack-name "$STACK" --template-stage Original \
  --query 'TemplateBody' --output text > /tmp/deployed-template.yml
git show "$TARGET_REF":configs/cloudformation/stack_template.yml > /tmp/tag-template.yml
diff -B <(sed 's/[[:space:]]*$//' /tmp/deployed-template.yml) <(sed 's/[[:space:]]*$//' /tmp/tag-template.yml)
```

Strip trailing whitespace on both sides **and pass `-B`**. Both are needed and they fix
different things. The `sed` handles trailing whitespace within a line; `-B` handles the
extra trailing *blank line* the deployed copy comes back with, which the `sed` cannot
touch because an empty line has no trailing whitespace to strip. Without `-B` this check
reports a phantom difference on every run, and the rule below then aborts every release
on something that is not real.

**Both environments currently carry known drift.** As of 2026-08, staging and production
each hold the same 43 extra template lines: an `AssessmentPortalSecret` parameter, an
`AddAssessmentPortal` condition, and `CONCORD_ASSESSMENT_CLIENT_ID` / `_SECRET` / `_URL`
environment variables on both the App and Worker containers. Commit `a8405aff`
("chore: remove Assessments Portal config", 2026-04-30) removed all of it from the repo
template, but no deploy has ever applied that removal, so both stacks still run the older
template. Expect this diff. It is the reason `--use-previous-template` is the default
here: applying the tag's template would delete those four values as a silent side effect
of a version bump.

**If the drift is anything other than that known block, stop and ask the user how to
proceed.** Applying a new template means passing `--template-body` from the tag instead of
`--use-previous-template`, which can change resources far beyond the image. Show them the
diff and let them decide.

**c. New or dropped stack parameters.** A new template parameter has no value on the
existing stack and must be supplied explicitly:

```bash
python3 -c "
import re
t=open('/tmp/tag-template.yml').read()
m=re.search(r'^Parameters:\n(.*?)^[A-Za-z]',t,re.S|re.M)
print('\n'.join(sorted(re.findall(r'^  ([A-Za-z0-9]+):',m.group(1),re.M))))
" | LC_ALL=C sort > /tmp/tag-params.txt
aws cloudformation describe-stacks --stack-name "$STACK" \
  --query 'Stacks[0].Parameters[].ParameterKey' --output text | tr '\t' '\n' | LC_ALL=C sort > /tmp/stack-params.txt
echo "need values:"; LC_ALL=C comm -23 /tmp/tag-params.txt /tmp/stack-params.txt
echo "dropped:";     LC_ALL=C comm -13 /tmp/tag-params.txt /tmp/stack-params.txt
```

Sort both with `LC_ALL=C`. Mismatched locale collation produces phantom differences that
look like real drift. `AssessmentPortalSecret` currently shows under "dropped" on both
environments; that is the same known drift as check b. If anything else is non-empty,
stop and ask the user for the new values or confirmation.

**d. Direction of the deploy.** Establish whether this moves the environment forwards,
sideways, or backwards, and **ask the user before proceeding on anything that is not a
clean forward deploy.** Do not refuse a backwards deploy: a rollback is a legitimate,
deliberate downgrade (see Rollback below), and the point of this check is to distinguish
a deliberate one from an accident.

Compare **commit ancestry, not version strings.** `sort -V` orders `v2.20.0` before
`v2.20.0-pre.0`, the reverse of semver, so a version-string comparison reports every
staging-to-production promotion as a downgrade.

```bash
DEPLOYED_VER="${DEPLOYED_IMAGE##*:}"        # from step 1, e.g. 2.19.0
DEPLOYED_TAG="v${DEPLOYED_VER}"
git fetch --tags --quiet

if [ "$DEPLOYED_TAG" = "$NEW_TAG" ]; then
  echo "SAME version already deployed"
elif ! git rev-parse -q --verify "${DEPLOYED_TAG}^{commit}" >/dev/null; then
  echo "UNKNOWN: deployed tag $DEPLOYED_TAG not found in this repo"
elif [ "$(git rev-parse "${TARGET_REF}^{commit}")" = "$(git rev-parse "${DEPLOYED_TAG}^{commit}")" ]; then
  echo "SAME COMMIT under a different tag (normal pre-release to release promotion)"
elif git merge-base --is-ancestor "$TARGET_REF" "$DEPLOYED_TAG"; then
  echo "DOWNGRADE: $NEW_TAG is an ancestor of the deployed $DEPLOYED_TAG"
elif git merge-base --is-ancestor "$DEPLOYED_TAG" "$TARGET_REF"; then
  echo "FORWARD: $DEPLOYED_TAG is an ancestor of $NEW_TAG"
else
  echo "DIVERGENT: neither $NEW_TAG nor $DEPLOYED_TAG is an ancestor of the other"
  echo "  on staging would lose:"
  git log --oneline "${TARGET_REF}..${DEPLOYED_TAG}" | head -20
fi
```

How to treat each result:

- **FORWARD** is the normal case. Continue.
- **SAME COMMIT** means the target and the deployed image are the same commit under two
  different tags. That is the normal staging-to-production promotion, and it also occurs
  **on staging** when the final `vX.Y.Z` is cut on the commit staging already runs as
  `vX.Y.Z-pre.N` (the build-once flow in step 2). Continue, and say so in the report. This
  is not a no-op deploy: the image tag differs, so CloudFormation does have a change to
  make, unlike the SAME version case below.
- **SAME version** means there is nothing for CloudFormation to change. It rejects a no-op
  update with `No updates are to be performed`, so step 6 fails rather than doing
  anything, and re-pointing the parameter at the image it already holds cannot restart
  anything. Ask what the user actually wants. If it is a restart, use `RestartToggle`
  (see "Forcing a restart" below) and skip the rest of this skill.
- **DOWNGRADE** needs an explicit confirmation, and the user must be told that
  **migrations are not reversed**. If any migration between the two versions was
  destructive or non-additive, the older code will be running against a schema it does not
  expect. Report which migrations sit between the two versions
  (`git diff --name-only "$TARGET_REF".."$DEPLOYED_TAG" -- db/migrate/`) so the decision is
  informed.
- **DIVERGENT** means each side has commits the other lacks. Releasing a branch to staging
  is the usual cause, and the consequence is concrete: staging *loses* the commits listed
  under "would lose". Report that list, not just the word DIVERGENT, and prefer merging
  master into the branch and re-tagging over deploying it as-is. See Releasing from a
  branch.
- **UNKNOWN** means the deployed tag is not in this repo at all, usually a tag never
  fetched or an image not built from a tag. Stop and ask; do not guess.

### 4. Tag, push, and wait for the image

```bash
git push origin HEAD          # branch releases: push the branch first, see below
git tag -a "$NEW_TAG" -m "Version $NEW_TAG"
git push origin "$NEW_TAG"
VERSION_NO_V="${NEW_TAG#v}"   # image tags drop the v; used by steps 5 and 6
```

On master that first push is a no-op if you already pulled. On a branch it matters: the
tag alone would leave the commits reachable only from the tag. CI is `on: push` with no
branch filter, so the tag triggers the build from any ref.

CI builds on tag push. **Wait for it and confirm it is green** before deploying; do not
deploy an untested image.

Find the run by the tag it was pushed for, since `headBranch` carries the tag name:

```bash
gh run list --limit 10 --json databaseId,headBranch,status \
  --jq ".[] | select(.headBranch==\"${NEW_TAG}\") | \"\(.databaseId) \(.status)\""
```

**Use `--jq`, not `--template`.** `--template` renders `databaseId` through Go's default
float formatting and prints it as `3.1089915042e+10`, which is not a usable run ID. Give
the push a few seconds before the first query: an empty list right after `git push` means
the run has not registered yet, not that CI failed to fire.

Gate on the run's own `status` reaching `completed` and require `conclusion=success`.
Both the `Test` and `Build Docker image` jobs must pass.

Note the image build depends on a Node build step that compiles `lara-typescript` into
the Rails asset tree before the Docker context is packed, because the Dockerfile itself
never builds it. That step lives in CI, so a release needs nothing manual, but it does
mean a green `Build Docker image` job is the real proof the assets shipped: the
Dockerfile runs `assets:precompile`, which fails loudly on missing
`lara-typescript.js`/`.css` rather than producing a quietly broken image.

The image tag drops the `v` prefix (`docker/metadata-action` with
`type=semver,pattern={{version}}`), so `v2.20.0-pre.0` publishes as:

```
ghcr.io/concord-consortium/lara:2.20.0-pre.0
```

Pre-releases do **not** get floating `{{major}}.{{minor}}` tags, so a pre-release can
never move a tag something else follows. Package read scope is usually unavailable, so
treat the green build job as proof of publication rather than querying the registry.

### 5. Apply migrations

Skip only if step 3a found no new migration files. Migrations run **before** the stack
update: additive migrations are backward compatible with the old containers still serving
traffic, and the deploy then starts containers with a fresh schema cache. Running
migrations after the deploy requires a container restart, since Rails caches the schema in
its models.

**Base the new task definition on the live App task definition, never on the existing
`*-migrate` family.** The migrate family goes stale between releases: as of 2026-08 the
staging one still sat at an image several versions old. Copying it forward risks carrying
whatever else has since changed in the App definition, such as a database endpoint.

**`run-task --overrides` cannot change the image**, only command, environment, cpu and
memory. Registering a new revision is mandatory, not a convenience.

The generated file contains **every environment variable from the task definition in
plaintext**, including database credentials and secret keys. Create it with a restrictive
umask in a private temp file and delete it on exit, so an aborted release cannot leave
secrets readable in a predictable location. Never print it.

```bash
TD=$(umask 077; mktemp)
trap 'rm -f "$TD"' EXIT

aws ecs describe-task-definition --task-definition "${STACK}-App" --output json \
 | jq --arg fam "${STACK}-App-migrate" --arg img "ghcr.io/concord-consortium/lara:${VERSION_NO_V}" '
     .taskDefinition
     | del(.taskDefinitionArn,.revision,.status,.requiresAttributes,.compatibilities,.registeredAt,.registeredBy,.deregisteredAt)
     | .family = $fam
     | .containerDefinitions[0].image = $img
     | .containerDefinitions[0].entryPoint = ["bundle","exec"]
     | .containerDefinitions[0].command = ["rake","db:migrate"]' > "$TD"

REV=$(aws ecs register-task-definition --cli-input-json file://"$TD" \
  --query 'taskDefinition.revision' --output text)
echo "registered ${STACK}-App-migrate:${REV}"
```

The entry point override matters. The App container runs with an empty `entryPoint` and
`command: ["./docker/prod/run.sh"]`, which boots the web server; without the override the
task would start LARA instead of migrating.

Before running, sanity-check that the generated task definition has the same `DB_HOST` as
the live App task definition (query the single field rather than dumping the file).

```bash
aws ecs run-task --cluster "$CLUSTER" --launch-type EC2 --count 1 \
  --started-by "lara-${VERSION_NO_V}-migrate" \
  --task-definition "${STACK}-App-migrate:${REV}" \
  --query '{taskArn:tasks[0].taskArn,failures:failures}'

TASK_ID=<last path segment of taskArn>
until [ "$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ID" \
        --query 'tasks[0].lastStatus' --output text)" = "STOPPED" ]; do sleep 10; done
aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ID" \
  --query 'tasks[0].{exit:containers[0].exitCode,stopCode:stopCode,reason:containers[0].reason}'
```

Require exit code `0`. Then **verify from the logs**, because an exit code says the
container exited cleanly, not which migrations ran:

```bash
"$SKILL_DIR"/scripts/verify-migration.sh "$LOG_GROUP" "$TASK_ID" <ExpectedMigrationClass ...>
```

Pass the class names derived in step 3a. The script polls, because the CloudWatch stream
can lag the task by up to a minute, and it treats "no migrations applied" as a warning
rather than success.

Then **confirm the schema itself**, because the log only reports what Rails narrated:

```bash
# reuse this release's migrate revision, overriding just the command (see Reading the
# schema state); do not register another revision
"$SKILL_DIR"/scripts/check-migration-status.sh "$LOG_GROUP" "$STATUS_TASK" applied <version ...>
```

Pass the version timestamps for the same migrations, not their class names. This is the
assertion that actually establishes the schema is current: `verify-migration.sh` can only
report that a run printed success, while this reads `schema_migrations` and fails if any
migration in the image is still pending. Requiring both closes the case where the migrate
task exits 0 having silently applied nothing, which the log check reports as a warning that
is easy to read past.

**Record `$TASK_ID` in the step 9 report.** It is the only cheap handle on this run's log
once the task ages out of ECS, and the next release may need it.

**If it fails, do not simply abort and assume the database is untouched.** This stack runs
MySQL, where DDL is not transactional, so a run that fails partway through several
migrations leaves the earlier ones committed and recorded in `schema_migrations` while the
later ones are not. The schema is then consistent with neither the old nor the new image.
Establish exactly how far it got and report that to the user before resolving forward. Do
not re-run blindly and do not start the stack update.

**Use `check-migration-status.sh` in `report` mode to establish this**, rather than the
migrate log. A run that died partway logs only what printed before the abort, and its last
line may be a migration that was committed, one that was rolled back, or neither, whereas
the pending list is the schema's own account of what remains. Compare that against the
expected list from step 3a; the verifier's `applied:` line is corroboration, not the
primary record.

#### Verifying a migration that already ran

Releases frequently reach this step with the migration already applied: staging was
migrated days earlier, or the same commit is being re-tagged and promoted. The user may
also simply ask you to double-check. **Do not re-run the task to find out.** Establish it
from the durable records instead.

**Read `schema_migrations` first.** It answers the question directly and it is the only
record here that cannot go stale: see Reading the schema state, in `applied` mode, against
the App family. The two checks below are inference from surrounding artifacts, and are
worth keeping for the history they show, but neither is evidence of the schema's contents.
This is also the case the log check handles worst, since a migration applied days ago may
have aged out of CloudWatch entirely.

**The migrate family's task definition revisions are the audit trail.** Every release
registers one, and its image tag says which version it migrated:

```bash
for r in $(aws ecs list-task-definitions --family-prefix "${STACK}-App-migrate" \
           --sort DESC --query 'taskDefinitionArns[:4]' --output text | tr '\t' '\n'); do
  aws ecs describe-task-definition --task-definition "$r" \
    --query 'taskDefinition.{rev:taskDefinitionArn,img:containerDefinitions[0].image,at:registeredAt}' --output text
done
```

Despite its name, `--family-prefix` on `list-task-definitions` matches the **full family
name**, not a prefix, so the one-off production families that start with the same string
(`-App-migrate2`, `-App-migrate-glossaries`) do not pollute this list. Verified: the query
above returns revisions of `lara-ecs-production-App-migrate` only, even though both
siblings have active revisions. Note this differs from `list-task-definition-families`,
where `--family-prefix` really is a prefix.

Slice inside the query (`taskDefinitionArns[:4]`) rather than passing `--max-items`. With
`--output text`, `--max-items` appends the pagination token as a literal `None` line,
which the loop then feeds to `describe-task-definition` and fails with
`ClientException: Unable to describe task definition`.

Registration proves the run was *prepared*, not that it succeeded, so confirm from the
log. **ECS retains STOPPED tasks for only about an hour**, so
`list-tasks --desired-status STOPPED` is empty for anything older and is not an audit
trail; the task definition's `registeredAt` is what you correlate against instead.

The migrate task logs to `lara/App/<task-id>` in the same log group as the web tasks, so
**it is not distinguishable by stream name**. Match the stream whose last event is shortly
after that revision's `registeredAt`, then read that one stream:

```bash
aws logs describe-log-streams --log-group-name "$LOG_GROUP" \
  --order-by LastEventTime --descending --max-items 20 \
  --query 'logStreams[].{stream:logStreamName,last:lastEventTimestamp}' --output text

aws logs get-log-events --log-group-name "$LOG_GROUP" \
  --log-stream-name "lara/App/<task-id>" --start-from-head \
  --query 'events[].message' --output text
```

A successful run shows `== <timestamp> <Class>: migrated`.

Correlating a stream by timestamp is guesswork, and it fails outright once the events have
aged out. If the matching stream is ambiguous or missing, stop reconstructing history and
read the schema instead: a `report`-mode status task answers what is applied today for a
few cents, with no correlation step at all.

**Never scan the whole log group.** `aws logs filter-log-events` across the group walks
every stream and times out even with a filter pattern and a `--start-time`. Always target
the single stream.

### 6. Update the CloudFormation stack

`--use-previous-template` is deliberate: it changes only the image parameter and cannot
drag in template drift from the working tree. Step 3b is what licenses it, and the known
Assessments Portal drift described there is exactly what it protects.

```bash
PARAMS=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey!='LaraDockerImage'].ParameterKey" --output json \
  | jq -r 'map("ParameterKey=" + . + ",UsePreviousValue=true") | join(" ")')

aws cloudformation update-stack \
  --stack-name "$STACK" \
  --use-previous-template \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters $PARAMS ParameterKey=LaraDockerImage,ParameterValue=ghcr.io/concord-consortium/lara:${VERSION_NO_V}
```

**For production, confirm with the user immediately before running this.** It starts a
rolling replacement of live tasks.

Watch it. **Filter stack events by timestamp against the update's start time**, or the
previous update's `UPDATE_COMPLETE` events will appear and look like this deploy
finishing. Gate completion on `describe-stacks` returning a terminal status, not on seeing
any particular event:

```bash
aws cloudformation describe-stacks --stack-name "$STACK" --query 'Stacks[0].StackStatus' --output text
```

`UPDATE_COMPLETE` is success. Anything containing `ROLLBACK` is a failure: report it with
the failing resource's status reason and stop. The App service is slower than the Worker
service because web tasks drain connections before old tasks stop.

### 7. Verify the deployment

Three checks, in order. All three must pass before reporting success.

**a. Stack.** `UPDATE_COMPLETE`, with `LastUpdatedTime` matching this update and
`LaraDockerImage` set to the new image.

**b. Running tasks are all on the new image. This is the authoritative check for rollout
completeness**, because it inspects every task directly rather than sampling whatever the
load balancer happens to hand you:

```bash
aws ecs list-tasks --cluster "$CLUSTER" --family "${STACK}-App" --desired-status RUNNING \
  --query 'taskArns' --output text | tr '\t' '\n' | while read -r t; do
    [ -z "$t" ] && continue
    aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$t" --query 'tasks[0].containers[0].image' --output text
  done | sort | uniq -c
```

Every line must show the new image. Any remaining old-image task means the rollout is
incomplete.

**c. The served footer reports the new version.** An end-to-end smoke test that the image
actually boots and serves, which (a) and (b) cannot tell you. It is *not* a completeness
check: it samples traffic, so treat (b) as the authority on whether every task rolled.

Size the streak against the fleet rather than using a fixed number. Production runs many
more App tasks than staging and the count varies with autoscaling, so any constant baked
in here is wrong somewhere. Count the tasks at runtime:

```bash
NEED=$(( $(aws ecs list-tasks --cluster "$CLUSTER" --family "${STACK}-App" \
           --desired-status RUNNING --query 'length(taskArns)' --output text) * 3 ))
MAX=$(( NEED * 5 * 3 ))
if [ "$MAX" -lt 900 ]; then MAX=900; fi   # never below the script default
"$SKILL_DIR"/scripts/check-deployed-version.sh "$HOST" "$NEW_TAG" "$NEED" "$MAX"
```

**Size the deadline from `NEED`, not the script's 900s default.** The script polls every
5s and resets the streak on any flap or failed request, so `NEED` alone implies `NEED * 5`
seconds of *uninterrupted* agreement as a floor. On a large fleet two or three flaps put a
perfectly healthy deploy past 900s and report a false failure. Passing `NEED * 15` leaves
room for the streak to restart a couple of times.

**This must require consecutive agreement, not a single request.** During a rollout the
ALB balances across both task generations and the footer flaps, so one lucky curl reports
success while half of all users are still on the old code.

The footer is rendered by `app/views/layouts/application.html.erb` from
`ENV['LARA_IMAGE_VERSION']`, falling back to `ENV['LARA_VERSION']`. `LARA_IMAGE_VERSION`
is baked into the image at build time from the git ref, so it carries the **`v` prefix**
(`v2.20.0-pre.0`) and is what you compare `$NEW_TAG` against directly. `LARA_VERSION`
comes from the stack, derived from the image tag, and has no `v`; it only surfaces if the
baked-in value is missing.

### 8. Create the GitHub Release (final versions only)

Step 2 says the convention is release objects for final versions only, and no other step
creates one, so it falls here. Do it **after** the verifications pass, so the release
object never advertises a version that failed to roll out.

The existing titles follow `Version X.Y.Z - Released <Month D, YYYY>`:

```bash
gh release create "$NEW_TAG" --title "Version ${VERSION_NO_V} - Released $(date '+%B %-d, %Y')" --generate-notes
```

**Skip this entirely for a pre-release** (`vX.Y.Z-pre.N` stays a plain git tag) and for a
rollback (the release object already exists). Confirm with the user before publishing: it
is outward-facing and notifies watchers. If the same commit already shipped to staging
under a pre-release tag, the release object still belongs on the final tag, not the
pre-release one.

### 9. Report

State the environment, the version deployed, the from-version, which migrations applied
(with the migrate task ID from step 5, or that there were none), the schema state
confirmed from `schema_migrations`, and the three verification results. For a branch
release, state the branch and the commit SHA too, since the version number alone does not
say what shipped. Summarize what actually shipped, per step 2, rather than only the
ticket that prompted the release. Mention anything deferred or skipped, including a
GitHub Release you did not create and any template drift left in place.

If the release enables a feature behind a flag or an admin setting, say so explicitly: the
deploy alone may not make the feature live.

## Forcing a restart without a new version

To restart the running containers on the image already deployed, change the
`RestartToggle` stack parameter. The template exists for exactly this and documents it as
"Change this value to cause a rolling restart of the containers running LARA code. This is
necessary after running migrations to update the containers without changing other
parameters."

Changing it changes the `RESTART_TOGGLE` environment variable in the App and Worker
containers, which registers new task definition revisions and makes ECS roll the services.
Redeploying the same image cannot do this, because CloudFormation sees no change at all.

The value is arbitrary and follows no convention: it only has to differ from whatever the
stack currently holds, and each environment holds something different (staging was a bare
letter). Read the current value at runtime rather than assuming one, then set something
distinct; a timestamp is self-documenting.

```bash
CURRENT=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey=='RestartToggle'].ParameterValue" --output text)
NEW="restart-$(date -u +%Y%m%dT%H%M%SZ)"    # any value != "$CURRENT"

PARAMS=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey!='RestartToggle'].ParameterKey" --output json \
  | jq -r 'map("ParameterKey=" + . + ",UsePreviousValue=true") | join(" ")')

aws cloudformation update-stack --stack-name "$STACK" --use-previous-template \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters $PARAMS ParameterKey=RestartToggle,ParameterValue="$NEW"
```

**The version checks in step 7 do not verify a restart**, since the image and therefore
the footer version are unchanged. Verify instead that the tasks are new, by confirming the
App task definition revision incremented and that the running tasks have recent
`startedAt` times:

```bash
# --output text returns every match on one tab-separated line, so split before taking one.
SVC=$(aws ecs list-services --cluster "$CLUSTER" --output text \
  --query "serviceArns[?contains(@, '${STACK}-AppService')]" | tr '\t' '\n' | head -1)

aws ecs describe-services --cluster "$CLUSTER" --services "$SVC" \
  --query 'services[0].{taskDef:taskDefinition,running:runningCount,deployments:deployments[].{status:status,rollout:rolloutState,updated:updatedAt}}'
```

A completed restart shows a single `PRIMARY` deployment with `rolloutState` `COMPLETED`
and an incremented task definition revision.

This is also the escape hatch if migrations ever get applied **after** a deploy rather than
before: Rails caches the schema in its models at boot, so the containers must be restarted
before they will see new columns.

## Rollback

Re-run step 6 with the previous image tag. Migrations are **not** rolled back; if the
release included a destructive migration, rolling back the image is not sufficient and the
user needs to be told that directly.

A rollback is a deliberate downgrade, so pre-flight check 3d will report `DOWNGRADE`. That
is expected here and is not a reason to stop; confirm it with the user and continue. Skip
the tagging step (step 4), since the target tag and its image already exist.

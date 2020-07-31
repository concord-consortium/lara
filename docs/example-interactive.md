# Example Interactive

# What is it?

The example interactive source is in `lara-typescript/src/example-interactive` and serves as a test bed for interactives,
allowing developers and testers to test out additions or changes to the interactive iframe api.

# Using the example interactive

The example interactive is deployed as part of build.
It can be found at `[lara-host]/example-interactive/`.
For example the most recent production build is here:
https://authoring.concord.org/example-interactive/

If you are expanding the example interactive it can be run locally:

1. `cd lara-typescript`
2. `npm init` (if not already done)
3. `npm build` (this builds both the api and the example interactive)
4. `npm run example-interactive` (this starts a live-server instance of the example interactive on port 8888)
5. In another window run `docker-compose up` (to run lara)
6. Create or edit an activity and add `http://localhost:8888` as the url for either in interactive or managed interactive.

When you make a change to the example interactive source, and you've already started the live server above:
1. `npm build`

In other words, the example-interactive not automatically rebuilt when you change the source.

# Adding to the example interactive

1. Choose which mode you want (authoring, dialog, report or runtime)
2. Edit the component for that mode

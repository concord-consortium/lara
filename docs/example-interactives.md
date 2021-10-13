# Example Interactives

## What are they?

The example interactive sources are in `lara-typescript/src/example-interactives` and serves as test beds for interactives,
allowing developers and testers to test out additions or changes to the interactive iframe api.

## Using the example interactives

The example interactives are deployed as part of the build.
The index page that links to all the examples can be found at `[lara-host]/example-interactives/`.
For example the most recent production build is here:
https://authoring.concord.org/example-interactives/index.html

If you are expanding any example interactives, they can be run locally:

1. `cd lara-typescript`
2. `npm init` (if not already done)
3. `npm run build` or `npm run build:watch` (this builds both the api and the example interactive)
4. `npm run example-interactives` (this starts a live-server instance of the example interactives on port 8888)
5. In another window run `docker-compose up` (to run lara)
6. Create or edit an activity and add `http://localhost:8888/<example>` as the url for either in interactive or managed interactive where `<example>` is the name of the example, available from the index page.

When you make a change to the example interactives source, and you've already started the live server above:

1. `npm run build`

In other words, example-interactives is not automatically rebuilt when you change the source.

## Adding to the example interactives

1. Choose which mode you want (authoring, dialog, report or runtime)
2. Edit the component for that mode

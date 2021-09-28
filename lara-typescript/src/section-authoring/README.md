# LARA Section Authoring Components

## What are these components for?
These React components are for developing pages used by LARA activity authors.

## How do I develop them?

### Story Book:

[StoryBook](https://storybook.js.org/) is an open source tool for building UI
components and pages in isolation. It streamlines UI development, testing,
and documentation. We use it to quickly develop the visual interfaces for
section Authoring in the LARA project.

As a developer of Lara Authoring components you can start StoryBook by running:
`npm run storybook`. When you do this, a web browser will open showing you an
index of component stories. The stories are defined in `src/stories`. The files
use a naming convention `<story-title>.tories.tsx`. Its important to follow this
naming convention to have your stories show up in the index.


### ReactQuery and usePageAPI

We use [ReactQuery](https://react-query.tanstack.com/) to fetch and mutate data
with LARA, or a mock API for storybook. From the React Query Page:

> Writing your data fetching logic by hand is over. Tell React Query where to get
> your data and how fresh you need it to be and the rest is automatic.
> React Query handles caching, background updates and stale data out of the box
> with zero-configuration.

We add custom Hooks for our API, defined in  `use-api-provider.ts`. As new verbs
become available from LARA they should go into the exported methods in `usePageAPI`.

The usePageAPI is implementation has a façade. An interface called
`IAuthoringAPIProvider` defines the contract with LARA (or other data sources
including mocks) so that the API implementation can be switched out.  

For examples, see: `query-providers.stories.tsx`

Here is an example of how ReactQuery is used to create a mock API for the app:

```html
    <APIContext.Provider value={mockProvider}>
      <QueryClientProvider client={queryClient}>
        <Content />
      </QueryClientProvider>
    </APIContext.Provider>
```

The `<Content />` component can then consume the Queries and Mutations offered by the API like so:

```
    ...
    const api = usePageAPI(); 
    const addSection = () => api.addSectionMutation.mutate(p.id);
   ...
```

## How do I build them for production & Staging ?

As a developer when you want to exercise the components against a local LARA
instance, you need to first build the bundle which is served from LARAs assets.

You can run `npm run build:dev:lara-typescript` this should build and copy the
bundle with development flags to your local lara instance.

When its time to build for deployment, instead run `npm run build`.  You will
need to commit the built artifacts as part of your PR.





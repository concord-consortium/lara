# LARA — Claude Code project notes

## Build lara-typescript before `docker build` or running Rails locally

The lara-typescript build outputs are **no longer committed** to git:

- `app/assets/javascripts/lara-typescript.js`
- `app/assets/stylesheets/lara-typescript.css`
- `public/example-interactives/**`

They are `.gitignore`d and produced by `npm run build:webpack` (webpack +
`copy-to-rails`). CI builds them automatically (the `build` and `test` jobs in
`.github/workflows/ci.yml`), but **locally you must build them yourself** before:

- `docker build` — the Dockerfile copies the repo verbatim (`ADD .`) and does not
  build the TS, so a stale/missing bundle ships as-is, and
- running the Rails app — Sprockets `//= require lara-typescript` /
  `@import "lara-typescript"` fail with `Sprockets::FileNotFound` if the JS/CSS are
  missing. That error is the signal you skipped the build.

```bash
# from lara-typescript/ — regenerates the three artifact sets above
NODE_OPTIONS=--openssl-legacy-provider npm run build:webpack
```

(`public/example-interactives/**` is static — not in the Sprockets pipeline — so its
absence is silent rather than a build failure; it is also rebuilt for S3 by the
`deploy-example-interactives` workflow.)

## Building lara-typescript on modern Node (webpack 4 + OpenSSL 3)

The `lara-typescript/` package builds with **webpack 4.46**, whose md4 hashing
breaks on Node 17+ (OpenSSL 3) with:

```
Error: error:0308010C:digital envelope routines::unsupported
```

Run the webpack commands with the legacy OpenSSL provider flag. From
`lara-typescript/`:

```bash
NODE_OPTIONS=--openssl-legacy-provider npm run build:watch        # watch build
NODE_OPTIONS=--openssl-legacy-provider npx webpack --devtool false # one-time build
```

This applies to every script that runs `webpack` (e.g. `build`, `build:dev`,
`build:webpack`, `build:watch`). Alternatively, run them under Node <= 16, where
the flag isn't needed.

The package.json scripts do **not** set this flag, so it must be supplied on the
command line (or via a shell env) each time.

### Serving the example-interactives does NOT need the flag

`npm run example-interactives` uses **live-server** (not webpack-dev-server) and
runs fine on modern Node. Typical local loop, both from `lara-typescript/`:

```bash
# terminal 1 — rebuild on change
NODE_OPTIONS=--openssl-legacy-provider npm run build:watch
# terminal 2 — serve dist/ on http://localhost:8888
npm run example-interactives
```

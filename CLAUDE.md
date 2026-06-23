# LARA — Claude Code project notes

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

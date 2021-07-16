# Dependencies Notes

Notes on dependencies and in particular on what's keeping particular dependencies from being updated to their latest versions.

## node 11

LARA's `.travis.yml` specifies `dist: precise` and then explicitly installs `node 11.14.0`. This limits the update options for some dependencies.

## Development Dependencies

Note that some dependencies that would normally be `dependencies` are listed as `devDependencies` because they're configured as `externals` in Webpack, i.e. they're not bundled with the library but simply assumed to be present in the client environment: `jquery`, `jqueryui`, `react`, `react-dom`.

|Dependency|Current Version|Latest Version|Notes|
|----------|---------------|--------------|-----|
|@types/react|16.14.8|17.0.14|React 17|
|@types/react-dom|16.9.13|17.0.9|React 17
|@types/react-select|3.1.2|4.0.17|Didn't investigate major version implications.|
|copy-webpack-plugin|6.4.1|9.0.1|Node 12 (9.0.0) Webpack 5 (7.0.0)|
|css-loader|5.2.7|6.0.0|Node 12, Webpack 5|
|html-webpack-plugin|4.5.2|5.3.2|Node 12, Webpack 5|
|jest-fetch-mock|1.7.5|3.0.3|Tests broke; didn't investigate further.|
|mini-css-extract-plugin|1.6.2|2.0.0|Node 12, Webpack 5|
|node-sass|4.12.0|6.0.1|Node 12; v5 nominally supports node 10 but Travis build failed when I tried.|
|react|16.14.0|17.0.2|React 17|
|react-dom|16.14.0|17.0.2|React 17|
|react-test-renderer|16.14.0|17.0.2|React 17|
|sass-loader|10.2.0|12.1.0|Node 12 (12.0.0), Webpack 5 (11.0.0)|
|style-loader|2.0.0|3.0.0|Node 12, Webpack 5|
|ts-loader|8.3.0|9.2.3|Node 12, Webpack 5|
|ts-node|9.1.1|10.1.0|Node 12|
|tslint|5.20.1|6.1.3|Avoiding deprecation warnings; should really switch to eslint.|
|tslint-react|4.2.0|5.0.0|tslint 6; should really switch to eslint.|
|typedoc|0.17.0-3|0.21.4|Encountered errors when updating even to 0.17.8; didn't investigate further.|
|typedoc-plugin-markdown|2.4.2|3.10.3|Given the other typedoc issues didn't investigate implications of major version change.|
|webpack|4.46.0|5.41.1|Webpack 5 ([migration guide](https://webpack.js.org/migrate/5/#upgrade-webpack-4-to-the-latest-available-version))|
|webpack-cli|3.3.12|4.7.2|Webpack 5 (claims to support Webpack 4 but I got an error on `npm start` when I tried.)|

## Runtime Dependencies

|Dependency|Current Version|Latest Version|Notes|
|----------|---------------|--------------|-----|
|react-select|3.2.0|4.3.1|Didn't investigate major version implications.|

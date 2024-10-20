'use strict';
const CopyPlugin = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const laraTypescript = () => ({
  // Outputs built by this configuration:
  // - lara-typescript: for use in LARA runtime and authoring system
  // - normalize.css: for use by plugins
  // - lara-plugin-api module: this doesn't have an explicit entry,
  //   the index.d.ts that is built during the lara-typescript compile
  //   is published as this module. see plugin-api/package.json
  context: __dirname, // to automatically find tsconfig.json
  devtool: 'source-map',
  entry: {
    'lara-typescript': './src/index.ts',
    // Build normalize.css separately so it can be used by plugins directly.
    'plugin-api/normalize': './src/plugin-api/normalize.scss'
  },
  mode: 'development',
  output: {
    filename: '[name].js',
    // Temporarily disabled, as it conflicts with V2 definition. Instead, src/index.ts file exports library
    // manually by extending LARA namespace. When lara-plugin-api-V2 is removed, this can be uncommented.
    // library: 'LARA',
    libraryTarget: 'umd'
  },
  performance: { hints: false },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        enforce: 'pre',
        use: [
          {
            loader: 'tslint-loader'
          }
        ],
        exclude: /node_modules/
      },
      {
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/
      },
      // PJ 9/9/2021: Why is Babel necessary if there's TS loader and tsconfig specifies ES5 target?
      // TS doesn't transform regexp named capture groups added in ES2018. This breaks Rails assets compilation.
      // Uglifier that is not able to parse the updated regexp format. Note that this loader is applied both to our
      // own code and node_modules. The problematic regexp is in AWS S3 Client.
      // See: https://github.com/microsoft/TypeScript/issues/36132
      {
        test: /\.(t|j)sx?$/,
        enforce: 'post',
        use: [
          {
            loader: 'babel-loader',
            options: {
              plugins: ['@babel/plugin-transform-named-capturing-groups-regex']
            }
          }
        ]
      },
      {
        test: /\.s?css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader
          },
          {
            loader: 'css-loader',
            options: {
              importLoaders: 1,
              import: true
            }
          },
          "sass-loader"
        ],
      }
    ]
  },
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ]
  },
  stats: {
    // suppress "export not found" warnings about re-exported types
    warningsFilter: /export .* was not found in/
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'src/plugin-api/package.json', to: 'plugin-api' },
        { from: 'src/plugin-api/README.md', to: 'plugin-api' },
      ]
    }),
    new MiniCssExtractPlugin({
      // Options similar to the same options in webpackOptions.output
      // both options are optional
      filename: '[name].css'
    }),
  ],
  externals: {
    'jquery': 'jQuery',
    'jqueryui': 'jQuery.ui',
    'react': 'React',
    'react-dom': 'ReactDOM',
    'react-dom/server': 'ReactDOMServer'
  }
});

const interactiveApiClient = () => ({
  // Outputs built by this configuration:
  // - interactive-api-client: for use by interactive developers
  //   this needs separate config as the externals are handled differently and
  //   different files are copied.
  context: __dirname, // to automatically find tsconfig.json
  devtool: 'source-map',
  entry: {
    'interactive-api-client': './src/interactive-api-client/index.ts',
  },
  mode: 'development',
  output: {
    filename: '[name]/index.js',
    libraryTarget: 'umd'
  },
  performance: { hints: false },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        enforce: 'pre',
        use: [
          {
            loader: 'tslint-loader'
          }
        ]
      },
      {
        test: /\.tsx?$/,
        loader: 'ts-loader'
      }
    ]
  },
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ]
  },
  stats: {
    // suppress "export not found" warnings about re-exported types
    warningsFilter: /export .* was not found in/
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'src/interactive-api-client/package.json', to: 'interactive-api-client' },
        { from: 'src/interactive-api-client/README.md', to: 'interactive-api-client' }
      ]
    })
  ],
  externals: {
    'react': 'commonjs2 react'   // allows interactives to use their own react instead of bundling it in this library
  }
});

const interactiveApiHost = () => ({
  // Outputs built by this configuration:
  // - interactive-api-host: for use by interactive developers
  //   this needs separate config as the externals are handled differently and
  //   different files are copied.
  context: __dirname, // to automatically find tsconfig.json
  devtool: 'source-map',
  entry: {
    'interactive-api-host': './src/interactive-api-host/index.ts',
  },
  mode: 'development',
  output: {
    filename: '[name]/index.js',
    libraryTarget: 'umd'
  },
  performance: { hints: false },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        enforce: 'pre',
        use: [
          {
            loader: 'tslint-loader'
          }
        ]
      },
      {
        test: /\.tsx?$/,
        loader: 'ts-loader'
      }
    ]
  },
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ]
  },
  stats: {
    // suppress "export not found" warnings about re-exported types
    warningsFilter: /export .* was not found in/
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'src/interactive-api-host/package.json', to: 'interactive-api-host' },
        { from: 'src/interactive-api-host/README.md', to: 'interactive-api-host' }
      ]
    })
  ]
});

const exampleInteractive = (name) => ({
  // Outputs built by this configuration:
  // - example-interactives: for use by developers and testers
  //   needs separate config as different files are copied,
  //   and no externals should be used
  context: __dirname, // to automatically find tsconfig.json
  devtool: 'source-map',
  entry: {
    [`example-interactive-${name}`]: `./src/example-interactives/src/${name}/index.tsx`,
  },
  mode: 'development',
  output: {
    filename: `example-interactives/${name}/index.js`
  },
  performance: { hints: false },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        enforce: 'pre',
        use: [
          {
            loader: 'tslint-loader'
          }
        ]
      },
      {
        test: /\.tsx?$/,
        loader: 'ts-loader'
      }
    ]
  },
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ]
  },
  stats: {
    // suppress "export not found" warnings about re-exported types
    warningsFilter: /export .* was not found in/
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'src/example-interactives/index.html', to: 'example-interactives' },
        { from: 'src/example-interactives/index.css', to: 'example-interactives' },
        { from: `src/example-interactives/src/${name}/index.html`, to: `example-interactives/${name}` }
      ]
    })
  ]
});

module.exports = (env, argv) => [
  laraTypescript(),
  interactiveApiClient(),
  interactiveApiHost(),
  exampleInteractive("testbed"),
  exampleInteractive("linked-state"),
  exampleInteractive("report-item"),
  exampleInteractive("attachments")
];

module.exports.laraTypescript = laraTypescript;
module.exports.interactiveApiClient = interactiveApiClient;
module.exports.interactiveApiHost = interactiveApiHost;
module.exports.exampleInteractive = exampleInteractive;

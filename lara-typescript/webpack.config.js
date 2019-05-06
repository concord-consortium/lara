'use strict';
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = (env, argv) => {
  return {
    context: __dirname, // to automatically find tsconfig.json
    devtool: 'source-map',
    entry: './src/index.ts',
    mode: 'development',
    output: {
      filename: 'lara-typescript.js',
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
              loader: 'tslint-loader',
              options: {}
            }
          ]
        },
        {
          test: /\.tsx?$/,
          loader: 'ts-loader',
          options: {
          }
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
      new ForkTsCheckerWebpackPlugin(),
      new CopyPlugin([
        { from: 'src/plugin-api/package.json', to: 'plugin-api' },
        { from: 'src/plugin-api/README.md', to: 'plugin-api' },
      ]),
    ],
    externals: {
      'jquery': 'jQuery',
      'jqueryui': 'jQuery.ui',
      'react': 'React',
      'react-dom': 'ReactDOM'
    }
  };
};

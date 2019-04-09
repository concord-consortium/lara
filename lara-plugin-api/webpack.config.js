'use strict';
const path = require('path');
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');

module.exports = (env, argv) => {
  return {
    context: __dirname, // to automatically find tsconfig.json
    devtool: 'source-map',
    entry: './src/lara-plugin-api.ts',
    mode: 'development',
    output: {
      filename: 'lara-plugin-api.js',
      library: 'LARA',
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
      new ForkTsCheckerWebpackPlugin()
    ],
    externals: {
      'jquery': 'jQuery',
      'jqueryui': 'jQuery.ui',
      'react': 'react',
      'react-dom': 'ReactDOM',
      "sidebar": "Sidebar" // LARA module exported to the window.Sidebar namespace
    }
  };
};

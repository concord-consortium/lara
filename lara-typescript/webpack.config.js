'use strict';
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = (env, argv) => {
  return {
    context: __dirname, // to automatically find tsconfig.json
    devtool: 'source-map',
    entry: {
      'lara-typescript': './src/index.ts',
      // Build normalize.css separately so it can be used by plugins directly.
      'plugin-api/normalize': './src/plugin-api/normalize.scss',
      // build the admin separately to make it cleaner to load
      'page-item-admin': './src/page-item-admin/index.tsx',
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
      new ForkTsCheckerWebpackPlugin(),
      new CopyPlugin([
        { from: 'src/plugin-api/package.json', to: 'plugin-api' },
        { from: 'src/plugin-api/README.md', to: 'plugin-api' },
      ]),
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
      'react-dom': 'ReactDOM'
    }
  };
};

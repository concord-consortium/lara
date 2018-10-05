const path = require('path')
const destFolder = path.resolve(__dirname, './app/assets/javascripts')

module.exports = {
  mode: 'development',
  entry: {
    webpack: ['./app/assets/javascripts/webpack/index.ts']
  },

  output: {
    path: destFolder,
    filename: '[name]-out.js'
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react']
          }
        }
      },
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: [ '.tsx', '.ts', '.js' ]
  },
  plugins: [],
  externals: {
    'react': 'React',
    'react-dom': 'ReactDOM'
  }
}

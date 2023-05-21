const path = require('path');
const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = {
  // const ESLintPlugin = require('eslint-webpack-plugin');
  // mode: 'development',
  // plugins: [new ESLintPlugin()],
  entry: {
    'swagger-layout': ['./src/index.js'],
  },
  output: {
    path: path.join(__dirname, 'static/swagger-ui/dist'),
    library: 'SwaggerLayout',
    libraryTarget: 'umd',
    filename: '[name].js',
    chunkFilename: 'js/[name].js',
  },
  module: {
    rules: [
      {
        enforce: 'pre',
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'eslint-loader',
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              emitFile: true,
              name: '[name].[ext]',
              publicPath: '/docs/static/dist',
            },
          },
        ],
      },
      {
        test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 50000,
          },
        },
      },
    ],
  },
  resolve: {
    extensions: ['*', '.js', '.jsx'],
    // fallback: {
    //   path: false,
    // },
  },
};

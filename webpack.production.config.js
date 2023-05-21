const path = require('path');

module.exports = {
  mode: 'production',
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
    fallback: {
      path: false,
    },
  },
};

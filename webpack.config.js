// const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = {
  mode: 'development',
  // plugins: [new ESLintPlugin()],
  entry: ['react-hot-loader/patch', './src/server.js'],
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
        use: ['file-loader'],
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
  output: {
    path: `${__dirname}/src/dist`,
    publicPath: '/',
    filename: 'bundle.js',
  },
  devServer: {
    static: './src/public',
    hot: true,
  },
};

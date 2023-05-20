const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
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

  mode: 'production',

  plugins: [new MiniCssExtractPlugin()],
  module: {
    rules: [
      {
        test: /\.(js(x)?)(\?.*)?$/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              retainLines: true,
            },
          },
        ],
        include: [path.join(__dirname, 'src')],
      },
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
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
  optimization: {
    minimize: true,
  },
  resolve: {
    extensions: ['.*', '.js', '.jsx'],
    fallback: {
      path: false,
    },
  },
};

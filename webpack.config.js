const webpack = require("webpack");
const ESLintPlugin = require("eslint-webpack-plugin");

module.exports = {
  entry: ["react-hot-loader/patch", "./src/server.js"],
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        type: "asset/resource",
      },
      {
        test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/,
        type: "asset",
        parser: {
          dataUrlCondition: {
            maxSize: 50000,
          },
        },
      },
    ],
  },
  resolve: {
    extensions: ["*", ".js", ".jsx"],
    fallback: {
      path: false,
    },
  },
  output: {
    path: __dirname + "/src/dist",
    publicPath: "/",
    filename: "bundle.js",
  },
  performance: {
    maxAssetSize: 9000000,
    maxEntrypointSize: 9000000,
  },
  plugins: [new webpack.HotModuleReplacementPlugin(), new ESLintPlugin()],
  devServer: {
    static: { directory: "./src/public" },
  },
};

const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const ESLintPlugin = require("eslint-webpack-plugin");

module.exports = {
  entry: {
    "swagger-layout": ["./src/index.js"],
  },

  output: {
    path: path.join(__dirname, "static/swagger-ui/dist"),
    library: "SwaggerLayout",
    libraryTarget: "umd",
    filename: "[name].js",
    chunkFilename: "js/[name].js",
  },

  mode: "production",

  module: {
    rules: [
      {
        test: /\.(js(x)?)(\?.*)?$/,
        use: [
          {
            loader: "babel-loader",
            options: {
              retainLines: true,
            },
          },
        ],
        include: [path.join(__dirname, "src")],
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        type: "asset/resource",
        generator: {
          filename: "[name][ext]",
        },
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

  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          output: false,
        },
      }),
    ],
  },
  resolve: {
    extensions: ["*", ".js", ".jsx"],
    fallback: {
      path: false,
    },
  },
  performance: {
    maxAssetSize: 9000000,
    maxEntrypointSize: 9000000,
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "main.css",
    }),
    new ESLintPlugin(),
  ],
};

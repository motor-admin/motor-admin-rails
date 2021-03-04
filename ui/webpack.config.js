const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const WebpackAssetsManifest = require('webpack-assets-manifest')
const { VueLoaderPlugin } = require('vue-loader');
const webpack = require('webpack')

module.exports = (env = {}) => ({
  mode: env.production ? 'production' : 'development',
  output: {
    path: path.resolve(__dirname, "./dist"),
    filename: "[name]-[fullhash].js",
    publicPath: '',
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: [
          {
            loader: 'vue-loader',
            options: { whitespace: 'preserve' }
          }
        ]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader'
        ]
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader',
        ]
      },
      {
        test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: 'fonts/'
            }
          }
        ]
      },
      {
        test: /\.(png|jpe?g|gif)$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: 'fonts/'
            }
          },
        ],
      }
    ],
  },
  resolve: {
    modules: [
      path.resolve(__dirname, './src'),
      path.resolve(__dirname, './node_modules')
    ],
    extensions: ['.js', '.vue', '.json', '.less' , '.scss', '.css']
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name]-[fullhash].css'
    }),
    new WebpackAssetsManifest({
      writeToDisk: true,
      output: 'manifest.json',
      publicPath: true
    }),
    new VueLoaderPlugin({ whitespace: 'preserve' })
  ],
  devServer: {
    port: 9090,
    contentBase: './',
    hot: false,
    stats: 'minimal',
    overlay: {
      warnings: true,
      errors: true
    },
    historyApiFallback: true
  }
})

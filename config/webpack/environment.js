const { environment } = require('@rails/webpacker')
const webpack         = require('webpack')

environment.loaders.prepend('erb', {
  test:    /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader'
  }]
})

environment.loaders.prepend('expose', {
  test: require.resolve('jquery'),
  use: [{
    loader:  'expose-loader',
    options: {
      exposes: '$'
    }
  }]
})

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $:               'jquery',
    jQuery:          'jquery',
    'window.jQuery': 'jquery',
    Rails:           'rails-ujs'
  })
)

module.exports = environment

const { environment } = require('@rails/webpacker')
const webpack         = require('webpack')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $:               'jquery',
    jQuery:          'jquery',
    'window.jQuery': 'jquery',
    Rails:           'rails-ujs'
  })
)

module.exports = environment

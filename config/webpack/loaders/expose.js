module.exports = {
  test: require.resolve('jquery'),
  use: [{
    loader:  'expose-loader',
    options: '$'
  }]
}

import 'rollbar'
import 'bootstrap'

import autosize from 'autosize'

require('turbolinks').start()

Rails.start()

$(document).on('turbolinks:load', () => {
  autosize(document.querySelectorAll('.autosize'))
})

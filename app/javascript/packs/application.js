import 'rollbar'
import 'font-awesome'
import 'bootstrap'

import autosize from 'autosize'

require('turbolinks').start()

Rails.start()

$(document).on('turbolinks:load', () => {
  autosize(document.querySelectorAll('.autosize'))
  $('[data-toggle="tooltip"]').tooltip()
})

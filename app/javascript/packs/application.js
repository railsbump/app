import 'rollbar'
import 'font-awesome'
import 'bootstrap'

import { Application }            from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import autosize                   from 'autosize'

require('turbolinks').start()

Rails.start()

const application = Application.start()
const context     = require.context('../controllers', true, /\.js$/)

application.load(definitionsFromContext(context))

$(document).on('turbolinks:load', () => {
  autosize(document.querySelectorAll('.autosize'))
  $('[data-toggle="tooltip"]').tooltip()
})

// let's recompile!

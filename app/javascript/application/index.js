import { Application }            from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import autosize                   from 'autosize'
import Rails                      from '@rails/ujs'
import Turbolinks                 from 'turbolinks'

import 'bootstrap'
import './rollbar'

Rails.start()
Turbolinks.start()

const application = Application.start()
const context     = require.context('./controllers', true, /\.js$/)

application.load(definitionsFromContext(context))

$(document).on('turbolinks:load', () => {
  autosize(document.querySelectorAll('.autosize'))
  $('[data-toggle="tooltip"]').tooltip()
})

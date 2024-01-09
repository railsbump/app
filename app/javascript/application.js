import "autosize"
import "@hotwired/turbo-rails"
import "popper"
import "bootstrap"

import { Application }              from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const initialize = event => {
  autosize(event.target.querySelectorAll(".autosize"))
  event.target
       .querySelectorAll('[data-bs-toggle="tooltip"]')
       .forEach(element => new bootstrap.Tooltip(element))
}

document.addEventListener("turbo:load",         initialize)
document.addEventListener("turbo:frame-render", initialize)

const application = Application.start()

application.debug = false
window.Stimulus   = application

eagerLoadControllersFrom("controllers", application)

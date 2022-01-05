import { Application }            from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import autosize                   from "autosize"
import Rails                      from "@rails/ujs"
import Turbolinks                 from "turbolinks"

import "bootstrap"
import "./rollbar"

Rails.start()
Turbolinks.start()

window.Stimulus = Application.start()
const context = require.context("./controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

$(document).on("turbolinks:load", () => {
  autosize(document.querySelectorAll(".autosize"))
  $("[data-toggle='tooltip']").tooltip()
})

import { Application }            from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import autosize                   from "autosize"

import "@hotwired/turbo-rails"
import "popper"
import "bootstrap"

window.Stimulus = Application.start()
const context = require.context("./controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

document.addEventListener("turbo:load", () => {
  autosize(document.querySelectorAll(".autosize"))
  $("[data-toggle='tooltip']").tooltip()
})

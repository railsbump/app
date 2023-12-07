import autosize from "autosize"
import "@hotwired/turbo-rails"
import "@popperjs/core"
import { Tooltip } from "bootstrap"
import "controllers"

const initialize = event => {
  autosize(event.target.querySelectorAll(".autosize"))
  event.target
       .querySelectorAll('[data-bs-toggle="tooltip"]')
       .forEach(element => new Tooltip(element))
}

document.addEventListener("turbo:load",         initialize)
document.addEventListener("turbo:frame-render", initialize)

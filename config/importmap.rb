pin "application"

pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/stimulus",         to: "stimulus.min.js"
pin "@hotwired/turbo-rails",      to: "turbo.min.js"
pin "autosize",                   to: "https://cdn.jsdelivr.net/npm/autosize@6.0.1/dist/autosize.min.js"
pin "bootstrap",                  to: "bootstrap.min.js"
pin "popper",                     to: "popper.js"

pin_all_from "app/javascript/controllers", under: "controllers"

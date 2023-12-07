pin "application", preload: true

pin "@hotwired/turbo-rails",      to: "turbo.min.js",        preload: true
pin "@hotwired/stimulus",         to: "stimulus.min.js",     preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "autosize",                   to: "https://ga.jspm.io/npm:autosize@6.0.1/dist/autosize.esm.js"
pin "bootstrap",                  to: "https://ga.jspm.io/npm:bootstrap@5.3.2/dist/js/bootstrap.esm.js"
pin "@popperjs/core",             to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js"

pin_all_from "app/javascript/controllers", under: "controllers"

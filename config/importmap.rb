pin "application", preload: true

pin "autosize",                       to: "https://ga.jspm.io/npm:autosize@5.0.1/dist/autosize.esm.js"
pin "bootstrap",                      to: "https://ga.jspm.io/npm:bootstrap@5.2.1/dist/js/bootstrap.esm.js"
pin "@popperjs/core",                 to: "https://ga.jspm.io/npm:@popperjs/core@2.11.6/dist/esm/index.js"
pin "@hotwired/stimulus",             to: "stimulus.min.js",     preload: true
pin "@hotwired/stimulus-loading",     to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails",          to: "turbo.min.js",        preload: true

pin_all_from "app/javascript/controllers", under: "controllers"

require 'sucker_punch'

SuckerPunch.exception_handler = ->(error, klass, args) {
  Rollbar.error error, klass: klass, args: args
}
